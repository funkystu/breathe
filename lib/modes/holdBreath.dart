import 'package:flutter/material.dart';
import 'package:breathe/util/timerDisplay.dart';
import 'package:breathe/util/parameters.dart';
import 'package:breathe/util/misc.dart';

class HoldBreath extends StatefulWidget {
  HoldBreath(_callback) {
    callback = _callback;
  }
  var callback;

  @override
  _HoldBreathState createState() => _HoldBreathState();
}

class _HoldBreathState extends State<HoldBreath> {
  final Dependencies dependencies = Dependencies();
  String _header = "Hold.";
  String _subtitle = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      if (!Parameters.displayTimerDuringHold)
        dependencies.textStyle = TransparentLogoTextStyle();
      dependencies.stopwatch.start();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Divider(height: 48.0, color: Colors.transparent),
              Text(
                _header,
                style: HeaderTextStyle(),
              ),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: SubtitleTextStyle(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Divider(height: 32.0, color: Colors.transparent),
                        TimerText(
                          dependencies: dependencies,
                        ),
                        Divider(height: 50.0, color: Colors.transparent),
                        RaisedButton(
                          child: Text(
                            "Inhale",
                            textScaleFactor: 1.3,
                            style: HeaderTextStyle(),
                          ),
                          onPressed: () => setState(() {
                                dependencies.stopwatch.stop();
                                widget.callback(
                                    dependencies.stopwatch.elapsedMilliseconds);
                                //TODO: MECHANICS: hold here for a hot minute and then callback? A timed callback to the callback?
                              }),
                        ),
                        Divider(height: 32.0, color: Colors.transparent),
                      ],
                    ),
                  ),
                )
              ]),
        ),
      ]),
    );
  }
}
