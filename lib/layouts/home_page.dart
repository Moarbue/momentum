import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/storage_helper.dart';
import '../utils/utils.dart';
import '../widgets/smart_marquee.dart';
import 'workout_builder.dart';
import 'workout_runner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Workout> _workouts = [];
  bool _isLoading = true;
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  /// Restart all marquee animations - called when page becomes visible
  void restartMarquees() {
    setState(() {
      _listKey = UniqueKey();
    });
  }

  Future<void> loadWorkouts({bool showSnackbar = false}) async {
    setState(() => _isLoading = true);
    final (workouts, errorCount) = await StorageHelper.loadAllWorkouts();
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
    if (mounted && showSnackbar) {
      if (workouts.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${workouts.length} workout(s) loaded')),
        );
      } else if (errorCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$errorCount workout(s) failed to load')),
        );
      }
    }
  }

  Future<void> _saveSorting() async {
    for (int i = 0; i < _workouts.length; i++) {
      _workouts[i].position = i;
      await StorageHelper.saveWorkout(_workouts[i]);
    }
  }

  void _deleteWorkout(Workout workout) async {
    await StorageHelper.deleteWorkout(workout.id);
    await loadWorkouts();
  }

  void _duplicateWorkout(Workout workout) async {
    final copy = Workout(
      name: 'Copy of ${workout.name}',
      blocks: List<WorkoutBlock>.from(workout.blocks),
    );
    await StorageHelper.saveWorkout(copy);
    await loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Momentum')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
          ? const Center(child: Text('No workouts yet. Create one!'))
          : ReorderableListView.builder(
              key: _listKey,
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
                    ).then((_) => loadWorkouts());
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutBuilder(workout: workout),
                      ),
                    ).then((_) => loadWorkouts());
                  },
                  onDelete: () => _showDeleteDialog(context, workout),
                  onDuplicate: () => _duplicateWorkout(workout),
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
          ).then((_) => loadWorkouts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: Text(
            'Are you sure you want to delete ${workout.name}?',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteWorkout(workout);
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: dialogColorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutItem extends StatefulWidget {
  final Workout workout;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _WorkoutItem({
    super.key,
    required this.workout,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  State<_WorkoutItem> createState() => _WorkoutItemState();
}

class _WorkoutItemState extends State<_WorkoutItem> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: SizedBox(
          height: 24,
          child: SmartMarquee(
            text: widget.workout.name,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.w500,
            ),
            velocity: 40,
            pauseAfterRound: const Duration(milliseconds: 1000),
            startAfter: const Duration(milliseconds: 2000),
          ),
        ),
        subtitle: Text(
          'Duration: ${formatDurationClock(widget.workout.duration)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: colorScheme.primary),
              onPressed: widget.onStart,
            ),
            IconButton(
              icon: Icon(Icons.copy, color: colorScheme.secondary),
              onPressed: widget.onDuplicate,
              tooltip: 'Duplicate',
            ),
            IconButton(icon: const Icon(Icons.edit), onPressed: widget.onEdit),
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.error),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
