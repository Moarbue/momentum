import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/settings_provider.dart';
import '../utils/utils.dart';

class StepContext {
  final WorkoutStep step;
  final int repetition;
  final int totalRepetitions;

  StepContext({
    required this.step,
    required this.repetition,
    required this.totalRepetitions,
  });
}

class WorkoutRunner extends StatefulWidget {
  final Workout workout;
  const WorkoutRunner({super.key, required this.workout});

  @override
  State<WorkoutRunner> createState() => _WorkoutRunnerState();
}

class _WorkoutRunnerState extends State<WorkoutRunner> {
  late List<StepContext> _flatSteps;
  int _currentStepIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  void _initializeWorkout() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _flatSteps = _flattenWorkout(widget.workout);

    if (settings.prepEnabled) {
      _flatSteps.insert(
        0,
        StepContext(
          step: WorkoutStep(
            name: 'Get Ready!',
            durationValue: settings.prepDuration,
            backgroundColor: Colors.blueGrey,
            isRest: true,
          ),
          repetition: 1,
          totalRepetitions: 1,
        ),
      );
    }

    if (_flatSteps.isNotEmpty) {
      _remainingSeconds = _flatSteps[0].step.durationValue;
    }
  }

  List<StepContext> _flattenWorkout(Workout workout) {
    List<StepContext> steps = [];

    void expandBlock(
      WorkoutBlock block, {
      int repetition = 1,
      int totalRepetitions = 1,
    }) {
      if (block is WorkoutStep) {
        steps.add(
          StepContext(
            step: WorkoutStep(
              name: block.name,
              durationValue: block.durationValue,
              backgroundColor: block.backgroundColor,
              isRest: block.isRest,
            ),
            repetition: repetition,
            totalRepetitions: totalRepetitions,
          ),
        );
      } else if (block is Set) {
        for (int i = 0; i < block.repetitions; i++) {
          for (int j = 0; j < block.blocks.length; j++) {
            var subBlock = block.blocks[j];

            if (i == block.repetitions - 1 &&
                j == block.blocks.length - 1 &&
                block.removeLastRest &&
                subBlock is WorkoutStep &&
                subBlock.isRest) {
              continue;
            }

            expandBlock(
              subBlock,
              repetition: i + 1,
              totalRepetitions: block.repetitions,
            );
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
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 1) {
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
    _timer = null;
  }

  void _nextStep() {
    if (_currentStepIndex < _flatSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _remainingSeconds = _flatSteps[_currentStepIndex].step.durationValue;
      });
    } else {
      _pauseTimer();
      _showWorkoutCompleteDialog();
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _remainingSeconds = _flatSteps[_currentStepIndex].step.durationValue;
      });
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

    final currentContext = _flatSteps[_currentStepIndex];
    final currentStep = currentContext.step;

    String nextStepName = 'Finished';
    if (_currentStepIndex < _flatSteps.length - 1) {
      nextStepName = _flatSteps[_currentStepIndex + 1].step.name;
    }

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
              'Next: $nextStepName',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 16),
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
              formatDuration(_remainingSeconds),
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Rep ${currentContext.repetition} of ${currentContext.totalRepetitions}',
              style: const TextStyle(fontSize: 24, color: Colors.white70),
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: _prevStep,
                ),
                const SizedBox(width: 32),
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
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: _nextStep,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _pauseTimer();
                setState(() {
                  _currentStepIndex = 0;
                  _remainingSeconds = _flatSteps[0].step.durationValue;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
