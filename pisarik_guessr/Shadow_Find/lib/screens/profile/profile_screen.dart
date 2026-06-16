import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/app_providers.dart';
import '../../services/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _picker = ImagePicker();
  File? _pickedImage;
  bool _saving = false;

  ImageProvider? _buildAvatarImage(AppUser? user) {
    if (_pickedImage != null) return FileImage(_pickedImage!);
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(user.avatarUrl!);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.displayName ?? '';
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      String? avatarUrl = user.avatarUrl;
      if (_pickedImage != null) {
        avatarUrl = await firebaseService.uploadImage(_pickedImage!, 'avatars/${user.uid}');
      }
      await firebaseService.updateProfile(
        displayName: _nameCtrl.text.trim(),
        avatarUrl: avatarUrl,
      );
      final updatedUser = AppUser(
        uid: user.uid,
        displayName: _nameCtrl.text.trim(),
        email: user.email,
        friendCode: user.friendCode,
        totalScore: user.totalScore,
        roundsPlayed: user.roundsPlayed,
        avatarUrl: avatarUrl,
        createdAt: user.createdAt,
      );
      if (mounted) {
        context.read<AuthProvider>().setUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлён')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _buildAvatarImage(user),
                child: (_pickedImage == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty))
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Сменить аватар'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Имя игрока',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Мой код: ${user.friendCode}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _StatRow(label: 'Очков', value: '${user.totalScore}'),
                    _StatRow(label: 'Раундов', value: '${user.roundsPlayed}'),
                    _StatRow(
                        label: 'Средний балл',
                        value: user.averageScore.toStringAsFixed(0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save),
                label: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}