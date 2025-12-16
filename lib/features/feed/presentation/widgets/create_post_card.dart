import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

/// Create post card widget - allows users to create a new post
class CreatePostCard extends StatefulWidget {
  final String userInitials;
  final String? userImageUrl;
  final Function(String content, List<File> images)? onPostTap;

  const CreatePostCard({
    super.key,
    required this.userInitials,
    this.userImageUrl,
    this.onPostTap,
  });

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  late final _HashtagTextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _textController = _HashtagTextEditingController();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasContent) {
      setState(() {
        _hasContent = hasText;
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFiles.isNotEmpty) {
        // Limit to 10 images total
        final remainingSlots = 10 - _selectedImages.length;
        final filesToAdd = pickedFiles.take(remainingSlots);

        setState(() {
          _selectedImages.addAll(filesToAdd.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitPost() {
    final content = _textController.text.trim();

    if (content.isEmpty && _selectedImages.isEmpty) {
      return; // Don't submit empty posts
    }

    if (widget.onPostTap != null) {
      widget.onPostTap!(content, List.from(_selectedImages));
      _textController.clear();
      setState(() {
        _selectedImages.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field with avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  backgroundImage: widget.userImageUrl != null && widget.userImageUrl!.isNotEmpty
                      ? NetworkImage(widget.userImageUrl!)
                      : null,
                  child: widget.userImageUrl == null || widget.userImageUrl!.isEmpty
                      ? Text(
                          widget.userInitials.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Input field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    minLines: 1,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1a1a1a),
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts, achievements, or questions...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Selected images preview
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImagePreview(),
            ],

            const SizedBox(height: 12),
            // Action buttons row - aligned with text input
            Padding(
              padding: const EdgeInsets.only(left: 60), // Avatar (48) + spacing (12) = 60
              child: Row(
                children: [
                  _ActionButton(
                    icon: Icons.image_outlined,
                    onTap: _pickImages,
                    badge: _selectedImages.isNotEmpty ? '${_selectedImages.length}' : null,
                  ),
                  const Spacer(),
                  // Post button - icon only without background
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: (_hasContent || _selectedImages.isNotEmpty)
                          ? _submitPost
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: (_hasContent || _selectedImages.isNotEmpty)
                            ? AppColors.primary
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                // Image preview
                ClipRRectContainer(
                  height: 100,
                  width: 100,
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
                // Remove button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper widget for ClipRRect
class ClipRRectContainer extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Widget child;

  const ClipRRectContainer({
    super.key,
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: width,
        child: child,
      ),
    );
  }
}

/// Action button widget for create post options (icon only)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? badge;

  const _ActionButton({
    required this.icon,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            if (badge != null)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom TextEditingController that highlights hashtags
class _HashtagTextEditingController extends TextEditingController {
  final RegExp _hashtagRegex = RegExp(r'#\w+');

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final String textValue = text;

    if (textValue.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    int lastMatchEnd = 0;

    for (final match in _hashtagRegex.allMatches(textValue)) {
      // Add normal text before hashtag
      if (match.start > lastMatchEnd) {
        children.add(
          TextSpan(
            text: textValue.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      // Add hashtag with primary color and bold
      children.add(
        TextSpan(
          text: match.group(0),
          style: style?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < textValue.length) {
      children.add(
        TextSpan(
          text: textValue.substring(lastMatchEnd),
          style: style,
        ),
      );
    }

    return TextSpan(style: style, children: children);
  }
}
