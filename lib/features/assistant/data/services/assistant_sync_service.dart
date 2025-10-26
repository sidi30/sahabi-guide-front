import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../datasources/assistant_remote_data_source.dart';
import '../datasources/assistant_local_data_source.dart';
import '../models/user_progress_model.dart';
import 'dart:async';

class AssistantSyncService {
  final AssistantRemoteDataSource remoteDataSource;
  final AssistantLocalDataSource localDataSource;
  final Connectivity connectivity;
  final Logger logger;

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  AssistantSyncService({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.logger,
  });

  /// Initialise le service de synchronisation
  Future<void> initialize() async {
    // Sync immédiate au démarrage si connecté
    await syncIfConnected();

    // Démarre la synchronisation périodique (toutes les 5 minutes)
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncIfConnected(),
    );

    // Écoute les changements de connectivité
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (results) {
        // results est une List<ConnectivityResult>
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          logger.d('Connectivity restored, triggering sync');
          syncIfConnected();
        }
      },
    );

    logger.d('Sync service initialized');
  }

  /// Vérifie la connectivité et synchronise si possible
  Future<bool> syncIfConnected() async {
    final connectivityResult = await connectivity.checkConnectivity();
    
    if (connectivityResult.isEmpty || connectivityResult.first == ConnectivityResult.none) {
      logger.d('No connectivity, skipping sync');
      return false;
    }

    return await syncOfflineData();
  }

  /// Synchronise les données offline avec le serveur
  Future<bool> syncOfflineData() async {
    if (_isSyncing) {
      logger.d('Sync already in progress, skipping');
      return false;
    }

    _isSyncing = true;

    try {
      logger.d('Starting offline data sync...');

      // Récupère les réponses non synchronisées
      final unsyncedProgress = await localDataSource.getUnsyncedProgress();

      if (unsyncedProgress.isEmpty) {
        logger.d('No unsynced data to sync');
        _isSyncing = false;
        return true;
      }

      logger.d('Found ${unsyncedProgress.length} unsynced items');

      // Groupe par userId (normalement un seul utilisateur)
      final groupedByUser = <String, List<UserProgressModel>>{};
      for (var progress in unsyncedProgress) {
        groupedByUser.putIfAbsent(progress.userId, () => []).add(progress);
      }

      // Synchronise pour chaque utilisateur
      for (var entry in groupedByUser.entries) {
        final userId = entry.key;
        final progressList = entry.value;

        try {
          // Prépare les données à envoyer
          final answers = progressList.map((p) => {
            'stepId': p.stepId,
            'answer': p.answer,
            'answeredAt': p.answeredAt.toIso8601String(),
            'isOffline': true,
            'deviceId': p.deviceId,
          }).toList();

          // Envoie au serveur
          final syncedData = await remoteDataSource.syncAnswers(
            userId: userId,
            answers: answers,
          );

          // Met à jour localement avec les données synchronisées
          for (var syncedProgress in syncedData) {
            await localDataSource.saveProgress(syncedProgress);
          }

          logger.d('Successfully synced ${syncedData.length} items for user $userId');
        } catch (e) {
          logger.e('Error syncing data for user $userId: $e');
          // Continue avec les autres utilisateurs
        }
      }

      _isSyncing = false;
      return true;
    } catch (e) {
      logger.e('Error during sync: $e');
      _isSyncing = false;
      return false;
    }
  }

  /// Force une synchronisation immédiate
  Future<bool> forceSyncNow() async {
    logger.d('Forcing immediate sync...');
    return await syncOfflineData();
  }

  /// Télécharge les dernières étapes du serveur
  Future<bool> downloadSteps() async {
    try {
      // Vérifie la connectivité
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.isEmpty || connectivityResult.first == ConnectivityResult.none) {
        logger.d('No connectivity, cannot download steps');
        return false;
      }

      logger.d('Downloading steps from server...');
      
      final steps = await remoteDataSource.getAllSteps();
      await localDataSource.saveSteps(steps);
      
      logger.d('Successfully downloaded ${steps.length} steps');
      return true;
    } catch (e) {
      logger.e('Error downloading steps: $e');
      return false;
    }
  }

  /// Télécharge la progression de l'utilisateur
  Future<bool> downloadUserProgress(String userId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.isEmpty || connectivityResult.first == ConnectivityResult.none) {
        logger.d('No connectivity, cannot download progress');
        return false;
      }

      logger.d('Downloading user progress from server...');
      
      final progress = await remoteDataSource.getUserProgress(userId);
      await localDataSource.saveProgressList(progress);
      
      logger.d('Successfully downloaded ${progress.length} progress items');
      return true;
    } catch (e) {
      logger.e('Error downloading progress: $e');
      return false;
    }
  }

  /// Synchronisation complète (steps + progress)
  Future<bool> fullSync(String userId) async {
    try {
      logger.d('Starting full sync for user $userId...');
      
      // 1. Télécharge les étapes
      final stepsDownloaded = await downloadSteps();
      
      // 2. Synchronise les réponses offline
      final offlineSynced = await syncOfflineData();
      
      // 3. Télécharge la progression
      final progressDownloaded = await downloadUserProgress(userId);
      
      final success = stepsDownloaded && offlineSynced && progressDownloaded;
      logger.d('Full sync completed: ${success ? 'SUCCESS' : 'PARTIAL'}');
      
      return success;
    } catch (e) {
      logger.e('Error during full sync: $e');
      return false;
    }
  }

  /// Vérifie si une resynchronisation est nécessaire (> 24h)
  Future<bool> shouldResync() async {
    final lastUpdate = await localDataSource.getLastUpdated('steps');
    if (lastUpdate == null) return true;
    
    final hoursSinceUpdate = DateTime.now().difference(lastUpdate).inHours;
    return hoursSinceUpdate >= 24;
  }

  /// Nettoie et arrête le service
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    logger.d('Sync service disposed');
  }
}

