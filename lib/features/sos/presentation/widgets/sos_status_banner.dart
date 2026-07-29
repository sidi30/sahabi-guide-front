import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/sos_request.dart';
import '../providers/sos_provider.dart';
import 'sos_button.dart';

/// Bandeau persistant sur l'état du dernier SOS.
///
/// Persistant, et non un toast : un appel au secours en attente doit rester
/// sous les yeux du pèlerin jusqu'à ce qu'il sache si oui ou non son agence
/// l'a reçu.
class SosStatusBanner extends ConsumerWidget {
  const SosStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(sosQueueProvider).current;
    if (request == null) return const SizedBox.shrink();

    final t = AppLocalizations.of(context)!;
    final notifier = ref.read(sosQueueProvider.notifier);

    return Material(
      color: _background(request.status),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _leading(request.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _headline(t, request),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _detail(t, request),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ..._actions(t, notifier, request),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(
    AppLocalizations t,
    SosQueueNotifier notifier,
    SosRequest request,
  ) {
    switch (request.status) {
      case SosDeliveryStatus.sent:
        return [
          _action(t.common_ok, () => notifier.acknowledge(request.clientAlertId)),
        ];
      case SosDeliveryStatus.failed:
        return [
          _action(t.sos_retry, () => notifier.retry(request.clientAlertId)),
          _action(t.common_close,
              () => notifier.acknowledge(request.clientAlertId)),
        ];
      case SosDeliveryStatus.pending:
      case SosDeliveryStatus.sending:
        // Rien à décider : l'app réessaie. Aucun bouton qui laisserait croire
        // que le pèlerin doit (ou peut) faire quelque chose de plus.
        return const [];
    }
  }

  Widget _action(String label, VoidCallback onPressed) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _leading(SosDeliveryStatus status) {
    switch (status) {
      case SosDeliveryStatus.sending:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
      case SosDeliveryStatus.pending:
        return const Icon(Icons.schedule, color: Colors.white, size: 22);
      case SosDeliveryStatus.sent:
        return const Icon(Icons.check_circle, color: Colors.white, size: 22);
      case SosDeliveryStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.white, size: 22);
    }
  }

  Color _background(SosDeliveryStatus status) {
    switch (status) {
      case SosDeliveryStatus.sending:
      case SosDeliveryStatus.pending:
        return const Color(0xFF8A5300);
      case SosDeliveryStatus.sent:
        return const Color(0xFF1B5E20);
      case SosDeliveryStatus.failed:
        return kSosRed;
    }
  }

  String _headline(AppLocalizations t, SosRequest request) {
    switch (request.status) {
      case SosDeliveryStatus.sending:
        return t.sos_status_sending;
      case SosDeliveryStatus.pending:
        return t.sos_status_pending;
      case SosDeliveryStatus.sent:
        return t.sos_status_sent;
      case SosDeliveryStatus.failed:
        // Sans session valide, « réessayer » ne mène nulle part : dire
        // exactement ce qui manque.
        return request.requiresLogin
            ? t.sos_status_failed_auth
            : t.sos_status_failed;
    }
  }

  String _detail(AppLocalizations t, SosRequest request) {
    final position = _position(t, request.locationOrigin);
    switch (request.status) {
      case SosDeliveryStatus.sending:
        return position;
      case SosDeliveryStatus.pending:
        return request.attempts == 0
            ? position
            : '${t.sos_status_attempt(request.attempts)} · $position';
      case SosDeliveryStatus.sent:
        return position;
      case SosDeliveryStatus.failed:
        return request.lastError == null
            ? position
            : t.common_error_detail(request.lastError!);
    }
  }

  String _position(AppLocalizations t, SosLocationOrigin origin) {
    switch (origin) {
      case SosLocationOrigin.freshGps:
        return t.sos_position_gps;
      case SosLocationOrigin.lastKnownGps:
        return t.sos_position_last_known;
      case SosLocationOrigin.declaredPlace:
        return t.sos_position_declared;
      case SosLocationOrigin.none:
        return t.sos_position_none;
    }
  }
}
