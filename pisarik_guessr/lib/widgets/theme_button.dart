import 'package:flutter/material.dart';
import 'package:pisarik_guessr/models/game_theme.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final GameTheme theme;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = theme == GameTheme.brawlStars ? const Color(0xFFFFE353) : const Color(0xFF911105);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth / 1.5;
        return Material(
          color: selected ? color.withOpacity(0.4) : const Color(0xFF2E2523),
          borderRadius: BorderRadius.circular(40),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(40),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: maxWidth * 0.4,
                    height: maxWidth >= 800 ? maxWidth * 0.25 : maxWidth * 0.5,
                    child: Image.asset(
                      theme == GameTheme.brawlStars ? 'assets/games/brawl_stars.png' : 'assets/games/dota2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      theme.displayName,
                      style: TextStyle(fontSize: maxWidth * 0.08, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (selected) Icon(Icons.check_circle, color: color, size: maxWidth * 0.08),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}