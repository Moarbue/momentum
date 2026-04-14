import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _prepDurationController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _prepDurationController = TextEditingController(
      text: settings.prepDuration.toString(),
    );
  }

  @override
  void dispose() {
    _prepDurationController.dispose();
    super.dispose();
  }

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
            title: const Text('Sound Effects'),
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: (val) => settings.setSoundEnabled(val),
            ),
          ),
          if (settings.soundEnabled) ...[
            ListTile(
              title: const Text('Countdown Beeps'),
              subtitle: const Text('Play sound during the last 3 seconds'),
              trailing: Switch(
                value: settings.countdownSoundEnabled,
                onChanged: (val) => settings.setCountdownSoundEnabled(val),
              ),
            ),
            ListTile(
              title: const Text('Start Beep'),
              subtitle: const Text('Play sound at the start of each exercise'),
              trailing: Switch(
                value: settings.startSoundEnabled,
                onChanged: (val) => settings.setStartSoundEnabled(val),
              ),
            ),
          ],
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
                      controller: _prepDurationController,
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
