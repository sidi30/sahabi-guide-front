import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/models/dua_model.dart';

class DuaCard extends StatelessWidget {
  final DuaModel dua;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const DuaCard({
    super.key,
    required this.dua,
    required this.isSelected,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec type et favori
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: dua.getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          dua.getTypeIcon(),
                          size: 14,
                          color: dua.getTypeColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dua.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: dua.getTypeColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      dua.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: dua.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavorite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Texte arabe
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    dua.arabicText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.8,
                      color: Color(0xFF1a5f3f),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Traduction française
              Text(
                dua.translation,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              // Footer avec audio et durée
              Row(
                children: [
                  if (dua.audioPath.isNotEmpty) ...[
                    Icon(
                      isSelected ? Icons.pause_circle : Icons.play_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dua.getFormattedDuration(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EN LECTURE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}













