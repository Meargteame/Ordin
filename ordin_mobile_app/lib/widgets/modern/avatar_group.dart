import 'package:flutter/material.dart';
import '../../theme/modern_dark_colors.dart';
import '../../theme/modern_dark_spacing.dart';

/// Avatar Group Widget - displays overlapping avatars
/// Matches reference design pixel-perfect
class AvatarGroup extends StatelessWidget {
  final List<String> avatarUrls;
  final int maxVisible;
  final double size;
  final double borderWidth;
  
  const AvatarGroup({
    super.key,
    required this.avatarUrls,
    this.maxVisible = 4,
    this.size = ModernDarkSpacing.avatarMd,
    this.borderWidth = 2.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final visibleCount = avatarUrls.length > maxVisible ? maxVisible : avatarUrls.length;
    final remainingCount = avatarUrls.length - maxVisible;
    
    return SizedBox(
      height: size,
      child: Stack(
        children: [
          // Visible avatars
          ...List.generate(visibleCount, (index) {
            return Positioned(
              left: index * (size + ModernDarkSpacing.avatarOverlap),
              child: _buildAvatar(
                avatarUrls[index],
                size,
                borderWidth,
              ),
            );
          }),
          
          // +N indicator if more avatars
          if (remainingCount > 0)
            Positioned(
              left: visibleCount * (size + ModernDarkSpacing.avatarOverlap),
              child: _buildCountIndicator(
                remainingCount,
                size,
                borderWidth,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAvatar(String url, double size, double borderWidth) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ModernDarkColors.cardDark,
          width: borderWidth,
        ),
        image: url.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
        color: url.isEmpty ? ModernDarkColors.cardElevated : null,
      ),
      child: url.isEmpty
          ? Icon(
              Icons.person,
              size: size * 0.5,
              color: ModernDarkColors.textSecondary,
            )
          : null,
    );
  }
  
  Widget _buildCountIndicator(int count, double size, double borderWidth) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ModernDarkColors.cardDark,
          width: borderWidth,
        ),
        color: ModernDarkColors.cardElevated,
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: ModernDarkColors.textPrimary,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
