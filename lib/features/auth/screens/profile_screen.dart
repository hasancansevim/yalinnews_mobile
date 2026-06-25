import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kullanıcı',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const Text('Bildirim Tercihleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Teknoloji Haberleri'),
            value: true,
            onChanged: (val) {
              // TODO: Update FCM topic subscription
            },
          ),
          SwitchListTile(
            title: const Text('Ekonomi Haberleri'),
            value: false,
            onChanged: (val) {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Karanlık Mod'),
            trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: (v){}),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
