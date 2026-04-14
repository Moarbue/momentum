import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/workout.dart';

class ExportImportHelper {
  static const String fileExtension = 'json';
  static const String fileMimeType = 'application/json';

  static Future<String?> exportWorkout(Workout workout) async {
    try {
      final jsonStr = jsonEncode(workout.toJson());
      final fileName =
          '${workout.name.replaceAll(RegExp(r'[^\w\s-]'), '')}_${DateTime.now().millisecondsSinceEpoch}.json';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Workout',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [fileExtension],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonStr);
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Workout?> importWorkout() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [fileExtension],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath == null) return null;
        final file = File(filePath);
        final jsonStr = await file.readAsString();
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;

        final validation = validateWorkout(json);
        if (!validation.isValid) {
          throw FormatException(
            validation.errorMessage ?? 'Unknown validation error',
          );
        }

        return Workout.fromJson(json);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static ValidationResult validateWorkout(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return ValidationResult(false, 'File is empty');
    }

    if (!json.containsKey('name') || json['name'] is! String) {
      return ValidationResult(false, 'Missing or invalid "name" field');
    }

    if (!json.containsKey('id') || json['id'] is! String) {
      return ValidationResult(false, 'Missing or invalid "id" field');
    }

    if (!json.containsKey('position') || json['position'] is! int) {
      return ValidationResult(false, 'Missing or invalid "position" field');
    }

    if (!json.containsKey('blocks') || json['blocks'] is! List) {
      return ValidationResult(false, 'Missing or invalid "blocks" field');
    }

    final blocks = json['blocks'] as List;
    if (blocks.isEmpty) {
      return ValidationResult(false, 'Workout must have at least one block');
    }

    for (int i = 0; i < blocks.length; i++) {
      final blockValidation = validateBlock(
        blocks[i] as Map<String, dynamic>,
        i,
      );
      if (!blockValidation.isValid) {
        return blockValidation;
      }
    }

    return ValidationResult(true, null);
  }

  static ValidationResult validateBlock(Map<String, dynamic> json, int index) {
    if (!json.containsKey('type') || json['type'] is! int) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "type" field',
      );
    }

    final type = json['type'] as int;
    if (type != 0 && type != 1) {
      return ValidationResult(
        false,
        'Block $index: invalid type value (must be 0 or 1)',
      );
    }

    if (type == 0) {
      return _validateStepBlock(json, index);
    } else {
      return _validateSetBlock(json, index);
    }
  }

  static ValidationResult _validateStepBlock(
    Map<String, dynamic> json,
    int index,
  ) {
    if (!json.containsKey('id') || json['id'] is! String) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "id" field',
      );
    }

    if (!json.containsKey('name') || json['name'] is! String) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "name" field',
      );
    }

    if (!json.containsKey('duration') || json['duration'] is! int) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "duration" field',
      );
    }

    final duration = json['duration'] as int;
    if (duration < 1) {
      return ValidationResult(
        false,
        'Block $index: duration must be at least 1 second',
      );
    }

    if (!json.containsKey('backgroundColor') ||
        json['backgroundColor'] is! int) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "backgroundColor" field',
      );
    }

    if (!json.containsKey('isRest') || json['isRest'] is! bool) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "isRest" field',
      );
    }

    return ValidationResult(true, null);
  }

  static ValidationResult _validateSetBlock(
    Map<String, dynamic> json,
    int index,
  ) {
    if (!json.containsKey('id') || json['id'] is! String) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "id" field',
      );
    }

    if (!json.containsKey('repetitions') || json['repetitions'] is! int) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "repetitions" field',
      );
    }

    final reps = json['repetitions'] as int;
    if (reps < 1) {
      return ValidationResult(
        false,
        'Block $index: repetitions must be at least 1',
      );
    }

    if (!json.containsKey('removeLastRest') ||
        json['removeLastRest'] is! bool) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "removeLastRest" field',
      );
    }

    if (!json.containsKey('blocks') || json['blocks'] is! List) {
      return ValidationResult(
        false,
        'Block $index: missing or invalid "blocks" field',
      );
    }

    final blocks = json['blocks'] as List;
    if (blocks.isEmpty) {
      return ValidationResult(
        false,
        'Block $index: set must have at least one block',
      );
    }

    for (int j = 0; j < blocks.length; j++) {
      final blockValidation = validateBlock(
        blocks[j] as Map<String, dynamic>,
        j,
      );
      if (!blockValidation.isValid) {
        return blockValidation;
      }
    }

    return ValidationResult(true, null);
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult(this.isValid, this.errorMessage);
}
