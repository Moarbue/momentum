import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/settings_provider.dart';
import '../utils/export_import_helper.dart';
import '../utils/storage_helper.dart';

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

  Future<void> _exportWorkout() async {
    final (workouts, _) = await StorageHelper.loadAllWorkouts();
    if (workouts.isEmpty) {
      _showMessage('No workouts to export');
      return;
    }

    if (workouts.length == 1) {
      final result = await ExportImportHelper.exportWorkout(workouts.first);
      if (result != null) {
        _showMessage('Exported "${workouts.first.name}"');
      } else {
        _showMessage('Export cancelled');
      }
      return;
    }

    final selected = await showDialog<Workout>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Workout'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: workouts.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(workouts[index].name),
              onTap: () => Navigator.pop(context, workouts[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      final result = await ExportImportHelper.exportWorkout(selected);
      if (result != null) {
        _showMessage('Exported "${selected.name}"');
      } else {
        _showMessage('Export cancelled');
      }
    }
  }

  Future<void> _importWorkout() async {
    try {
      final workout = await ExportImportHelper.importWorkout();
      if (workout != null) {
        await StorageHelper.saveWorkout(workout);
        _showMessage('Workout "${workout.name}" imported successfully');
      }
    } catch (e) {
      _showMessage('Failed to import: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            ListTile(
              title: const Text('Skip Sound'),
              subtitle: const Text('Play sound when skipping exercises'),
              trailing: Switch(
                value: settings.skipSoundEnabled,
                onChanged: (val) => settings.setSkipSoundEnabled(val),
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
            leading: const Icon(Icons.file_upload),
            title: const Text('Export Workout'),
            subtitle: const Text('Save workout to a JSON file'),
            onTap: _exportWorkout,
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import Workout'),
            subtitle: const Text('Load workout from a JSON file'),
            onTap: _importWorkout,
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Momentum',
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
