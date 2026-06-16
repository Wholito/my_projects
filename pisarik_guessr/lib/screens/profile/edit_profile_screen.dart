import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_state.dart';
import '../../services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _cloudinaryService = CloudinaryService();
  bool _isLoading = false;
  File? _selectedImageFile;
  String? _imagePreviewUrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await _cloudinaryService.pickImage(ImageSource.gallery);
                if (image != null) {
                  final file = File(image.path);
                  setState(() {
                    _selectedImageFile = file;
                    _imagePreviewUrl = file.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await _cloudinaryService.pickImage(ImageSource.camera);
                if (image != null) {
                  final file = File(image.path);
                  setState(() {
                    _selectedImageFile = file;
                    _imagePreviewUrl = file.path;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Имя не может быть пустым')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl;
      if (_selectedImageFile != null) {
        final xFile = XFile(_selectedImageFile!.path);
        newPhotoUrl = await _cloudinaryService.uploadImage(xFile);
        if (newPhotoUrl == null) {
          throw Exception('Не удалось загрузить фото');
        }
      }

      final success = await context.read<AppState>().updateUserProfile(
        newName: newName,
        newPhotoUrl: newPhotoUrl,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлён')),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<AppState>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Ошибка обновления')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _updateProfile,
              child: const Text('Сохранить'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _showImagePickerDialog,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  image: (_imagePreviewUrl != null)
                      ? DecorationImage(image: FileImage(File(_imagePreviewUrl!)), fit: BoxFit.cover)
                      : (user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover)
                      : null),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: (_imagePreviewUrl == null && (user?.photoUrl == null || user!.photoUrl!.isEmpty))
                    ? const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey))
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : _showImagePickerDialog,
              child: const Text('Изменить фото'),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя пользователя',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Код друга (неизменяемый)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          user?.friendCode ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            final friendCode = user?.friendCode ?? '';
                            if (friendCode.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: friendCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Код скопирован')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}