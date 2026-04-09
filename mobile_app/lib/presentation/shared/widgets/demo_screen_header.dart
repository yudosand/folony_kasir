import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class DemoScreenHeader extends StatelessWidget {
  const DemoScreenHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.height = 92,
    this.titleStyle,
    this.badgeLabel,
    this.backgroundColor = AppColors.primary,
    this.padding = const EdgeInsets.fromLTRB(20, 10, 20, 10),
    this.boxShadow,
    this.border,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final TextStyle? titleStyle;
  final String? badgeLabel;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: boxShadow,
        border: border,
      ),
      padding: padding,
      child: Stack(
        children: [
          if (leading != null)
            Align(
              alignment: Alignment.centerLeft,
              child: leading!,
            ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeLabel != null && badgeLabel!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel!,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    title,
                    style: titleStyle ??
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

class DemoCircleIconButton extends StatelessWidget {
  const DemoCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primaryDark,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }
}
