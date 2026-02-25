import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../providers/notifications_provider.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationsSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: ref.colors.primary,
        foregroundColor: ref.colors.textOnPrimary,
        automaticallyImplyLeading: true,
      ),
      body: notificationSettings.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: ref.colors.error),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(notificationsSettingsProvider),
                child: const Text('Reessayer'),
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
        // En-tete explicatif
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: ref.colors.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Gerez les notifications que vous souhaitez recevoir',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Notifications generales
        _buildSectionTitle(context, ref, 'Notifications Generales'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Toutes les notifications'),
                subtitle: const Text('Activer/desactiver toutes les notifications'),
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
                subtitle: const Text('Emettre un son lors de la reception'),
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
                subtitle: const Text('Vibrer lors de la reception'),
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
        _buildSectionTitle(context, ref, 'Types de Notifications'),
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
                secondary: Icon(Icons.emergency, color: ref.colors.error),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Rappels de priere'),
                subtitle: const Text('Notifications des heures de priere'),
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
                title: const Text('Alertes sante'),
                subtitle: const Text('Notifications liees a votre sante'),
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
                title: const Text('Mises a jour'),
                subtitle: const Text('Notifications de mises a jour de l\'application'),
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

        // Mode Ne Pas Deranger
        _buildSectionTitle(context, ref, 'Mode Silencieux'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Mode Ne Pas Deranger'),
                subtitle: Text(
                  settings.doNotDisturb
                      ? 'Active - Notifications silencieuses'
                      : 'Desactive - Notifications normales',
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

  Widget _buildSectionTitle(BuildContext context, WidgetRef ref, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: ref.colors.primary,
            ),
      ),
    );
  }
}
