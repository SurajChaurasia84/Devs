import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final double size;
  final bool isDark;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 40,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.startsWith('http') || avatarUrl.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Icon(
      Iconsax.profile_circle5,
      size: size,
      color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
    );
  }
}
