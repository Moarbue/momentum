import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/storage_helper.dart';
import '../utils/utils.dart';
import 'workout_runner.dart';

class WorkoutBuilder extends StatefulWidget {
  final Workout workout;
  final bool isQuickStart;
  const WorkoutBuilder({
    super.key,
    required this.workout,
    this.isQuickStart = false,
  });

  @override
  State<WorkoutBuilder> createState() => _WorkoutBuilderState();
}

class _WorkoutBuilderState extends State<WorkoutBuilder> {
  late Workout _workout;
  late TextEditingController _nameController;
  VoidCallback? onRunWorkout;

  @override
  void initState() {
    super.initState();
    _workout = Workout(
      name: widget.workout.name,
      id: widget.workout.id,
      position: widget.workout.position,
      blocks: List<WorkoutBlock>.from(widget.workout.blocks),
    );
    _nameController = TextEditingController(text: _workout.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_workout.blocks.isEmpty) {
      _showEmptyWarning();
      return;
    }
    _workout.name = _nameController.text;
    await StorageHelper.saveWorkout(_workout);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showEmptyWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Workout'),
        content: const Text(
          'This workout has no steps. Add at least one step before saving.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _run() {
    _workout.name = _nameController.text;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutRunner(workout: _workout)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isQuickStart ? 'Quick Start' : 'Edit Workout'),
        actions: [
          if (widget.isQuickStart)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _run,
              tooltip: 'Run',
            ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
              ),
              controller: _nameController,
              onChanged: (val) => _workout.name = val,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _workout.blocks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _workout.blocks.removeAt(oldIndex);
                  _workout.blocks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                return _BlockEditor(
                  key: ValueKey(_workout.blocks[index]),
                  block: _workout.blocks[index],
                  onChanged: () => setState(() {}),
                  onDelete: () {
                    setState(() {
                      _workout.blocks.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _workout.blocks.add(WorkoutStep());
                      });
                    },
                    icon: const Icon(Icons.timer),
                    label: const Text('Add Step'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _workout.blocks.add(Set());
                      });
                    },
                    icon: const Icon(Icons.group),
                    label: const Text('Add Set'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockEditor extends StatelessWidget {
  final WorkoutBlock block;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _BlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (block is WorkoutStep) {
      return _StepEditor(
        key: ValueKey(block),
        step: block as WorkoutStep,
        onChanged: onChanged,
        onDelete: onDelete,
      );
    } else if (block is Set) {
      return _SetEditor(
        key: ValueKey(block),
        set: block as Set,
        onChanged: onChanged,
        onDelete: onDelete,
      );
    }
    return const SizedBox.shrink();
  }
}

class _StepEditor extends StatefulWidget {
  final WorkoutStep step;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _StepEditor({
    super.key,
    required this.step,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_StepEditor> createState() => _StepEditorState();
}

class _StepEditorState extends State<_StepEditor> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.step.name);
    _durationController = TextEditingController(
      text: widget.step.durationValue.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _StepEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _nameController.text = widget.step.name;
      _durationController.text = widget.step.durationValue.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    final List<Color> colors = [
      const Color.fromARGB(255, 205, 92, 92), // Red
      const Color.fromARGB(255, 138, 154, 91), // Green
      const Color.fromARGB(255, 92, 138, 205), // Blue
      const Color.fromARGB(255, 205, 180, 92), // Yellow
      const Color.fromARGB(255, 150, 92, 205), // Purple
      const Color.fromARGB(255, 92, 205, 150), // Teal
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                widget.step.backgroundColor = color;
                widget.onChanged();
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.step.backgroundColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.step.backgroundColor.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.step.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: widget.step.isRest,
                        onChanged: (val) {
                          widget.step.isRest = val ?? false;
                          widget.onChanged();
                        },
                      ),
                      const Text('Rest', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      controller: _nameController,
                      onChanged: (val) {
                        widget.step.name = val;
                        widget.onChanged();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Secs'),
                    keyboardType: TextInputType.number,
                    controller: _durationController,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      widget.step.durationValue = parsed != null && parsed > 0
                          ? parsed
                          : 1;
                      widget.onChanged();
                    },
                  ),
                  Text(
                    formatDurationClock(widget.step.durationValue),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetEditor extends StatefulWidget {
  final Set set;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _SetEditor({
    super.key,
    required this.set,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_SetEditor> createState() => _SetEditorState();
}

class _SetEditorState extends State<_SetEditor> {
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(
      text: widget.set.repetitions.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _SetEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set != widget.set) {
      _repsController.text = widget.set.repetitions.toString();
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'SET',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                    controller: _repsController,
                    onChanged: (val) {
                      widget.set.repetitions = int.tryParse(val) ?? 1;
                      widget.onChanged();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const Divider(),
            if (widget.set.blocks.isEmpty)
              const SizedBox(height: 0)
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.set.blocks.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = widget.set.blocks.removeAt(oldIndex);
                    widget.set.blocks.insert(newIndex, item);
                  });
                  widget.onChanged();
                },
                itemBuilder: (context, index) {
                  return _BlockEditor(
                    key: ValueKey(widget.set.blocks[index]),
                    block: widget.set.blocks[index],
                    onChanged: () => setState(() {}),
                    onDelete: () {
                      widget.set.blocks.removeAt(index);
                      setState(() {});
                      widget.onChanged();
                    },
                  );
                },
              ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    widget.set.blocks.add(WorkoutStep());
                    widget.onChanged();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
                TextButton.icon(
                  onPressed: () {
                    widget.set.blocks.add(Set());
                    widget.onChanged();
                  },
                  icon: const Icon(Icons.group_add),
                  label: const Text('Add Nested Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
