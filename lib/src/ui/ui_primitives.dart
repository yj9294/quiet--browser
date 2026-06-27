import 'dart:io';

import 'package:flutter/material.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFF2E6E2),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142A1624),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.backgroundColor = const Color(0xFFFFF0EB),
    this.foregroundColor = const Color(0xFFD06361),
    this.icon,
    this.compact = false,
    this.expand = false,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? icon;
  final bool compact;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 6)],
          if (expand)
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 72,
          right: -24,
          child: _Orb(size: 180, color: const Color(0xFFFFE1DB)),
        ),
        Positioned(
          bottom: 96,
          left: -40,
          child: _Orb(size: 170, color: const Color(0xFFFFF0DB)),
        ),
        child,
      ],
    );
  }
}

class SiteAvatar extends StatelessWidget {
  const SiteAvatar({
    super.key,
    required this.url,
    this.iconPath = '',
    this.size = 42,
    this.backgroundColor = const Color(0xFFFFF1EE),
    this.foregroundColor = const Color(0xFFFF6B6B),
  });

  final String url;
  final String iconPath;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.38);
    final file = iconPath.isEmpty ? null : File(iconPath);
    final hasLocalIcon = file != null && file.existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: hasLocalIcon
          ? Padding(
              padding: EdgeInsets.all(size * 0.18),
              child: Image.file(
                file,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _FallbackSiteGlyph(
                  url: url,
                  foregroundColor: foregroundColor,
                ),
              ),
            )
          : _FallbackSiteGlyph(url: url, foregroundColor: foregroundColor),
    );
  }
}

class _FallbackSiteGlyph extends StatelessWidget {
  const _FallbackSiteGlyph({required this.url, required this.foregroundColor});

  final String url;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final host = Uri.tryParse(url)?.host ?? '';
    final initial = host.isEmpty ? '?' : host.substring(0, 1).toUpperCase();
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}
