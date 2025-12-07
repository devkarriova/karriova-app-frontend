import 'package:flutter/material.dart';

/// Profile avatar widget - circular avatar with gradient background and initials
class ProfileAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final VoidCallback? onUploadImage;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.onUploadImage,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: imageUrl == null
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC86DD7), // Purple
                    Color(0xFFFF6B9D), // Pink
                  ],
                )
              : null,
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null
            ? Center(
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
