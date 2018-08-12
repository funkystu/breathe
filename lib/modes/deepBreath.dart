import 'package:flutter/material.dart';
import 'package:breathe/util/circle.dart';
import 'package:breathe/util/misc.dart';
import 'package:breathe/util/parameters.dart';

class DeepBreath extends StatefulWidget {
  DeepBreath(_callback) {
    callback = _callback;
  }
  var callback;

  @override
  _DeepBreathState createState() => _DeepBreathState();
}

class _DeepBreathState extends State<DeepBreath> with TickerProviderStateMixin {
  AnimationController _animationController;
  CircleTween _tween;

  String _header = "Deep Breaths.";
  String _subtitle = "Tap and hold to begin your inhale.\nRelease to exhale.";

  //how long did each in-and-out take?
  Stopwatch _watch = Stopwatch();
  Duration _in = Duration();
  Duration _out = Duration();

  //breath count so-far
  int _count = 0;

  bool _inputDone = false;
  bool _circleInvisible = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );

    _tween = CircleTween(Circle.smallest(), Circle.smallest());
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
          ]),
        ));
  }

  //used for changing the header when the inhale animation is done.
  void _endOfInhale(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      setState(() {
        _header = "Exhale.";
      });
    }
  }

  //used for changing the header when the exhale animation is done.
  void _endOfExhale(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      setState(() {
        _header = "Inhale.";
      });
    }
  }

  void _inhale(TapDownDetails d) {
    if (_inputDone) return;

    setState(() {
//      print("in");
      //record duration.
      _watch.stop();
      if (_watch.elapsedMilliseconds > 1000) {
        _out += Duration(milliseconds: _watch.elapsedMilliseconds);
//        print(_watch.elapsedMilliseconds);
      }
      _watch.reset();

      if (_count == Parameters.deepBreathCount)
        _done();
      else {
        _header = "Inhale.";
        _tween = CircleTween(
            _tween.evaluate(_animationController), Circle.largest());
        _animationController.removeStatusListener(_endOfExhale);
        _animationController.addStatusListener(_endOfInhale);
        _animationController.forward(from: 0.0);
        _watch.start();
      }
    });
  }

  void _exhale(TapUpDetails d) {
//    print("out");

    if (_inputDone) return;

    setState(() {
      bool _msg = false;
      //record duration.
      _watch.stop();

      if (_watch.elapsedMilliseconds > 1000) {
        _in += Duration(milliseconds: _watch.elapsedMilliseconds);
        _count++;
        _msg = false;
      } else {
        _subtitle = "Please take long breaths.";
        _msg = true;
      }
//aesthetics
      _watch.reset();

      _header = "Exhale.";
      _tween =
          CircleTween(_tween.evaluate(_animationController), Circle.smallest());
      _animationController.removeStatusListener(_endOfInhale);
      _animationController.addStatusListener(_endOfExhale);
      _animationController.forward(from: 0.0);

      int _left = Parameters.deepBreathCount - _count;

      if (_count == Parameters.deepBreathCount)
        _done();
      else {
        _watch.start();
        if (_msg)
          return;
        else if (_left == 1)
          _subtitle = "Last Breath!";
        else
          _subtitle = "$_left Breaths Left.";
      }
    });
  }

  void _done() {
    setState(() {
      _inputDone = true;
      _header = "Get Ready.";
      _subtitle = "";
      //extra code???
      if (_animationController.status == AnimationStatus.forward)
        _animationController.addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed)
            setState(() {
              _circleInvisible = true;
              _header = "Get Ready!";
              widget.callback(_in, _out);
            });
        });
      else {
        _circleInvisible = true;
        _header = "Get Ready!";
        widget.callback(_in, _out);
      }
    });
  }
}
