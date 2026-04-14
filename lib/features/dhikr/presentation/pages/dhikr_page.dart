import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Data model for a single dhikr type
class _DhikrItem {
  final String arabic;
  final String transliteration;
  final String translation;
  final int target;

  const _DhikrItem({
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.target,
  });
}

class DhikrPage extends StatefulWidget {
  const DhikrPage({super.key});

  @override
  State<DhikrPage> createState() => _DhikrPageState();
}

class _DhikrPageState extends State<DhikrPage> with TickerProviderStateMixin {
  // ── Dhikr definitions ──
  static const _dhikrList = [
    _DhikrItem(
      arabic: 'سبحان الله',
      transliteration: 'SubhanAllah',
      translation: 'Glory be to Allah',
      target: 33,
    ),
    _DhikrItem(
      arabic: 'الحمد لله',
      transliteration: 'Alhamdulillah',
      translation: 'Praise be to Allah',
      target: 33,
    ),
    _DhikrItem(
      arabic: 'الله أكبر',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      target: 34,
    ),
  ];

  // ── State ──
  int _currentDhikrIndex = 0;
  List<int> _counts = [0, 0, 0];
  int _tasbeehToday = 0;
  int _streak = 0;
  String _lastTasbeehDate = '';

  // ── Animations ──
  late AnimationController _tapAnimController;
  late Animation<double> _tapScale;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationOpacity;

  bool _showCelebration = false;

  // ── Prefs keys ──
  static const _keyCount0 = 'dhikr_count_0';
  static const _keyCount1 = 'dhikr_count_1';
  static const _keyCount2 = 'dhikr_count_2';
  static const _keyCurrentIndex = 'dhikr_current_index';
  static const _keyTasbeehToday = 'dhikr_tasbeeh_today';
  static const _keyStreak = 'dhikr_streak';
  static const _keyLastDate = 'dhikr_last_date';

  @override
  void initState() {
    super.initState();

    _tapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapAnimController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrationOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut),
    );
    _celebrationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showCelebration = false);
      }
    });

    _loadState();
  }

  @override
  void dispose() {
    _tapAnimController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  // ── Persistence ──

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    final today = _todayKey();
    final savedDate = prefs.getString(_keyLastDate) ?? '';

    int streak = prefs.getInt(_keyStreak) ?? 0;
    int tasbeehToday = prefs.getInt(_keyTasbeehToday) ?? 0;
    List<int> counts = [
      prefs.getInt(_keyCount0) ?? 0,
      prefs.getInt(_keyCount1) ?? 0,
      prefs.getInt(_keyCount2) ?? 0,
    ];
    int currentIndex = prefs.getInt(_keyCurrentIndex) ?? 0;

    // If last saved date is not today, reset daily counters
    if (savedDate != today) {
      // Check if yesterday to keep streak
      final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
      if (savedDate != yesterday) {
        // Streak broken (unless first time)
        if (savedDate.isNotEmpty) streak = 0;
      }
      tasbeehToday = 0;
      counts = [0, 0, 0];
      currentIndex = 0;
    }

    setState(() {
      _counts = counts;
      _currentDhikrIndex = currentIndex.clamp(0, 2);
      _tasbeehToday = tasbeehToday;
      _streak = streak;
      _lastTasbeehDate = savedDate;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCount0, _counts[0]);
    await prefs.setInt(_keyCount1, _counts[1]);
    await prefs.setInt(_keyCount2, _counts[2]);
    await prefs.setInt(_keyCurrentIndex, _currentDhikrIndex);
    await prefs.setInt(_keyTasbeehToday, _tasbeehToday);
    await prefs.setInt(_keyStreak, _streak);
    await prefs.setString(_keyLastDate, _lastTasbeehDate);
  }

  String _todayKey() => _dateKey(DateTime.now());
  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Tap logic ──

  void _onTap() {
    HapticFeedback.lightImpact();

    // Tap animation
    _tapAnimController.forward().then((_) => _tapAnimController.reverse());

    final item = _dhikrList[_currentDhikrIndex];

    setState(() {
      _counts[_currentDhikrIndex]++;

      // Auto-advance when current dhikr target reached
      if (_counts[_currentDhikrIndex] >= item.target) {
        if (_currentDhikrIndex < 2) {
          // Move to next dhikr
          _currentDhikrIndex++;
        } else {
          // All three completed = 1 tasbeeh
          _completeTasbeeh();
        }
      }
    });

    _saveState();
  }

  void _completeTasbeeh() {
    _tasbeehToday++;

    // Update streak
    final today = _todayKey();
    if (_lastTasbeehDate != today) {
      _streak++;
      _lastTasbeehDate = today;
    }

    // Show celebration
    _showCelebration = true;
    _celebrationController.reset();
    _celebrationController.forward();

    // Reset counts after a brief moment (the celebration plays)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _counts = [0, 0, 0];
          _currentDhikrIndex = 0;
        });
        _saveState();
      }
    });
  }

  void _onReset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counts = [0, 0, 0];
      _currentDhikrIndex = 0;
    });
    _saveState();
  }

  // ── Computed helpers ──

  int get _totalCount => _counts[0] + _counts[1] + _counts[2];
  int get _totalTarget =>
      _dhikrList.fold<int>(0, (sum, item) => sum + item.target); // 100

  double get _currentProgress {
    final item = _dhikrList[_currentDhikrIndex];
    return _counts[_currentDhikrIndex] / item.target;
  }

  // ── Colors ──

  static const _islamicGreen = Color(0xFF1B5E20);
  static const _islamicGreenLight = Color(0xFF4CAF50);
  static const _islamicGold = Color(0xFFD4A843);

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final item = _dhikrList[_currentDhikrIndex];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F0);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : _islamicGreen;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Dhikr'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _onReset,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Stats row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    context,
                    label: 'Tasbeeh',
                    value: '$_tasbeehToday',
                    icon: Icons.auto_awesome,
                    color: _islamicGold,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  _buildStat(
                    context,
                    label: 'Total',
                    value: '$_totalCount / $_totalTarget',
                    icon: Icons.tag,
                    color: _islamicGreenLight,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  _buildStat(
                    context,
                    label: 'Streak',
                    value: '$_streak j',
                    icon: Icons.local_fire_department,
                    color: Colors.deepOrange,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Dhikr selector chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_dhikrList.length, (i) {
                  final d = _dhikrList[i];
                  final isActive = i == _currentDhikrIndex;
                  final isCompleted = _counts[i] >= d.target;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _currentDhikrIndex = i);
                        _saveState();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? _islamicGold.withValues(alpha: 0.15)
                              : isActive
                                  ? _islamicGreen.withValues(alpha: 0.12)
                                  : cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted
                                ? _islamicGold
                                : isActive
                                    ? _islamicGreen
                                    : Colors.grey.shade300,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCompleted)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child:
                                    Icon(Icons.check_circle, size: 16, color: _islamicGold),
                              ),
                            Text(
                              d.transliteration,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isActive ? FontWeight.bold : FontWeight.w500,
                                color: isCompleted
                                    ? _islamicGold
                                    : isActive
                                        ? _islamicGreen
                                        : subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Main tap area ──
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tap circle with progress ring
                    ScaleTransition(
                      scale: _tapScale,
                      child: GestureDetector(
                        onTap: _onTap,
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: CustomPaint(
                            painter: _ProgressRingPainter(
                              progress: _currentProgress,
                              ringColor: _islamicGreen,
                              trackColor: isDark
                                  ? Colors.white12
                                  : _islamicGreen.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: isDark
                                        ? [
                                            const Color(0xFF2E2E2E),
                                            const Color(0xFF1A1A1A),
                                          ]
                                        : [
                                            Colors.white,
                                            const Color(0xFFF0EDE5),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _islamicGreen.withValues(alpha: 0.15),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Arabic text
                                    Text(
                                      item.arabic,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Transliteration
                                    Text(
                                      item.transliteration,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: subtextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Counter
                                    Text(
                                      '${_counts[_currentDhikrIndex]}',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: _islamicGreen,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      '/ ${item.target}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Celebration overlay
                    if (_showCelebration)
                      FadeTransition(
                        opacity: _celebrationOpacity,
                        child: _CelebrationOverlay(
                          controller: _celebrationController,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Translation ──
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item.translation,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: subtextColor,
                ),
              ),
            ),

            // ── Tap hint ──
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Tap the circle to count',
                style: TextStyle(
                  fontSize: 12,
                  color: subtextColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: subtextColor),
          ),
        ],
      ),
    );
  }
}

// ── Progress ring painter ──

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start at top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ── Celebration overlay ──

class _CelebrationOverlay extends StatelessWidget {
  final AnimationController controller;

  const _CelebrationOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding ring
              Transform.scale(
                scale: 1.0 + controller.value * 1.5,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _DhikrPageState._islamicGold
                          .withValues(alpha: (1 - controller.value) * 0.6),
                      width: 3,
                    ),
                  ),
                ),
              ),
              // Star particles
              for (int i = 0; i < 8; i++)
                Transform.translate(
                  offset: Offset(
                    cos(i * pi / 4) * 80 * controller.value,
                    sin(i * pi / 4) * 80 * controller.value,
                  ),
                  child: Opacity(
                    opacity: (1 - controller.value).clamp(0.0, 1.0),
                    child: Icon(
                      Icons.star,
                      size: 16 + (i % 3) * 4,
                      color: i.isEven
                          ? _DhikrPageState._islamicGold
                          : _DhikrPageState._islamicGreenLight,
                    ),
                  ),
                ),
              // Center text
              Opacity(
                opacity: (1 - controller.value * 1.5).clamp(0.0, 1.0),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: _DhikrPageState._islamicGold, size: 36),
                    SizedBox(height: 4),
                    Text(
                      'Tasbeeh!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _DhikrPageState._islamicGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
