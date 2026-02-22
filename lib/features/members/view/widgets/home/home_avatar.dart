import 'package:flutter/material.dart';

class HomeAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? memberNumber;
  final double radius;

  const HomeAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.memberNumber,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(name);
    final assetPath = memberNumber != null
        ? 'assets/${memberNumber!}.jpg'
        : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
      child: ClipOval(child: _buildImageOrFallback(initials, assetPath)),
    );
  }

  Widget _buildImageOrFallback(String initials, String? assetPath) {
    // 1️⃣ prioridade: imagem remota
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _assetOrInitials(initials, assetPath);
        },
      );
    }

    // 2️⃣ asset local
    return _assetOrInitials(initials, assetPath);
  }

  Widget _assetOrInitials(String initials, String? assetPath) {
    if (assetPath == null) {
      return _Initials(initials: initials);
    }

    return Image.asset(
      assetPath,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _Initials(initials: initials);
      },
    );
  }

  String _initials(String s) {
    final parts = s
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    final first = parts.first.characters.take(1).toString();
    final last = parts.length > 1
        ? parts.last.characters.take(1).toString()
        : '';

    return (first + last).toUpperCase();
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials({required this.initials});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        initials,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}