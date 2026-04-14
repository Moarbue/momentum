import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/workout.dart';

class StorageHelper {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getLocalFile(String id) async {
    final path = await _localPath;
    return File('$path/workout_$id.json');
  }

  static Future<void> saveWorkout(Workout workout) async {
    final file = await _getLocalFile(workout.id);
    await file.writeAsString(jsonEncode(workout.toJson()));
  }

  static Future<List<Workout>> loadAllWorkouts() async {
    final path = await _localPath;
    final directory = Directory(path);

    if (!await directory.exists()) {
      return [];
    }

    final List<FileSystemEntity> files = directory.listSync();

    final futures = files
        .where(
          (file) =>
              file is File &&
              file.path.endsWith('.json') &&
              file.path.contains('workout_'),
        )
        .map((file) async {
          try {
            final contents = await (file as File).readAsString();
            return Workout.fromJson(jsonDecode(contents));
          } catch (e) {
            return null;
          }
        });

    final results = await Future.wait(futures);
    final workouts = results.whereType<Workout>().toList();

    workouts.sort((a, b) => a.position.compareTo(b.position));
    return workouts;
  }

  static Future<void> deleteWorkout(String id) async {
    final file = await _getLocalFile(id);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
