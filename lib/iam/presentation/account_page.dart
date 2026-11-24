import 'package:flutter/material.dart';

import '../../common/session.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/terms_page.dart';
import 'login_page.dart';

/// Pestana Cuenta: datos del usuario, acceso a los Terminos y condiciones y cierre de sesion.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Session.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final account = Session.currentAccount;
    final name = account?.fullName ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                    child: Text(
                      name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, color: AppColors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(account?.email ?? '', style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Text('Segmento: ${account?.segmentLabel ?? '—'}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos y condiciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.red),
                  title: const Text('Cerrar sesión', style: TextStyle(color: AppColors.red)),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
