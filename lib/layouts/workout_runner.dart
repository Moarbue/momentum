import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutRunner extends StatefulWidget {
  final Workout workout;
  const WorkoutRunner({super.key, required this.workout});

  @override
  State<WorkoutRunner> createState() => _WorkoutRunnerState();
}

class _WorkoutRunnerState extends State<WorkoutRunner> {
  late List<WorkoutStep> _flatSteps;
  int _currentStepIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _flatSteps = _flattenWorkout(widget.workout);
    if (_flatSteps.isNotEmpty) {
      _remainingSeconds = _flatSteps[0].durationValue;
    }
  }

  List<WorkoutStep> _flattenWorkout(Workout workout) {
    List<WorkoutStep> steps = [];

    void expandBlock(WorkoutBlock block) {
      if (block is WorkoutStep) {
        steps.add(
          WorkoutStep(
            name: block.name,
            durationValue: block.durationValue,
            backgroundColor: block.backgroundColor,
            isRest: block.isRest,
          ),
        );
      } else if (block is Set) {
        for (int i = 0; i < block.repetitions; i++) {
          for (var subBlock in block.blocks) {
            expandBlock(subBlock);
          }
        }
      }
    }

    for (var block in workout.blocks) {
      expandBlock(block);
    }
    return steps;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _nextStep();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _nextStep() {
    if (_currentStepIndex < _flatSteps.length - 1) {
      _currentStepIndex++;
      _remainingSeconds = _flatSteps[_currentStepIndex].durationValue;
    } else {
      _timer?.cancel();
      setState(() => _isRunning = false);
      _showWorkoutCompleteDialog();
    }
  }

  void _showWorkoutCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: const Text('Congratulations on finishing your workout.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flatSteps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Runner')),
        body: const Center(child: Text('This workout has no steps.')),
      );
    }

    final currentStep = _flatSteps[_currentStepIndex];

    return Scaffold(
      backgroundColor: currentStep.backgroundColor,
      appBar: AppBar(
        title: Text(widget.workout.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentStep.name,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '$_remainingSeconds',
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Step ${_currentStepIndex + 1} of ${_flatSteps.length}',
              style: const TextStyle(fontSize: 24, color: Colors.white70),
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _pauseTimer();
                    setState(() {
                      _currentStepIndex = 0;
                      _remainingSeconds = _flatSteps[0].durationValue;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
