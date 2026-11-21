import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_notifier.dart';

/// Avatar button with account info and a logout action.
/// Logout asks for confirmation before it clears the session.
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      onSelected: (value) {
        if (value == 'logout') {
          _confirmLogout(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            email ?? 'Signed in',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 20),
              SizedBox(width: 12),
              Text('Log out'),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: Text(
          _initials(email),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_outlined),
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              auth.logout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  String _initials(String? value) {
    final localPart = value?.split('@').first ?? 'user';
    final parts = localPart
        .split(RegExp(r'[._-]'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
