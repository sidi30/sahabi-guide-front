import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';

class ConnectivityPage extends ConsumerStatefulWidget {
  const ConnectivityPage({super.key});

  @override
  ConsumerState<ConnectivityPage> createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends ConsumerState<ConnectivityPage> {
  bool _isConnected = true;
  bool _autoSync = true;
  bool _wifiOnly = false;
  DateTime _lastSync = DateTime.now().subtract(const Duration(minutes: 15));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkConnection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (_isConnected ? Colors.green : Colors.red)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _isConnected ? Icons.wifi : Icons.wifi_off,
                            color: _isConnected ? Colors.green : Colors.red,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isConnected ? 'Connecté' : 'Déconnecté',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _isConnected
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                              ),
                              Text(
                                _isConnected
                                    ? 'Connexion Internet active'
                                    : 'Aucune connexion Internet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isConnected) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.signal_wifi_4_bar,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Signal fort - WiFi domestique',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sync Status
            Text(
              'Synchronisation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dernière synchronisation',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _formatLastSync(_lastSync),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isConnected ? _syncNow : null,
                        icon: const Icon(Icons.sync),
                        label: const Text('Synchroniser maintenant'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sync Settings
            Text(
              'Paramètres de synchronisation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Synchronisation automatique'),
                    subtitle:
                        const Text('Synchroniser automatiquement les données'),
                    value: _autoSync,
                    onChanged: (value) {
                      setState(() {
                        _autoSync = value;
                      });
                    },
                    secondary: const Icon(Icons.sync),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('WiFi uniquement'),
                    subtitle: const Text('Synchroniser seulement en WiFi'),
                    value: _wifiOnly,
                    onChanged: (value) {
                      setState(() {
                        _wifiOnly = value;
                      });
                    },
                    secondary: const Icon(Icons.wifi),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Usage
            Text(
              'Utilisation des données',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDataUsageRow('Ce mois', '45.2 MB', '2.1 MB'),
                    const SizedBox(height: 12),
                    _buildDataUsageRow('Cette semaine', '12.8 MB', '0.6 MB'),
                    const SizedBox(height: 12),
                    _buildDataUsageRow('Aujourd\'hui', '2.3 MB', '0.1 MB'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Offline Features
            Text(
              'Fonctionnalités hors ligne',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.download_done,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: const Text('Rituels téléchargés'),
                    subtitle: const Text('25 rituels disponibles hors ligne'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Show downloaded rituals
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.audiotrack,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    title: const Text('Audio téléchargés'),
                    subtitle: const Text('18 fichiers audio (156 MB)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Show downloaded audio
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Network Diagnostics
            Text(
              'Diagnostics réseau',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDiagnosticRow('Ping', '23 ms', Colors.green),
                    const SizedBox(height: 12),
                    _buildDiagnosticRow(
                        'Débit descendant', '45.2 Mbps', Colors.green),
                    const SizedBox(height: 12),
                    _buildDiagnosticRow(
                        'Débit montant', '12.8 Mbps', Colors.green),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _runDiagnostics,
                        icon: const Icon(Icons.speed),
                        label: const Text('Tester la connexion'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUsageRow(String period, String download, String upload) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          period,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  download,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Téléchargé',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  upload,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Envoyé',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiagnosticRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  void _checkConnection() {
    // TODO: Implement actual connection check
    setState(() {
      _isConnected = !_isConnected;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isConnected ? 'Connexion rétablie' : 'Connexion perdue'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
      ),
    );
  }

  void _syncNow() {
    // TODO: Implement sync
    setState(() {
      _lastSync = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Synchronisation terminée'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _runDiagnostics() {
    // TODO: Implement network diagnostics
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Test de la connexion en cours...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test de connexion terminé'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  String _formatLastSync(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays} jour(s)';
    }
  }
}
