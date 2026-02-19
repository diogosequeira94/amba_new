import 'dart:io';

import 'package:amba_new/models/member.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// opcional:
// import 'package:image_cropper/image_cropper.dart';

class ClickableAvatar extends StatelessWidget {
  final Member? member;
  final File? localPhoto;

  /// Callback quando o utilizador escolhe uma foto (já processada).
  final ValueChanged<File>? onPhotoPicked;

  /// Callback quando o utilizador remove a foto.
  final VoidCallback? onRemovePhoto;

  /// Desativa interação (ex: durante submit)
  final bool enabled;

  const ClickableAvatar({
    super.key,
    required this.member,
    required this.localPhoto,
    required this.onPhotoPicked,
    required this.onRemovePhoto,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final provider = _resolveProvider(member: member, localPhoto: localPhoto);

    return Center(
      child: InkWell(
        onTap: enabled
            ? () async {
          final action = await _showPhotoActionsSheet(context);
          if (action == _AvatarAction.cancel) return;

          if (action == _AvatarAction.remove) {
            onRemovePhoto?.call();
            return;
          }

          final source = action == _AvatarAction.camera
              ? ImageSource.camera
              : ImageSource.gallery;

          final file = await pickAndProcessImage(
            context,
            source: source,
          );

          if (file != null) onPhotoPicked?.call(file);
        }
            : null,
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.surfaceVariant,
              backgroundImage: provider,
              child: provider == null
                  ? Icon(
                Icons.person_outline,
                size: 40,
                color: theme.hintColor,
              )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: enabled ? 1 : 0.6,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.15),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _resolveProvider({
    required Member? member,
    required File? localPhoto,
  }) {
    if (localPhoto != null) return FileImage(localPhoto);

    final url = member?.avatarUrl;
    if (url == null || url.isEmpty) return null;

    // cache-bust se tiver avatarUpdatedAtMs
    final v = member?.avatarUpdatedAtMs;
    final displayUrl = (v == null) ? url : '$url&v=$v';

    return NetworkImage(displayUrl);
  }
}

enum _AvatarAction { gallery, camera, remove, cancel }

Future<_AvatarAction> _showPhotoActionsSheet(BuildContext context) async {
  final theme = Theme.of(context);

  return showModalBottomSheet<_AvatarAction>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, _AvatarAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Câmara'),
              onTap: () => Navigator.pop(context, _AvatarAction.camera),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(
                'Remover foto',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(context, _AvatarAction.remove),
            ),
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context, _AvatarAction.cancel),
            ),
          ],
        ),
      );
    },
  ).then((v) => v ?? _AvatarAction.cancel);
}

Future<File?> pickAndProcessImage(
    BuildContext context, {
      required ImageSource source,
    }) async {
  final picker = ImagePicker();

  final XFile? picked = await picker.pickImage(
    source: source,
    imageQuality: 100, // compressão é feita abaixo com mais controlo
  );
  if (picked == null) return null;

  File file = File(picked.path);

  // (Opcional) crop 1:1
  // final cropped = await ImageCropper().cropImage(
  //   sourcePath: file.path,
  //   aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  // );
  // if (cropped == null) return null;
  // file = File(cropped.path);

  // compress + resize
  final dir = await getTemporaryDirectory();
  final outPath = p.join(
    dir.path,
    'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );

  final compressed = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    outPath,
    quality: 78,
    minWidth: 512,
    minHeight: 512,
    format: CompressFormat.jpeg,
  );

  return compressed == null ? null : File(compressed.path);
}