import 'dart:async';
import 'package:flutter/material.dart';
import 'package:breathe/util/circle.dart';
import 'package:breathe/util/parameters.dart';
import 'package:breathe/util/misc.dart';

class ShallowBreath extends StatefulWidget {
  ShallowBreath(_callback) {
    callback = _callback;
  }
  var callback;

  @override
  _ShallowBreathState createState() => _ShallowBreathState();
}

class _ShallowBreathState extends State<ShallowBreath>
    with TickerProviderStateMixin {
  //for animation
  AnimationController _animationController;
  CircleTween _tween;

  String _header = "Shallow Breaths.";
  String _subtitle = "";

  //how long did each in-and-out take?
  Stopwatch _watch = Stopwatch();
  Duration _in = Duration();
  Duration _out = Duration();

  //breath count so far
  int _count = 0;

  bool _inhaling = true;
  bool _inputDone = false;
  bool _circleInvisible = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _tween = CircleTween(Circle.smallest(), Circle.smallest());

    _animationController.addStatusListener((status) {
      if ((status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) &&
          _inhaling) return; //_exhale(TapUpDetails());
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: Key("circleHitBox"),
        behavior: HitTestBehavior.translucent,
        onTapDown: _inhale,
        onTapUp: _exhale,
        //Very important! Sometimes a onTapUp is a onTapCancel.
        onTapCancel: () {
          _exhale(TapUpDetails());
        },
        child: Center(
            child: Column(children: <Widget>[
          Expanded(
              child: Column(
            children: <Widget>[
              Divider(
                height: 46.0,
                color: Colors.transparent,
              ),
              Text(_header,
                  textAlign: TextAlign.center, style: HeaderTextStyle()),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: SubtitleTextStyle(),
              )
            ],
          )),
          Expanded(
            flex: 3,
            child: _circleInvisible
                ? Container()
                : Container(
                    alignment: Alignment.center,
                    child: CustomPaint(
                      painter:
                          CirclePainter(_tween.animate(_animationController)),
                    ),
                  ),
          ),
        ])));
  }

  void _inhale(TapDownDetails d) {
    if (_inputDone) return;
    setState(() {
      _inhaling = true;
      //record duration.
      _watch.stop();
      if (_watch.elapsedMilliseconds < 1000) {
        _out += Duration(milliseconds: _watch.elapsedMilliseconds);
      }
      _watch.reset();

      if (_count != Parameters.shallowBreathCount) {
        _header = "Inhale.";
        _tween = CircleTween(
            _tween.evaluate(_animationController), Circle.largest());
        _animationController.forward(from: 0.0);
        _watch.start();
      }
    });
  }

  void _exhale(TapUpDetails d) {
    if (_inputDone) return;

    setState(() {
      _inhaling = false;
      //record duration.
      _watch.stop();

      if (_watch.elapsedMilliseconds < 1000) {
        _in += Duration(milliseconds: _watch.elapsedMilliseconds);
//        print(_count);
        _count++;
      } else if (Parameters.shallowBreathCount - _count == 1) {
        _count++;
      } else {
        _subtitle = "Please take short breaths.";
      }

      _watch.reset();

      _header = "Exhale.";
      _tween =
          CircleTween(_tween.evaluate(_animationController), Circle.smallest());
      _animationController.forward(from: 0.0);

      //depending on the count, we want to display different instructions...
      if (_count == Parameters.shallowBreathCount)
        _done();
      else if (_count >= Parameters.shallowBreathCount - 7) {
        int _left = Parameters.shallowBreathCount - _count;
        if (_left == 1) {
          _subtitle = "Last Breath!";
          _animationController.duration = Duration(seconds: 4);
        } else
          _subtitle = "$_left Breaths Left.";
      } else
        _watch.start();
    });
  }

  void _done() {
    setState(() {
      _inputDone = true;
      _header = "Big Exhale!";
      _subtitle = "";
      if (_animationController.status == AnimationStatus.forward)
        _animationController.addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed)
            setState(() {
              _circleInvisible = true;
              widget.callback(_in, _out);
            });
        });
      else {
        _circleInvisible = true;
        widget.callback(_in, _out);
      }
    });
  }
}
