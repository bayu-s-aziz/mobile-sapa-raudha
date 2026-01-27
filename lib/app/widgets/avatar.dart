import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sapa_raudha/app/utils/url_utils.dart';

class Avatar extends StatelessWidget {
  final String? photoUrl; // server-stored path or URL
  final String? localFilePath; // local file path for preview (e.g., XFile.path)
  final String? name; // used to generate initials if no image
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const Avatar({
    super.key,
    this.photoUrl,
    this.localFilePath,
    this.name,
    this.radius = 24.0,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  String _initials() {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = UrlUtils.normalizeUrl(photoUrl);
    ImageProvider? provider;
    if (localFilePath != null && localFilePath!.isNotEmpty) {
      provider = FileImage(File(localFilePath!));
    } else if (normalized != null) {
      provider = NetworkImage(normalized);
    }

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: provider != null
            ? Image(
                image: provider,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
                // Optionally, show a small progress indicator while loading
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: radius / 2,
                      height: radius / 2,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
