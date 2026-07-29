import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';

/// Compte à rebours avant l'envoi effectif d'un SOS.
///
/// Un appui suffit à ouvrir cet écran ; l'envoi n'a lieu qu'à la fin du
/// décompte. C'est ce qui protège des déclenchements accidentels sans exiger
/// d'un pèlerin paniqué qu'il maintienne un appui long ou lise une
/// confirmation.
class SosCountdownSheet extends StatefulWidget {
  const SosCountdownSheet({
    super.key,
    required this.onElapsed,
    required this.onCancelled,
    this.seconds = defaultSeconds,
  });

  static const int defaultSeconds = 5;

  /// Le décompte est allé à son terme : c'est l'ordre d'envoi.
  final VoidCallback onElapsed;

  /// Le pèlerin a annulé : rien ne doit partir.
  final VoidCallback onCancelled;

  final int seconds;

  @override
  State<SosCountdownSheet> createState() => _SosCountdownSheetState();
}

class _SosCountdownSheetState extends State<SosCountdownSheet> {
  static const Color _red = Color(0xFFB3261E);

  late int _remaining = widget.seconds;
  Timer? _timer;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (_settled) return;
    final next = _remaining - 1;
    if (next <= 0) {
      _settle(widget.onElapsed);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _remaining = next);
  }

  void _cancel() => _settle(widget.onCancelled);

  /// Le décompte ne se dénoue qu'une fois : pas d'envoi après une annulation,
  /// pas d'annulation après un envoi.
  void _settle(VoidCallback action) {
    if (_settled) return;
    _settled = true;
    _timer?.cancel();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopScope(
      // Le retour système annule : il ne doit jamais valider un envoi par
      // inadvertance, mais il ne doit pas non plus laisser l'écran coincé.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Material(
        color: _red,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sos_rounded, color: Colors.white, size: 72),
                const SizedBox(height: 16),
                Text(
                  t.sos_countdown_title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  label: t.sos_countdown_semantics(_remaining),
                  child: ExcludeSemantics(
                    child: Text(
                      '$_remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.sos_countdown_hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Semantics(
                  button: true,
                  label: t.sos_cancel,
                  child: SizedBox(
                    width: double.infinity,
                    height: 88,
                    child: ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _red,
                        textStyle: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(t.sos_cancel),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
