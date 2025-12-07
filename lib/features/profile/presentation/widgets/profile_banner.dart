import 'package:flutter/material.dart';

/// Profile banner widget - gradient background with optional image upload
class ProfileBanner extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onUploadImage;

  const ProfileBanner({
    super.key,
    this.imageUrl,
    this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: imageUrl == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF9A56), // Orange
                  Color(0xFFFF6B9D), // Pink
                  Color(0xFFC86DD7), // Purple
                  Color(0xFF3023AE), // Deep Purple
                  Color(0xFF53A0FD), // Blue
                  Color(0xFF00D2FF), // Cyan
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
      child: onUploadImage != null
          ? Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: onUploadImage,
                    tooltip: 'Upload banner image',
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
