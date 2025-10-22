import 'package:flutter/material.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/rituals_repository_impl_with_sync.dart';
import '../../domain/repositories/rituals_repository.dart';

/// Widget pour afficher l'état de synchronisation et du cache
/// Utile pour le débogage et pour informer l'utilisateur
class RitualsSyncStatusWidget extends StatefulWidget {
  const RitualsSyncStatusWidget({super.key});

  @override
  State<RitualsSyncStatusWidget> createState() => _RitualsSyncStatusWidgetState();
}

class _RitualsSyncStatusWidgetState extends State<RitualsSyncStatusWidget> {
  final _hiveCacheService = sl<HiveCacheService>();
  final _connectivityService = sl<ConnectivityService>();
  final _repository = sl<RitualsRepository>() as RitualsRepositoryImplWithSync;

  Map<String, dynamic>? _cacheStats;
  bool _isConnected = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _listenToConnectivity();
  }

  Future<void> _loadStats() async {
    final stats = await _hiveCacheService.getCacheStats();
    setState(() {
      _cacheStats = stats;
    });
  }

  void _listenToConnectivity() {
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
    
    // État initial
    setState(() {
      _isConnected = _connectivityService.isConnected;
    });
  }

  Future<void> _manualSync() async {
    if (_isSyncing) return;
    
    setState(() {
      _isSyncing = true;
    });

    try {
      await _repository.syncAll();
      await _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation réussie'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de synchronisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer le cache'),
        content: const Text('Êtes-vous sûr de vouloir effacer tout le cache ? Cette action nécessitera une nouvelle synchronisation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _hiveCacheService.clearAll();
      await _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache effacé'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'En ligne' : 'Hors ligne',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const Divider(height: 24),
            
            // Statistiques des rituels
            if (_cacheStats != null) ...[
              _buildStatRow(
                'Rituels en cache',
                '${_cacheStats!['rituals']?['count'] ?? 0}',
                Icons.mosque,
              ),
              _buildStatRow(
                'Dernière mise à jour',
                _formatDateTime(_cacheStats!['rituals']?['lastUpdate']),
                Icons.update,
              ),
              _buildStatRow(
                'Version du contenu',
                '${_cacheStats!['rituals']?['contentVersion'] ?? 'N/A'}',
                Icons.numbers,
              ),
              _buildStatRow(
                'Cache valide',
                _cacheStats!['rituals']?['isValid'] == true ? 'Oui' : 'Non',
                _cacheStats!['rituals']?['isValid'] == true 
                    ? Icons.check_circle 
                    : Icons.warning,
                color: _cacheStats!['rituals']?['isValid'] == true 
                    ? Colors.green 
                    : Colors.orange,
              ),
              const SizedBox(height: 8),
              
              // Statistiques des duas
              _buildStatRow(
                'Duas en cache',
                '${_cacheStats!['duas']?['count'] ?? 0}',
                Icons.book,
              ),
              _buildStatRow(
                'Cache duas valide',
                _cacheStats!['duas']?['isValid'] == true ? 'Oui' : 'Non',
                _cacheStats!['duas']?['isValid'] == true 
                    ? Icons.check_circle 
                    : Icons.warning,
                color: _cacheStats!['duas']?['isValid'] == true 
                    ? Colors.green 
                    : Colors.orange,
              ),
            ],
            
            const Divider(height: 24),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSyncing ? null : _manualSync,
                  icon: const Icon(Icons.sync),
                  label: const Text('Synchroniser'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Effacer cache'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.toString().isEmpty) {
      return 'Jamais';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeStr.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inHours < 1) {
        return 'Il y a ${difference.inMinutes} min';
      } else if (difference.inDays < 1) {
        return 'Il y a ${difference.inHours} h';
      } else {
        return 'Il y a ${difference.inDays} j';
      }
    } catch (e) {
      return 'Invalide';
    }
  }
}

