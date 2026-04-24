import 'package:flutter/material.dart';
import 'smart_marquee.dart';

class FittingText extends StatefulWidget {
  final String text;
  final double fontSize;
  final List<double>? fallbackFontSizes;
  final bool isBold;
  final TextAlign textAlign;
  final double blankSpace;
  final double velocity;

  const FittingText({
    super.key,
    required this.text,
    required this.fontSize,
    this.fallbackFontSizes,
    this.isBold = false,
    this.textAlign = TextAlign.center,
    this.blankSpace = 100.0,
    this.velocity = 50.0,
  });

  @override
  State<FittingText> createState() => FittingTextState();
}

class FittingTextState extends State<FittingText> {
  late double _currentFontSize;
  bool _needsMarquee = false;
  double _lastMaxWidth = -1;

  @override
  void initState() {
    super.initState();
    _currentFontSize = widget.fontSize;
  }

  @override
  void didUpdateWidget(covariant FittingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.fontSize != oldWidget.fontSize ||
        widget.fallbackFontSizes != oldWidget.fallbackFontSizes) {
      _lastMaxWidth = -1;
    }
  }

  List<double> get _fallbackSizes {
    if (widget.fallbackFontSizes != null &&
        widget.fallbackFontSizes!.isNotEmpty) {
      final custom =
          widget.fallbackFontSizes!.where((s) => s < widget.fontSize).toList()
            ..sort((a, b) => b.compareTo(a));
      return [widget.fontSize, ...custom];
    }
    return [
      widget.fontSize,
      widget.fontSize * 0.8,
      widget.fontSize * 0.6,
      widget.fontSize * 0.4,
    ];
  }

  void _scheduleLayoutCheck(double maxWidth) {
    _lastMaxWidth = maxWidth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _doLayoutCheck(maxWidth);
    });
  }

  void _doLayoutCheck(double maxWidth) {
    if (maxWidth <= 0 || maxWidth == double.infinity) {
      if (_currentFontSize != widget.fontSize || _needsMarquee) {
        setState(() {
          _currentFontSize = widget.fontSize;
          _needsMarquee = false;
        });
      }
      return;
    }

    final sizes = _fallbackSizes;
    for (final size in sizes) {
      final testPainter = TextPainter(
        text: TextSpan(text: widget.text, style: _textStyle(size)),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (testPainter.width <= maxWidth) {
        if (_currentFontSize != size || _needsMarquee) {
          setState(() {
            _currentFontSize = size;
            _needsMarquee = false;
          });
        }
        return;
      }
    }

    final smallestSize = sizes.last;
    if (_currentFontSize != smallestSize || !_needsMarquee) {
      setState(() {
        _currentFontSize = smallestSize;
        _needsMarquee = true;
      });
    }
  }

  TextStyle _textStyle(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth != _lastMaxWidth) {
          _scheduleLayoutCheck(constraints.maxWidth);
        }

        if (_needsMarquee) {
          return SmartMarquee(
            text: widget.text,
            style: _textStyle(_currentFontSize),
            textAlign: widget.textAlign,
            velocity: widget.velocity,
            blankSpace: widget.blankSpace,
            pauseAfterRound: const Duration(milliseconds: 500),
            startAfter: const Duration(milliseconds: 1000),
          );
        }

        return Text(
          widget.text,
          style: _textStyle(_currentFontSize),
          textAlign: widget.textAlign,
          maxLines: 1,
        );
      },
    );
  }
}
