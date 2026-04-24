import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class SmartMarquee extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;
  final Duration startAfter;

  const SmartMarquee({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.velocity = 40,
    this.blankSpace = 100.0,
    this.pauseAfterRound = const Duration(milliseconds: 500),
    this.startAfter = const Duration(milliseconds: 1000),
  });

  @override
  State<SmartMarquee> createState() => SmartMarqueeState();
}

class SmartMarqueeState extends State<SmartMarquee> {
  bool _needsMarquee = false;
  double _lastMaxWidth = -1;
  double _textHeight = 16.0;
  Key _marqueeKey = UniqueKey();

  @override
  void didUpdateWidget(covariant SmartMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.style != oldWidget.style) {
      _lastMaxWidth = -1;
      _marqueeKey = UniqueKey();
    }
  }

  void _scheduleCheck(double maxWidth) {
    _lastMaxWidth = maxWidth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkNeedsMarquee(maxWidth);
    });
  }

  void _checkNeedsMarquee(double maxWidth) {
    if (maxWidth <= 0 || maxWidth == double.infinity) {
      if (_needsMarquee) {
        setState(() {
          _needsMarquee = false;
        });
      }
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final requiredMarquee = textPainter.width > maxWidth;

    if (_needsMarquee != requiredMarquee || _textHeight != textPainter.height) {
      setState(() {
        _needsMarquee = requiredMarquee;
        _textHeight = textPainter.height;
      });
    }
  }

  void restart() {
    if (_needsMarquee) {
      setState(() {
        _marqueeKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth != _lastMaxWidth) {
          _scheduleCheck(constraints.maxWidth);
        }

        if (_needsMarquee) {
          return SizedBox(
            height: _textHeight,
            width: double.infinity,
            child: Marquee(
              key: _marqueeKey,
              text: widget.text,
              style: widget.style,
              velocity: widget.velocity,
              blankSpace: widget.blankSpace,
              pauseAfterRound: widget.pauseAfterRound,
              startAfter: widget.startAfter,
            ),
          );
        }

        return Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: 1,
        );
      },
    );
  }
}
