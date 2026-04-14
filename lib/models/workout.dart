import 'dart:ui';
import 'package:uuid/uuid.dart';

const Color COLOR_EXERCISE = Color.fromARGB(255, 205, 92, 92);
const Color COLOR_REST = Color.fromARGB(255, 138, 154, 91);

enum BlockType { step, set }

abstract class WorkoutBlock {
  String get id;
  int get duration;
  BlockType get type;
  Map<String, dynamic> toJson();
}

class WorkoutStep extends WorkoutBlock {
  String id;
  String name;
  int durationValue;
  Color backgroundColor;
  bool isRest;
  bool skipLastRest;

  WorkoutStep({
    String? id,
    this.name = "Exercise",
    this.durationValue = 10,
    this.backgroundColor = COLOR_EXERCISE,
    this.isRest = false,
    this.skipLastRest = false,
  }) : id = id ?? const Uuid().v4();

  @override
  int get duration => durationValue;

  @override
  BlockType get type => BlockType.step;

  @override
  Map<String, dynamic> toJson() => {
    'type': type.index,
    'id': id,
    'name': name,
    'duration': durationValue,
    'backgroundColor': backgroundColor.value,
    'isRest': isRest,
    'skipLastRest': skipLastRest,
  };

  factory WorkoutStep.fromJson(Map<String, dynamic> json) {
    return WorkoutStep(
      id: json['id'] as String,
      name: json['name'] as String,
      durationValue: json['duration'] as int,
      backgroundColor: Color(json['backgroundColor'] as int),
      isRest: json['isRest'] as bool,
      skipLastRest: json['skipLastRest'] as bool? ?? false,
    );
  }
}

class Set extends WorkoutBlock {
  String id;
  int repetitions;
  bool removeLastRest;
  List<WorkoutBlock> blocks;

  Set({
    String? id,
    this.repetitions = 1,
    this.removeLastRest = true,
    List<WorkoutBlock>? blocks,
  }) : id = id ?? const Uuid().v4(),
       this.blocks = blocks ?? [WorkoutStep()];

  @override
  int get duration {
    int total = 0;
    for (var block in blocks) {
      total += block.duration;
    }
    return total * repetitions;
  }

  @override
  BlockType get type => BlockType.set;

  @override
  Map<String, dynamic> toJson() => {
    'type': type.index,
    'id': id,
    'repetitions': repetitions,
    'removeLastRest': removeLastRest,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };

  factory Set.fromJson(Map<String, dynamic> json) {
    var blocksJson = json['blocks'] as List;
    var blocks = blocksJson.map((b) {
      var blockMap = b as Map<String, dynamic>;
      var type = BlockType.values[blockMap['type'] as int];
      if (type == BlockType.step) {
        return WorkoutStep.fromJson(blockMap);
      } else {
        return Set.fromJson(blockMap);
      }
    }).toList();

    return Set(
      id: json['id'] as String,
      repetitions: json['repetitions'] as int,
      removeLastRest: json['removeLastRest'] as bool,
      blocks: blocks,
    );
  }
}

class Workout {
  String name;
  String id;
  int position;
  List<WorkoutBlock> blocks;

  Workout({
    this.name = "Workout",
    String? id,
    this.position = -1,
    List<WorkoutBlock>? blocks,
  }) : this.id = id ?? const Uuid().v4(),
       this.blocks = blocks ?? [Set()];

  int get duration {
    int total = 0;
    for (var block in blocks) {
      total += block.duration;
    }
    return total;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'position': position,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) {
    var blocksJson = json['blocks'] as List;
    var blocks = blocksJson.map((b) {
      var blockMap = b as Map<String, dynamic>;
      var type = BlockType.values[blockMap['type'] as int];
      if (type == BlockType.step) {
        return WorkoutStep.fromJson(blockMap);
      } else {
        return Set.fromJson(blockMap);
      }
    }).toList();

    return Workout(
      name: json['name'] as String,
      id: json['id'] as String,
      position: json['position'] as int,
      blocks: blocks,
    );
  }
}
