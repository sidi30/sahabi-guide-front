import 'package:flutter/material.dart';

/// Effet « shimmer » maison (aucune dépendance externe) : un dégradé balaie en
/// boucle les [SkeletonBox] descendants pour matérialiser le chargement, dans
/// l'esprit des animations du splash. S'adapte au thème clair/sombre.
///
/// Un seul contrôleur d'animation par écran-squelette (phase partagée entre
/// tous les [SkeletonBox] enfants), donc peu coûteux.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2D34) : const Color(0xFFE4E7EC);
    final highlight = isDark ? const Color(0xFF3A3F47) : const Color(0xFFF4F6F8);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlidingGradient(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Fait glisser le dégradé de gauche (-largeur) à droite (+largeur).
class _SlidingGradient extends GradientTransform {
  final double slidePercent;

  const _SlidingGradient(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}

/// Liste-squelette générique (carte + lignes) pour les onglets à liste
/// (rituels, alertes…). Déjà enveloppée dans un [Shimmer].
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    const SkeletonBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloc opaque arrondi servant de « placeholder » sous un [Shimmer].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // La couleur exacte importe peu : le ShaderMask du [Shimmer] la
        // recouvre. On garde un gris neutre comme repli hors shimmer.
        color: const Color(0xFFE4E7EC),
        borderRadius: borderRadius,
      ),
    );
  }
}
