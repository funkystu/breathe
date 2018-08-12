import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:breathe/util/misc.dart';
import 'package:breathe/util/parameters.dart';
import 'package:breathe/util/candleStickGraph.dart';

class Victory extends StatefulWidget {
  Victory(this.callback, this.holds);
  final callback;
  final List<int> holds;
  @override
  _VictoryState createState() => _VictoryState();
}

class _VictoryState extends State<Victory> {
  List _sessionData = List();

  @override
  void initState() {
    super.initState();
    int high = widget.holds.reduce(Math.max);
    int low = widget.holds.reduce(Math.min);
    int volumeto = widget.holds.reduce((a, b) => a + b);
    _sessionData = List.filled(1, {
      "open": widget.holds.first,
      "high": high,
      "low": low,
//      "high": widget.holds.reduce(Math.max),
//      "low": widget.holds.reduce(Math.min),
      "close": widget.holds.last,
      "volumeto": volumeto,
//      "volumeto": widget.holds.reduce((num a, num b) => a + b),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 86.0),
        ),
        Icon(
          Icons.assessment,
          size: 120.0,
        ),
        Text('Good Job!', style: HeaderTextStyle()),
        Padding(padding: EdgeInsets.only(bottom: 8.0)),
        Container(
//          margin:  EdgeInsets.symmetric(horizontal: 64.0),
          child: Text(
              'You performed ' +
                  (Parameters.deepBreathsOn
                      ? (Parameters.deepBreathCount *
                                  (Parameters.reps -
                                      (Parameters.deepBreathsFirst ? 0 : 1)) *
                                  Parameters.sets)
                              .toString() +
                          " deep breaths. \nAnd "
                      : "") +
                  (Parameters.shallowBreathCount *
                          Parameters.reps *
                          Parameters.sets)
                      .toString() +
                  " shallow breaths." +
                  '\n',
              textAlign: TextAlign.center,
              style: DescriptionTextStyle()),
        ),
        Padding(padding: EdgeInsets.only(bottom: 16.0)),
        widget.holds.length > 1
            ? Container(
                padding: const EdgeInsets.only(
                    top: 18.0, left: 32.0, right: 0.0, bottom: 18.0),
                constraints: BoxConstraints(minHeight: 250.0, maxHeight: 250.0),
                child: CandleGraph(
                  data: _sessionData,
                  enableGridLines: true,
                  volumeProp: 0.3,
                ))
            : Container(),
        Divider(height: 32.0, color: Colors.transparent),
        Container(
          child: Material(
            elevation: 16.0,
            shadowColor: Colors.black26,
            color: Colors.white,
            child: InkWell(
              onTap: () => widget.callback(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 64.0, vertical: 16.0),
                child: Text('Return to Main Menu',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        )
      ],
    );
  }
}
