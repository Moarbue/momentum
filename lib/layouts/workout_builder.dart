import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/storage_helper.dart';

class WorkoutBuilder extends StatefulWidget {
  final Workout workout;
  const WorkoutBuilder({super.key, required this.workout});

  @override
  State<WorkoutBuilder> createState() => _WorkoutBuilderState();
}

class _WorkoutBuilderState extends State<WorkoutBuilder> {
  late Workout _workout;

  @override
  void initState() {
    super.initState();
    // Create a copy of the workout to avoid modifying the original until saved
    _workout = Workout(
      name: widget.workout.name,
      id: widget.workout.id,
      position: widget.workout.position,
      blocks: List<WorkoutBlock>.from(widget.workout.blocks),
    );
  }

  void _save() async {
    await StorageHelper.saveWorkout(_workout);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
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
              onChanged: (val) => _workout.name = val,
              controller: TextEditingController(text: _workout.name),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _workout.blocks.length,
              itemBuilder: (context, index) {
                return _BlockEditor(
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
        step: block as WorkoutStep,
        onChanged: onChanged,
        onDelete: onDelete,
      );
    } else if (block is Set) {
      return _SetEditor(
        set: block as Set,
        onChanged: onChanged,
        onDelete: onDelete,
      );
    }
    return const SizedBox.shrink();
  }
}

class _StepEditor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      color: step.backgroundColor.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (val) {
                  step.name = val;
                  onChanged();
                },
                controller: TextEditingController(text: step.name),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Secs'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  step.durationValue = int.tryParse(val) ?? 0;
                  onChanged();
                },
                controller: TextEditingController(
                  text: step.durationValue.toString(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetEditor extends StatelessWidget {
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
                    onChanged: (val) {
                      set.repetitions = int.tryParse(val) ?? 1;
                      onChanged();
                    },
                    controller: TextEditingController(
                      text: set.repetitions.toString(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(),
            ...set.blocks.map(
              (block) => _BlockEditor(
                block: block,
                onChanged: onChanged,
                onDelete: () {
                  set.blocks.remove(block);
                  onChanged();
                },
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    set.blocks.add(WorkoutStep());
                    onChanged();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
                TextButton.icon(
                  onPressed: () {
                    set.blocks.add(Set());
                    onChanged();
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
