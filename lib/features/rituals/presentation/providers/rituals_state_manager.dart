import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../../../shared/models/dua_model.dart';
import '../../../../shared/models/ritual_progress_model.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../../domain/usecases/get_rituals_usecase.dart';

class RitualsStateManager extends ChangeNotifier {
  // Services from GetIt
  late final AudioService _audioService;
  late final NotificationService _notificationService;
  late final RitualsRepository _ritualsRepository;
  late final GetRitualsUseCase _getRitualsUseCase;

  // State
  List<RitualModel> _rituals = [];
  List<DuaModel> _duas = [];
  List<RitualProgressModel> _progress = [];
  RitualModel? _currentActiveRitual;
  DuaModel? _currentPlayingDua;
  String _selectedLanguage = 'fr';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RitualModel> get rituals => _rituals;
  List<DuaModel> get duas => _duas;
  List<RitualProgressModel> get progress => _progress;
  RitualModel? get currentActiveRitual => _currentActiveRitual;
  DuaModel? get currentPlayingDua => _currentPlayingDua;
  String get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<RitualModel> get completedRituals => 
      _rituals.where((r) => r.status == RitualStatus.completed).toList();
  
  List<RitualModel> get pendingRituals => 
      _rituals.where((r) => r.status == RitualStatus.pending).toList();
  
  List<RitualModel> get overdueRituals => 
      _rituals.where((r) => r.status == RitualStatus.overdue).toList();

  List<DuaModel> get favoriteDuas => 
      _duas.where((d) => d.isFavorite).toList();

  List<DuaModel> get duasByType => 
      _duas.where((d) => d.type == DuaType.hajj).toList();

  double get overallProgress {
    if (_rituals.isEmpty) return 0.0;
    final completedCount = completedRituals.length;
    return completedCount / _rituals.length;
  }

  RitualsStateManager() {
    _initializeServices();
  }

  void _initializeServices() {
    // Get services from GetIt
    _audioService = sl<AudioService>();
    _notificationService = sl<NotificationService>();
    _ritualsRepository = sl<RitualsRepository>();
    _getRitualsUseCase = sl<GetRitualsUseCase>();
    
    _audioService.addListener(_onAudioStateChanged);
  }

  void _onAudioStateChanged() {
    if (_audioService.currentDua != null) {
      _currentPlayingDua = _audioService.currentDua;
      notifyListeners();
    }
  }

  // Ritual management
  Future<void> loadRituals() async {
    _setLoading(true);
    try {
      // Load from repository
      _rituals = await _getRitualsUseCase();
      _updateRitualStatuses();
      _setCurrentActiveRitual();
      await _scheduleRitualNotifications();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors du chargement des rituels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDuas() async {
    _setLoading(true);
    try {
      _duas = await _ritualsRepository.getDuas();
      await _scheduleDuaNotifications();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors du chargement des douas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProgress() async {
    try {
      // For now, we'll use local progress tracking
      // This can be extended to sync with API later
      _updateRitualStatuses();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement du progrès: ${e.toString()}');
    }
  }

  Future<void> markRitualAsCompleted(String ritualId) async {
    try {
      final ritualIndex = _rituals.indexWhere((r) => r.id == ritualId);
      if (ritualIndex == -1) return;

      final ritual = _rituals[ritualIndex];
      final updatedRitual = ritual.copyWith(
        status: RitualStatus.completed,
        completedAt: DateTime.now(),
        isActive: false,
      );

      _rituals[ritualIndex] = updatedRitual;

      // Update progress
      await _updateRitualProgress(ritualId, RitualStatus.completed);

      // Activate next ritual
      _activateNextRitual(ritualIndex);

      // Cancel notifications for this ritual
      await _notificationService.cancelRitualNotification(ritualId);

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  Future<void> startRitual(String ritualId) async {
    try {
      final ritualIndex = _rituals.indexWhere((r) => r.id == ritualId);
      if (ritualIndex == -1) return;

      final ritual = _rituals[ritualIndex];
      final updatedRitual = ritual.copyWith(
        status: RitualStatus.active,
        isActive: true,
      );

      _rituals[ritualIndex] = updatedRitual;
      _currentActiveRitual = updatedRitual;

      // Update progress
      await _updateRitualProgress(ritualId, RitualStatus.active);

      // Show reminder notification
      await _notificationService.showRitualReminder(updatedRitual);

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du démarrage: ${e.toString()}');
    }
  }

  // Dua management
  Future<void> playDua(DuaModel dua) async {
    try {
      await _audioService.playDua(dua, language: _selectedLanguage);
      _currentPlayingDua = dua;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la lecture: ${e.toString()}');
    }
  }

  Future<void> pauseDua() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> resumeDua() async {
    await _audioService.resume();
    notifyListeners();
  }

  Future<void> stopDua() async {
    await _audioService.stop();
    _currentPlayingDua = null;
    notifyListeners();
  }

  Future<void> toggleDuaFavorite(String duaId) async {
    try {
      final duaIndex = _duas.indexWhere((d) => d.id == duaId);
      if (duaIndex == -1) return;

      final dua = _duas[duaIndex];
      final updatedDua = dua.copyWith(isFavorite: !dua.isFavorite);
      _duas[duaIndex] = updatedDua;

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  // Language management
  void setLanguage(String language) {
    _selectedLanguage = language;
    _audioService.setLanguage(language);
    notifyListeners();
  }

  // Timeline management
  void _updateRitualStatuses() {
    final now = DateTime.now();
    
    for (int i = 0; i < _rituals.length; i++) {
      final ritual = _rituals[i];
      
      if (ritual.status == RitualStatus.completed) continue;

      if (ritual.scheduledTime != null) {
        if (now.isAfter(ritual.scheduledTime!.add(const Duration(hours: 1)))) {
          _rituals[i] = ritual.copyWith(status: RitualStatus.overdue);
        } else if (now.isAfter(ritual.scheduledTime!) && ritual.status == RitualStatus.pending) {
          _rituals[i] = ritual.copyWith(status: RitualStatus.active);
        }
      }
    }
  }

  void _setCurrentActiveRitual() {
    _currentActiveRitual = _rituals.firstWhere(
      (r) => r.status == RitualStatus.active,
      orElse: () => _rituals.firstWhere(
        (r) => r.status == RitualStatus.pending,
        orElse: () => _rituals.first,
      ),
    );
  }

  void _activateNextRitual(int currentIndex) {
    if (currentIndex < _rituals.length - 1) {
      final nextRitual = _rituals[currentIndex + 1];
      if (nextRitual.status == RitualStatus.pending) {
        _rituals[currentIndex + 1] = nextRitual.copyWith(
          status: RitualStatus.active,
          isActive: true,
        );
        _currentActiveRitual = _rituals[currentIndex + 1];
      }
    }
  }

  Future<void> _updateRitualProgress(String ritualId, RitualStatus status) async {
    // Update local progress
    final progressIndex = _progress.indexWhere((p) => p.ritualId == ritualId);
    
    if (progressIndex != -1) {
      _progress[progressIndex] = RitualProgressModel(
        ritualId: ritualId,
        status: status,
        startedAt: status == RitualStatus.active ? DateTime.now() : _progress[progressIndex].startedAt,
        completedAt: status == RitualStatus.completed ? DateTime.now() : null,
      );
    } else {
      _progress.add(RitualProgressModel(
        ritualId: ritualId,
        status: status,
        startedAt: status == RitualStatus.active ? DateTime.now() : null,
        completedAt: status == RitualStatus.completed ? DateTime.now() : null,
      ));
    }

    // Sync with API
    await _syncProgressWithAPI(ritualId, status);
  }

  // Data source methods - using existing repositories
  Future<void> _syncProgressWithAPI(String ritualId, RitualStatus status) async {
    // This can be extended to sync with the backend API later
    // For now, we'll keep it local
  }

  Future<void> _scheduleRitualNotifications() async {
    await _notificationService.scheduleRitualNotifications(_rituals);
  }

  Future<void> _scheduleDuaNotifications() async {
    await _notificationService.scheduleDuaNotifications(_duas);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    super.dispose();
  }
}
