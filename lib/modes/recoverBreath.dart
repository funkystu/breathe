import 'package:flutter/material.dart';
import 'package:breathe/util/circle.dart';
import 'dart:core';
import 'package:breathe/util/parameters.dart';
import 'package:breathe/util/misc.dart';

class RecoverBreath extends StatefulWidget {
  RecoverBreath(_callback) {
    callback = _callback;
  }
  var callback;

  @override
  _RecoverBreathState createState() => _RecoverBreathState();
}

//these is no input here, this is just a 'cutscene'.
class _RecoverBreathState extends State<RecoverBreath>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  CircleTween _tween;

  String _header = "Inhale.";
  String _subtitle = "";

  int _count = 0;

  bool _inhaling = true;
  bool _holding = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );
    _animationController.addStatusListener(_listener);
    _animationController.addListener(_subtitleUpdate);

    _tween = CircleTween(Circle.smallest(), Circle.largest());
    _animationController.forward();
  }

  void _subtitleUpdate() {
    if (_holding) {
      setState(() {
        _subtitle =
            (15.0 * (1.0 - _animationController.value)).ceil().toString();
      });
    }
  }

  void _listener(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      setState(() {
        //three possible states:
        // we're done inhaling, we're done holding the breath, or we're done exhaling.
        if (_inhaling) {
          _holding = true;
          _inhaling = false;
          _tween = CircleTween(Circle.largest(), Circle.largest());
          _animationController.duration = Duration(seconds: 15);
          _header = "Hold.";
        } else if (_holding) {
          _holding = false;
          _inhaling = false;
          _tween = CircleTween(Circle.largest(), Circle.smallest());
          _animationController.duration = Duration(seconds: 5);
          _header = "Exhale.";
          _subtitle = "";
        } else if (!_inhaling) {
          _holding = false;
          _inhaling = true;
          _tween = CircleTween(Circle.smallest(), Circle.largest());
          _animationController.duration = Duration(seconds: 5);
          _count++;
          if (_count == Parameters.recoverBreathCount)
            widget.callback();
          else
            _header = "Inhale.";
        }
        _animationController.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: <Widget>[
        Expanded(
            child: Column(
          children: <Widget>[
            Divider(height: 46.0, color: Colors.transparent),
            Text(
              _header,
              style: HeaderTextStyle(),
            ),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: SubtitleTextStyle(),
            )
          ],
        )),
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: CirclePainter(_tween.animate(_animationController)),
            ),
          ),
        )
      ]),
    );
  }
}
