import 'package:flutter/material.dart';

import '../models/rewards.dart';

/// 司書キャラクターのプレースホルダ表示。
/// 本格的なイラストに差し替えるまでは、衣装色を反映した簡易な姿で表示する。
class LibrarianAvatar extends StatelessWidget {
  const LibrarianAvatar({
    super.key,
    required this.costume,
    this.size = 150,
    this.onTap,
  });

  final RewardItem costume;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final robe = costume.colors.first;
    final accent =
        costume.colors.length > 1 ? costume.colors[1] : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.25,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 頭部
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: size * 0.42,
                  height: size * 0.42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7DDBE),
                    shape: BoxShape.circle,
                  ),
                ),
                // 髪
                Container(
                  width: size * 0.42,
                  height: size * 0.22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A3226),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(100),
                    ),
                  ),
                ),
                // 目
                Positioned(
                  top: size * 0.26,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dot(size * 0.035),
                      SizedBox(width: size * 0.12),
                      _dot(size * 0.035),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: size * 0.03),
            // 衣装
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size * 0.72,
                  height: size * 0.62,
                  decoration: BoxDecoration(
                    color: robe,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size * 0.36),
                      bottom: Radius.circular(size * 0.08),
                    ),
                  ),
                ),
                // 襟元
                Positioned(
                  top: size * 0.05,
                  child: Container(
                    width: size * 0.16,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(size * 0.04),
                    ),
                  ),
                ),
                // 手に持った本
                Positioned(
                  bottom: size * 0.08,
                  child: Icon(
                    Icons.menu_book,
                    size: size * 0.24,
                    color: accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(double d) => Container(
        width: d,
        height: d,
        decoration: const BoxDecoration(
          color: Color(0xFF33241B),
          shape: BoxShape.circle,
        ),
      );
}
