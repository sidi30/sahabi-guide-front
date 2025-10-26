import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../core/theme/theme.dart';
import '../providers/notifications_provider.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationsSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // ✅ Bouton retour automatique
      ),
      body: notificationSettings.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(notificationsSettingsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, NotificationSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // En-tête explicatif
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Gérez les notifications que vous souhaitez recevoir',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Notifications générales
        _buildSectionTitle(context, 'Notifications Générales'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Toutes les notifications'),
                subtitle: const Text('Activer/désactiver toutes les notifications'),
                value: settings.allEnabled,
                onChanged: (value) {
                  ref.read(notificationsSettingsProvider.notifier).toggleAllNotifications(value);
                },
                secondary: const Icon(Icons.notifications),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Notifications push'),
                subtitle: const Text('Recevoir des notifications sur votre appareil'),
                value: settings.pushEnabled,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).togglePushNotifications(value);
                      }
                    : null,
                secondary: const Icon(Icons.push_pin),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Sons'),
                subtitle: const Text('Émettre un son lors de la réception'),
                value: settings.soundEnabled,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleSound(value);
                      }
                    : null,
                secondary: const Icon(Icons.volume_up),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Vibrations'),
                subtitle: const Text('Vibrer lors de la réception'),
                value: settings.vibrationEnabled,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleVibration(value);
                      }
                    : null,
                secondary: const Icon(Icons.vibration),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Types de notifications
        _buildSectionTitle(context, 'Types de Notifications'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Alertes d\'urgence'),
                subtitle: const Text('Alertes importantes et urgentes'),
                value: settings.emergencyAlerts,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleEmergencyAlerts(value);
                      }
                    : null,
                secondary: const Icon(Icons.emergency, color: Colors.red),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Rappels de prière'),
                subtitle: const Text('Notifications des heures de prière'),
                value: settings.prayerReminders,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).togglePrayerReminders(value);
                      }
                    : null,
                secondary: const Icon(Icons.access_time),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Rappels de rituels'),
                subtitle: const Text('Notifications pour les rituels du Hajj'),
                value: settings.ritualReminders,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleRitualReminders(value);
                      }
                    : null,
                secondary: const Icon(Icons.event),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Messages du groupe'),
                subtitle: const Text('Notifications des messages de votre groupe'),
                value: settings.groupMessages,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleGroupMessages(value);
                      }
                    : null,
                secondary: const Icon(Icons.group),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Alertes santé'),
                subtitle: const Text('Notifications liées à votre santé'),
                value: settings.healthAlerts,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleHealthAlerts(value);
                      }
                    : null,
                secondary: const Icon(Icons.local_hospital),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Mises à jour'),
                subtitle: const Text('Notifications de mises à jour de l\'application'),
                value: settings.appUpdates,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleAppUpdates(value);
                      }
                    : null,
                secondary: const Icon(Icons.system_update),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Mode Ne Pas Déranger
        _buildSectionTitle(context, 'Mode Silencieux'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Mode Ne Pas Déranger'),
                subtitle: Text(
                  settings.doNotDisturb
                      ? 'Activé - Notifications silencieuses'
                      : 'Désactivé - Notifications normales',
                ),
                value: settings.doNotDisturb,
                onChanged: settings.allEnabled
                    ? (value) {
                        ref.read(notificationsSettingsProvider.notifier).toggleDoNotDisturb(value);
                      }
                    : null,
                secondary: Icon(
                  settings.doNotDisturb ? Icons.do_not_disturb_on : Icons.do_not_disturb_off,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }
}

