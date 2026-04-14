import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/storage_helper.dart';
import '../utils/utils.dart';
import 'workout_builder.dart';
import 'workout_runner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    final workouts = await StorageHelper.loadAllWorkouts();
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  Future<void> _saveSorting() async {
    for (int i = 0; i < _workouts.length; i++) {
      _workouts[i].position = i;
      await StorageHelper.saveWorkout(_workouts[i]);
    }
  }

  void _deleteWorkout(Workout workout) async {
    await StorageHelper.deleteWorkout(workout.id);
    await _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interval Timer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
          ? const Center(child: Text('No workouts yet. Create one!'))
          : ReorderableListView.builder(
              itemCount: _workouts.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _workouts.removeAt(oldIndex);
                  _workouts.insert(newIndex, item);
                });
                _saveSorting();
              },
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return _WorkoutItem(
                  key: ValueKey(workout.id),
                  workout: workout,
                  onStart: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutRunner(workout: workout),
                      ),
                    ).then((_) => _loadWorkouts());
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutBuilder(workout: workout),
                      ),
                    ).then((_) => _loadWorkouts());
                  },
                  onDelete: () => _showDeleteDialog(context, workout),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutBuilder(workout: Workout()),
            ),
          ).then((_) => _loadWorkouts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete ${workout.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteWorkout(workout);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _WorkoutItem extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkoutItem({
    super.key,
    required this.workout,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(workout.name),
        subtitle: Text('Duration: ${formatDurationClock(workout.duration)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: onStart,
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
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
