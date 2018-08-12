import 'dart:math';
import 'dart:async';
import 'package:breathe/util/candleStickGraph.dart';
import 'package:flutter/material.dart';
import 'package:breathe/util/misc.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:breathe/util/database.dart';
import 'package:breathe/util/pageViewDotIndicator.dart';

class Records extends StatefulWidget {
  Records(this.callback);
  final callback;
  @override
  _RecordsState createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  //TODO: TESTING: move these to the test class...
  bool _debugging = false;
  bool _debugDaysOne() {
    final today = Today();
    List<Day> _dbDays = List<Day>();
    List<Hold> _dbHolds = List<Hold>();
    Random _random = Random();
    for (int i = 0; i < 21; i++) {
      if ((i + 1) % 5 == 0) {
        _dbDays.add(Day.fromMap({
          "DAYID": today - 21 + i,
          "DEEPBREATHS": 10,
          "SHALLOWBREATHS": 70,
          "RECPVERYBREATHS": 5,
          "DEEPINHALETIME": 10 * 1500,
          "SHALLOWINHALETIME": 70 * 600,
          "DEEPEXHALETIME": 10 * 1100,
          "SHALLOWEXHALETIME": 70 * 450,
          "TOTALHOLDTIME": 30 * 1000 * 4
        }));

        num total = 30 * 4 * 1000; //2 minutes in ms.
        for (int j = 0; j < 4; j++) {
          num length =
              _random.nextDouble() * 30.0 + _random.nextDouble() * 10.0;
          length *= 1000; //convert to ms.
          _dbHolds.add(Hold.fromMap({
            "DAYID": today - 21 + i,
            "DURATION": j == 3 ? total.floor() : length.floor(),
          }));
          total -= length;
        }
      }
    }
    _days = List<Day>.from(_dbDays);
    _holds = List<Hold>.from(_dbHolds);
    return true;
  }

  bool _debugDaysTwo() {
    final today = Today();
    List<Day> _dbDays = List<Day>();
    List<Hold> _dbHolds = List<Hold>();
    Random _random = Random();
    final numdays = 49;
    for (int i = 0; i < numdays; i++) {
      if ((i + 1) % 7 != 0) {
        _dbDays.add(Day.fromMap({
          "DAYID": today - numdays + i,
          "DEEPBREATHS": 10,
          "SHALLOWBREATHS": 70,
          "RECPVERYBREATHS": 5,
          "DEEPINHALETIME": 10 * 1500,
          "SHALLOWINHALETIME": 70 * 600,
          "DEEPEXHALETIME": 10 * 1100,
          "SHALLOWEXHALETIME": 70 * 450,
          "TOTALHOLDTIME": 30 * 1000 * 4
        }));

        num total = 30 * 4 * 1000; //2 minutes in ms.
        for (int j = 0; j < 4; j++) {
          num length =
              _random.nextDouble() * 30.0 + _random.nextDouble() * 10.0;
          length *= 1000; //convert to ms.
          _dbHolds.add(Hold.fromMap({
            "DAYID": today - numdays + i,
            "DURATION": j == 3 ? total.floor() : length.floor(),
          }));
          total -= length;
        }
      }
    }
    _days = List<Day>.from(_dbDays);
    _holds = List<Hold>.from(_dbHolds);
    return true;
  }

  bool _active = false;
  bool _loaded = false;
  List<Day> _days = List<Day>();
  List<Hold> _holds = List<Hold>();

  //for switching between different records screens
  final _pageViewController = PageController();
  final _kDuration = const Duration(milliseconds: 300);
  final _kCurve = Curves.ease;

  //setup candle chart for breath holds.
  //------------------------------------
  List _holdsGraphData = List();
  void _generateHoldGraphData() {
    //holds for every day, from the first day to the last.
    _holdsGraphData = List.filled(_days.last.day - _days.first.day + 1,
        {"open": 0, "high": 0, "low": 0, "close": 0, "volumeto": 0});

    //first we find opens, highs, lows, and closes.
    //holds are sorted by holdIDS.
    int day = _holds.first.day;
    int open = -1;
    int high = -1;
    int low = pow(2, 52);
    int close = -1;
    int volume = 0;

    //every hold we have from the last year.
    for (int i = 0; i < _holds.length; i++) {
      //Days have multiple breath holds.
      // holds[i] is from a  day.
      if (_holds[i].day != day) {
        //make sure we're not writing invalid data by checking to see
        //if the day's data is the (invalid) default
        if (open == -1 &&
            high == -1 &&
            low == pow(2, 52) &&
            close == -1) //&& i > 0) implicit.
          //for days when the user didn't interact, we just write
          //no movement on the chart and nothing added to the volume to breaths.
          _holdsGraphData[day - _holds.first.day] = {
            "open": _holdsGraphData[day - _holds.first.day - 1]["open"],
            "close": _holdsGraphData[day - _holds.first.day - 1]["open"],
            "high": _holdsGraphData[day - _holds.first.day - 1]["open"],
            "low": _holdsGraphData[day - _holds.first.day - 1]["open"],
            "volumeto": _holdsGraphData[day - _holds.first.day - 1]["volumeto"]
          };

        //otherwise, record the hold normally.
        volume += _days[_days.indexWhere((e) {
          return e.day == day;
        })]
            .totalHoldTime
            .inMilliseconds;
        _holdsGraphData[day - _holds.first.day] = {
          "open": open,
          "high": high,
          "low": low,
          "close": close,
          "volumeto": volume,
        };
        //and reset.
        open = -1;
        high = -1;
        low = pow(2, 52);
        close = -1;
        day = _holds[i].day;
      }

      //record this hold's data.
      int t = _holds[i].duration.inMilliseconds;
      if (open == -1) open = t;
      if (t > high) high = t;
      if (t < low) low = t;
      close = t;
    }

    //do the last day.
    volume += _days[_days.indexWhere((e) {
      return e.day == day;
    })]
        .totalHoldTime
        .inMilliseconds;

    _holdsGraphData[day - _holds.first.day] = {
      "open": open,
      "high": high,
      "low": low,
      "close": close,
      "volumeto": volume,
    };
  }

  //setup pie chart for breath ratios.
  //------------------------------------
  final GlobalKey<AnimatedCircularChartState> _pieChartKey =
      GlobalKey<AnimatedCircularChartState>();
  num fraction = 0.0;
  List<CircularStackEntry> _pieChartSlices = List<CircularStackEntry>();
  void _generateRatioData() {
    //TODO: MECHANICS: introduce timeframes here. We'll all all-time (1yr) for now.
    num deepIn = 0.0;
    num deepOut = 0.0;
    num shallowIn = 0.0;
    num shallowOut = 0.0;
    _days.forEach((Day d) {
      deepIn += d.deepInhaleTime.inMilliseconds;
      deepOut += d.deepExhaleTime.inMilliseconds;
      shallowIn += d.shallowInhaleTime.inMilliseconds;
      shallowOut += d.shallowExhaleTime.inMilliseconds;
    });
    fraction = (shallowIn / (shallowOut + shallowIn));
    if (fraction.isNaN) fraction = 0.0;
    _pieChartSlices = <CircularStackEntry>[
      CircularStackEntry(
        <CircularSegmentEntry>[
//           CircularSegmentEntry(deepIn, Colors.red, rankKey: 'Deep Inhales'),
          CircularSegmentEntry(shallowIn, Colors.red,
              rankKey: 'Shallow Inhales'),
//           CircularSegmentEntry(deepOut, Colors.blue,
//              rankKey: 'Deep Exhales'),
          CircularSegmentEntry(shallowOut, Colors.blue,
              rankKey: 'Shallow Exhales'),
        ],
        rankKey: 'Breath Types',
      )
    ];
  }

  //setup 'calender' for practice consistency.
  //------------------------------------------
  List<bool> _daysComplete =
      List<bool>.filled(49, false); //a representation of the last seven weeks.

  //we know session(s) are completed by existing in the databases
  void _assignDayCompleted(day) {
    int today = Today();
    //only look at the last 7 weeks.
    if (today - day.day > 48 || today - day.day < 0) return;
    _daysComplete[48 - (today - day.day)] = true;
  }

  List<Widget> _dayGridTiles() {
    List<Widget> children = [];
    for (int i = 0; i != 49; i++) {
      children.add(GridTile(
          child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Material(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.black87,
          child: Icon(_daysComplete[i] ? Icons.check : Icons.block,
              size: 28.0,
              color: _daysComplete[i] ? Colors.white : Colors.redAccent),
        ),
      )));
    }
    return children;
  }

  //callback to display the graphs once data is loaded.
  void onLoaded(bool exists) {
    setState(() {
      _loaded = true;
      if (exists) _active = true;
    });
  }

  //load data.
  Future<bool> _load() async {
    BreathDatabase db = BreathDatabase();
    _days = await db.getDays();
    _holds = await db.getHolds();
    if (_days.length == 0 || _holds.length == 0) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    //load data from database.
    //return if there's no data.
    _load().then((exists) {
      if (!exists) return false;
      //compute the how many days in the last week have been completed.
      _days.forEach(_assignDayCompleted);
      //compute the candlestick data
      _generateHoldGraphData();
      //compute the ratio of inhales & exhales
      _generateRatioData();
      return true;
    }).then((exists) => onLoaded(exists));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 16.0),
                      child: IconButton(
                          onPressed: () => widget.callback(),
                          icon: Icon(Icons.arrow_back, size: 32.0)))),
              Expanded(
                flex: 6,
                child: Center(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Text("Records", style: HeaderTextStyle())),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
//                        alignment: Alignment.centerRight,
//                        padding: EdgeInsets.only(top: 16.0),
//                        child: IconButton(
//                            onPressed: () => {},
//                            icon: Icon(Icons.help_outline, size: 32.0))
                      ))
            ],
          )),
      Expanded(
        flex: 15,
        child: PageView(
          controller: _pageViewController,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  //holds.
                  Center(
                      child: Text(
                    "Holds.",
                    style: SubtitleTextStyle(),
                  )),
                  Divider(height: 32.0, color: Colors.transparent),
                  _loaded
                      ? _active
                          ? Container(
                              constraints: BoxConstraints(
                                  minHeight: 400.0, maxHeight: 400.0),
                              child: CandleGraph(
                                data: _holdsGraphData,
                                enableGridLines: true,
                                volumeProp: 0.3,
                              ))
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 28.0)),
                                  Text('No Data.', style: HeaderTextStyle()),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 8.0)),
                                  Icon(Icons.assessment, size: 280.0),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 16.0)),
                                ],
                              ),
                            )
                      : Container()
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: <Widget>[
                    //inhales & exhales.
                    Center(
                        child: Text(
                      "Ratio of Inhalation to Exhalation.",
                      style: SubtitleTextStyle(),
                    )),
                    Divider(height: 32.0, color: Colors.transparent),
                    _active
                        ? Container(
                            child: Column(
                              children: <Widget>[
                                Center(
                                    child: Text(
                                  floatToRatio(fraction),
                                  style: HeaderTextStyle(),
                                )),
                                Container(
                                  constraints: BoxConstraints(
                                      minHeight: 400.0, maxHeight: 400.0),
                                  child: AnimatedCircularChart(
                                    key: _pieChartKey,
                                    size: const Size(400.0, 400.0),
                                    initialChartData: _pieChartSlices,
                                    chartType: CircularChartType.Pie,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(bottom: 28.0)),
                                Text('No Data.', style: HeaderTextStyle()),
                                Padding(padding: EdgeInsets.only(bottom: 8.0)),
                                Icon(Icons.assessment, size: 280.0),
                                Padding(padding: EdgeInsets.only(bottom: 16.0)),
                              ],
                            ),
                          ),
                  ],
                )),

            //Consistency over time.
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(children: <Widget>[
                  //inhales & exhales.
                  Center(
                      child: Text(
                    "Consistency.",
                    style: SubtitleTextStyle(),
                  )),
                  // making up for the room we lost due to the BoxConstraints
                  // floating point rounding error kludge by adding 55, the
                  // remainder from 400 - 345.
                  Divider(height: 32.0, color: Colors.transparent),
                  _active
                      ? Container(
                          constraints: BoxConstraints.loose(Size(345.0, 345.0)),
                          child: IgnorePointer(
                            ignoring: true,
                            ignoringSemantics: true,
                            child: GridView.count(
                              primary: true,
                              shrinkWrap: true,
                              crossAxisCount: 7,
                              children: _dayGridTiles(),
                            ),
                          ),
                        )
                      : Center(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Padding(
                                  padding: new EdgeInsets.only(bottom: 28.0)),
                              new Text('No Data.', style: HeaderTextStyle()),
                              new Padding(
                                  padding: new EdgeInsets.only(bottom: 8.0)),
                              new Icon(Icons.assessment, size: 280.0),
                              new Padding(
                                  padding: new EdgeInsets.only(bottom: 16.0)),
                            ],
                          ),
                        ),
                ])),

            //TODO: AESTHETICS: maybe have raw data, but in what kind of presentation?
            //Raw Data
//            Padding(
//                padding: const EdgeInsets.all(16.0),
//                child: ListView(children: <Widget>[
//                  //inhales & exhales.
//                  Center(
//                      child: Text(
//                    "Raw Data.",
//                    style: SubtitleTextStyle(),
//                  )),
//                  Divider(height: 16.0, color: Colors.transparent),
//                ])),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        //TODO: MECHANICS: put a selector here for the last day, week, month, year?
        child: Center(
          child: DotsIndicator(
            controller: _pageViewController,
            itemCount: 3,
            color: Colors.black87,
            onPageSelected: (int page) {
              _pageViewController.animateToPage(
                page,
                duration: _kDuration,
                curve: _kCurve,
              );
            },
          ),
        ),
      ),
    ]);
  }
}
