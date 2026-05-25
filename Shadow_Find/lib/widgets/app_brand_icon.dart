import 'package:flutter/material.dart';

class AppBrandIcon extends StatelessWidget {
  final double size;
  final double borderRadius;
  final BoxBorder? border;
  final Color? backgroundColor;

  const AppBrandIcon({
    super.key,
    this.size = 40,
    this.borderRadius = 12,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/smallIcon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
