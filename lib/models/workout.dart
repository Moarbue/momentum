import 'dart:ui';
import 'package:uuid/uuid.dart';

const Color COLOR_EXERCISE = Color.fromARGB(255, 205, 92, 92);
const Color COLOR_REST = Color.fromARGB(255, 138, 154, 91);

enum BlockType { step, set }

abstract class WorkoutBlock {
  int get duration;
  BlockType get type;
  Map<String, dynamic> toJson();
}

class WorkoutStep extends WorkoutBlock {
  String name;
  int durationValue;
  Color backgroundColor;
  bool isRest;

  WorkoutStep({
    this.name = "Exercise",
    this.durationValue = 10,
    this.backgroundColor = COLOR_EXERCISE,
    this.isRest = false,
  });

  @override
  int get duration => durationValue;

  @override
  BlockType get type => BlockType.step;

  @override
  Map<String, dynamic> toJson() => {
    'type': type.index,
    'name': name,
    'duration': durationValue,
    'backgroundColor': backgroundColor.value,
    'isRest': isRest,
  };

  factory WorkoutStep.fromJson(Map<String, dynamic> json) {
    return WorkoutStep(
      name: json['name'] as String,
      durationValue: json['duration'] as int,
      backgroundColor: Color(json['backgroundColor'] as int),
      isRest: json['isRest'] as bool,
    );
  }
}

class Set extends WorkoutBlock {
  int repetitions;
  bool removeLastRest;
  List<WorkoutBlock> blocks;

  Set({
    this.repetitions = 1,
    this.removeLastRest = true,
    List<WorkoutBlock>? blocks,
  }) : this.blocks = blocks ?? [WorkoutStep()];

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
