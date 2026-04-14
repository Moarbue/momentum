import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  settings.setThemeMode(mode);
                }
              },
              items: ThemeMode.values.map((ThemeMode mode) {
                return DropdownMenuItem<ThemeMode>(
                  value: mode,
                  child: Text(mode.name.toUpperCase()),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (val) => settings.setNotificationsEnabled(val),
            ),
          ),
          ListTile(
            title: const Text('Preparation Timer'),
            trailing: Switch(
              value: settings.prepEnabled,
              onChanged: (val) => settings.setPrepEnabled(val),
            ),
          ),
          if (settings.prepEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Preparation Duration (s):'),
                  const Spacer(),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      decoration: const InputDecoration(isDense: true),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: settings.prepDuration.toString(),
                      ),
                      onChanged: (val) {
                        final duration = int.tryParse(val) ?? 10;
                        settings.setPrepDuration(duration);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ListTile(
            title: const Text('Remove Last Rest of Set'),
            subtitle: const Text(
              'Skips the final rest period of a set if it is the last block in the set, preventing an unnecessary wait before the next set or finishing.',
            ),
            trailing: Switch(
              value: settings.removeLastRestEnabled,
              onChanged: (val) => settings.setRemoveLastRestEnabled(val),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Preparation Timer'),
            trailing: Switch(
              value: settings.prepEnabled,
              onChanged: (val) => settings.setPrepEnabled(val),
            ),
          ),
          if (settings.prepEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Preparation Duration (s):'),
                  const Spacer(),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      decoration: const InputDecoration(isDense: true),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: settings.prepDuration.toString(),
                      ),
                      onChanged: (val) {
                        final duration = int.tryParse(val) ?? 10;
                        settings.setPrepDuration(duration);
                      },
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Interval Timer',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.timer),
              );
            },
          ),
        ],
      ),
    );
  }
}
