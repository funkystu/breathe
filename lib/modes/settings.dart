import 'dart:async';
import 'package:flutter/material.dart';
import 'package:breathe/util/parameters.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:breathe/util/misc.dart';
import 'package:breathe/util/database.dart';

//Settings page.
class Settings extends StatefulWidget {
  Settings(this.callback);
  final callback;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void initState() {
    super.initState();
    //Hack for the delete data button.
    settings.add(Card(
        child: Container(
            child: Material(
                elevation: 32.0,
                shadowColor: Colors.redAccent,
                color: Colors.white,
                child: InkWell(
                    onTap: _sure,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Icon(Icons.delete_forever,
                                    color: Colors.red))),
                        Expanded(
                          flex: 9,
                          child: Center(
                              child: Text(
                            "Delete All Data",
                            style: DeleteTextStyle(),
                          )),
                        ),
                      ]),
                    ))))));
  }

  @override
  void dispose() {
    super.dispose();
  }

  //DRY: Just hacking it out here. The callbacks are messy & gross repetition especially.
  List<Widget> settings = [
    SettingsOption(
      name: "Number Of Cycles",
      description: "The number of holds in a set.",
      value: Parameters.reps,
      min: 1,
      max: 10,
      callback: ((i) {
        Parameters.reps = i;
      }),
      numerical: true,
    ),
    SettingsOption(
        name: "Number of Sets",
        description: "The number of sets before the excercise is complete.",
        value: Parameters.sets,
        min: 1,
        max: 50,
        callback: ((i) {
          Parameters.sets = i;
        }),
        numerical: true),
    SettingsOption(
      name: "Deep Breaths",
      description: "After each set, there will be a round of deep breathing.",
      value: Parameters.deepBreathsOn,
      callback: ((i) {
        Parameters.deepBreathsOn = i;
      }),
      numerical: false,
    ),
    SettingsOption(
      name: "Deep Breaths First",
      description: "The excercise will begin with deep breathing.",
      value: Parameters.deepBreathsFirst,
      callback: ((i) {
        Parameters.deepBreathsFirst = i;
      }),
      numerical: false,
    ),
    SettingsOption(
      name: "Deep Breath Reps",
      description: "Sets the number of deep breaths for one rep.",
      value: Parameters.deepBreathCount,
      min: 1,
      max: 10,
      callback: ((i) {
        Parameters.deepBreathCount = i;
      }),
      numerical: true,
    ),
    SettingsOption(
      name: "Shallow Breath Reps",
      description: "Sets the number of shallow breaths for one rep.",
      value: Parameters.shallowBreathCount,
      min: 5,
      max: 100,
      callback: ((i) {
        Parameters.shallowBreathCount = i;
      }),
      numerical: true,
    ),
    SettingsOption(
      name: "Recovery Breath Reps",
      description: "Sets the number of recovery breaths for one rep.",
      value: Parameters.recoverBreathCount,
      min: 1,
      max: 10,
      callback: ((i) {
        Parameters.recoverBreathCount = i;
      }),
      numerical: true,
    ),
    SettingsOption(
      name: "Display Timer",
      description: "Displays the timer during breath holds.",
      value: Parameters.displayTimerDuringHold,
      callback: ((i) {
        Parameters.displayTimerDuringHold = i;
      }),
      numerical: false,
    ),
    SettingsOption(
      name: "Don't Record Data",
      description: "Data about your breathing will not be recorded.",
      value: Parameters.dontRecordData,
      callback: ((i) {
        Parameters.dontRecordData = i;
      }),
      numerical: false,
    ),
    Divider(height: 82.0),
  ];

  //The About Popup
  Future<Null> _about() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Breathe', style: HeaderTextStyle()),
          content: SingleChildScrollView(
            child: Align(
              child: ListBody(
                children: <Widget>[
                  Text('An application by Funky Stu.\nMade with Flutter.',
                      style: DescriptionTextStyle()),
                  Divider(),
                  Text(
                      'Candlestick chart code and design by Trent Piercy.(c) 2018 MIT License.',
                      style: DescriptionTextStyle()),
                  Divider(),
                  Text(
                      'Pie chart code and design by Victor Choueiri. (c) 2017 MIT License.',
                      style: DescriptionTextStyle()),
                  Divider(),
                  Text(
                      'Number picker code and design by Marcin Szalek. (c) 2017 BSD-2 License. ',
                      style: DescriptionTextStyle()),
                  Divider(),
                  Text(
                      'Logo: Air by Shastry from the Noun Project. (c) 2018 CC BY License.',
                      style: DescriptionTextStyle()),
                  Divider(),
                  Text('Special thanks to Wim Hof.',
                      style: DescriptionTextStyle()),
                  Divider(color: Colors.transparent),
                  Divider(height: 32.0, color: Colors.transparent),
                  Text(
                      'Breathe 1.0.0\nCopyright (c) 2018 Stuart Brunt.\nThis program comes with\nABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions.',
                      style: MicroTextStyle()),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok.'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _sure() {
    _areYouSure();
  }

  //The 'Are you sure you want to delete all the data Popup
  Future<Null> _areYouSure() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user can dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?', style: HeaderTextStyle()),
          content: SingleChildScrollView(
            child: Align(
              child: ListBody(
                children: <Widget>[
                  Icon(
                    Icons.delete_forever,
                    color: Colors.redAccent,
                    size: 72.0,
                  ),
                  Divider(height: 8.0, color: Colors.transparent),
                  Text('This action will delete all your data.',
                      style: DescriptionTextStyle()),
                  Divider(height: 8.0, color: Colors.transparent),
                  Text('You cannot undo this action.',
                      style: SubtitleTextStyle()),
                  Divider(color: Colors.transparent),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8.0),
            ),
            FlatButton(
              color: Colors.red,
              child: Text(
                'Delete Data.',
                style: DeleteTextStyle(),
              ),
              onPressed: () {
                BreathDatabase db = BreathDatabase();
                db.deleteDatabase();
                Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            FlatButton(
              color: Colors.blueAccent,
              child: Text(
                'Cancel.',
                style: DeleteTextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.0),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //TODO: AESTHETICS: must test this out on different resoultions in order to see if it's consistant...
    return Column(
      children: <Widget>[
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
                        child: Text("Settings", style: HeaderTextStyle())),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(top: 16.0),
                        child: IconButton(
                            onPressed: () => _about(),
                            icon: Icon(Icons.help_outline, size: 32.0))))
              ],
            )),
//        Divider(
//          height: 16.0,
//          color: Colors.transparent,
//        ),
        Expanded(
          flex: 15,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) =>
                    settings[index],
                itemCount: settings.length),
          ),
        ),
      ],
    );
  }
}

class SettingsOption extends StatefulWidget {
  SettingsOption(
      {this.name,
      this.description,
      this.value,
      this.min,
      this.max,
      this.callback,
      this.numerical});

  final String name;
  final String description;
  var value; //reference to the parameter.
  final int min;
  final int max;
  final callback;
  final bool numerical;

  @override
  _SettingsOptionState createState() => _SettingsOptionState();
}

class _SettingsOptionState extends State<SettingsOption> {
  void onChange(var i) {
    setState(() {
      widget.value = i;
      widget.callback(i);
    });
  }

  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        child: Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.name,
                            style: SubtitleTextStyle(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.description,
                                style: DescriptionTextStyle()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: widget.numerical
                        ? NumberPicker.integer(
                            initialValue: widget.value,
                            minValue: widget.min,
                            maxValue: widget.max,
                            onChanged: onChange,
                          )
                        : Checkbox(value: widget.value, onChanged: onChange),
                  ),
                ],
              ),
            ])));
  }
}
