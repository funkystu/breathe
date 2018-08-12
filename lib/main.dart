import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//utils
import 'package:statemachine/statemachine.dart' as SM;
import 'package:breathe/util/parameters.dart';
import 'package:breathe/util/database.dart';
import 'package:breathe/util/misc.dart';

//pages
import 'package:breathe/modes/settings.dart';
import 'package:breathe/modes/records.dart';
import 'package:breathe/modes/deepBreath.dart';
import 'package:breathe/modes/shallowBreath.dart';
import 'package:breathe/modes/holdBreath.dart';
import 'package:breathe/modes/recoverBreath.dart';
import 'package:breathe/modes/victory.dart';

void main() => runApp(new Breathe());

//App
class Breathe extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    return new MaterialApp(
      title: 'Breathe.',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Breathing(),
    );
  }
}

//Root Widget
class Breathing extends StatefulWidget {
  Breathing({Key key}) : super(key: key);
  @override
  _BreathingState createState() => new _BreathingState();
}

class _BreathingState extends State<Breathing>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //state machine for switching between 'activities' rendered as stateful widgets.
  SM.Machine machine;
  SM.State mainMenu;
  SM.State settings;
  SM.State records;

  //the mechanical states of the program
  SM.State breathing;
  SM.State deepBreath;
  SM.State shallowBreath;
  SM.State holdBreath;
  SM.State recoverBreath;

  //victory screen
  SM.State victory;

  //how far into the exercise has the user progressed?
  int _set = 0;
  int _rep = 0;

  //records
  Duration _deepInhales;
  Duration _shallowInhales;
  Duration _deepExhales;
  Duration _shallowExhales;
  List<int> _holds;

  //did the user want to quit the session?
  bool _askedToQuit = false;

  //For measuring the length of a session.
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 500;

  //Scaffold key for displaying toasts
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  //reset the session
  void _reset() {
    _rep = 0;
    _set = 0;
    _deepInhales = Duration();
    _deepExhales = Duration();
    _shallowInhales = Duration();
    _shallowExhales = Duration();
    _holds.clear();
  }

  void _recordSession() async {
    BreathDatabase db = BreathDatabase();
    await db.recordSession(
        (Parameters.deepBreathCount *
            (Parameters.sets - (Parameters.deepBreathsFirst ? 0 : 1)) *
            (Parameters.deepBreathsOn ? 1 : 0)),
        _deepInhales.inMilliseconds,
        _deepExhales.inMilliseconds,
        Parameters.shallowBreathCount * (Parameters.sets * Parameters.reps),
        _shallowInhales.inMilliseconds,
        _shallowExhales.inMilliseconds,
        (Parameters.recoverBreathCount * (Parameters.sets * Parameters.reps)),
        List<int>.from(_holds));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //setup local storage & load parameters.
    Parameters.load();
    BreathDatabase db = BreathDatabase();

    //only init the database if it isn't there.
    if (!Parameters.dbInitialized)
      db
          .initDB()
          .then((db) => Parameters.dbInitialized = true)
          .then((db) => Parameters.save());

    //Data for this session.
    _holds = List<int>();
    _deepInhales = Duration();
    _shallowInhales = Duration();
    _deepExhales = Duration();
    _shallowExhales = Duration();

    //Setup the State Machine.
    //-----------------------
    machine = SM.Machine();

    mainMenu = machine.newState('mainMenu');
    settings = machine.newState('settings');
    records = machine.newState('records');

    breathing = machine.newState('breathing');
    deepBreath = machine.newState('deep');
    shallowBreath = machine.newState('shallow');
    holdBreath = machine.newState('hold');
    recoverBreath = machine.newState('recover');
    victory = machine.newState('victory');

    mainMenu.onEntry(enterMainMenu);
    settings.onEntry(enterSettings);
    records.onEntry(enterRecords);

    breathing.onEntry(enterBreathing);
    deepBreath.onEntry(enterDeepBreath);
    shallowBreath.onEntry(enterShallowBreath);
    holdBreath.onEntry(enterHoldBreath);
    recoverBreath.onEntry(enterRecoverBreath);
    victory.onEntry(enterVictory);

    machine.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //State Transitions.
  //------------------
  //we're using onEntry for when states start and
  // exitState as a callback to prompt state transition by this widget.
  void enterMainMenu() {}
  void exitMainMenu() {}

  void enterSettings() {}
  void exitSettings() {
    setState(() {
      Parameters.save();
      mainMenu.enter();
    });
  }

  void enterRecords() {}
  void exitRecords() {
    setState(() {
      mainMenu.enter();
    });
  }

  void enterBreathing() {
    setState(() {
      _reset();
      stopwatch.start();
      if (Parameters.deepBreathsOn && Parameters.deepBreathsFirst)
        deepBreath.enter();
      else
        shallowBreath.enter();
    });
  }

  void exitBreathing() {}

  void enterShallowBreath() {}
  void exitShallowBreath(Duration _in, Duration _out) {
    setState(() {
      if (!Parameters.dontRecordData) {
        _shallowInhales += _in;
        _shallowExhales += _out;
      }
      holdBreath.enter();
    });
  }

  void enterDeepBreath() {}
  void exitDeepBreath(Duration _in, Duration _out) {
    setState(() {
      if (!Parameters.dontRecordData) {
        _deepInhales += _in;
        _deepExhales += _out;
      }
      shallowBreath.enter();
    });
  }

  void enterHoldBreath() {}
  void exitHoldBreath(int ms) {
    setState(() {
      if (!Parameters.dontRecordData) _holds.add(ms);
      recoverBreath.enter();
    });
  }

  void enterRecoverBreath() {}
  void exitRecoverBreath() {
    setState(() {
      _rep++;
      if (_rep >= Parameters.reps) {
        _rep = 0;
        _set++;
      }

      if (_set >= Parameters.sets) {
        victory.enter();
      } else if (_rep == 0 && Parameters.deepBreathsOn)
        deepBreath.enter();
      else
        shallowBreath.enter();
    });
  }

  void enterVictory() {
    setState(() {
      if (!Parameters.dontRecordData) _recordSession();
    });
  }

  void exitVictory() {
    setState(() {
      mainMenu.enter();
    });
  }

  //Handle Back Press
  //-----------------
  @override
  didPopRoute() {
    //give a toast asking if they really want to quit
    if (machine.current == breathing ||
        machine.current == deepBreath ||
        machine.current == shallowBreath ||
        machine.current == holdBreath ||
        machine.current == recoverBreath ||
        //sneak the main menu in here as well.
        machine.current == mainMenu) {
      if (_askedToQuit)
        setState(() {
          if (machine.current == mainMenu)
            exit(0);
          else
            mainMenu.enter();
        });
      else {
        //ask the user if they want to quit & handle time-out.
        setState(() {
          _askedToQuit = true;
          Timer(Duration(seconds: 3), () {
            setState(() {
              _askedToQuit = false;
            });
          });
          _key.currentState.showSnackBar(new SnackBar(
            content: new Text((machine.current == mainMenu)
                ? "Press back again to exit the application."
                : "Press back again to quit."),
            action: new SnackBarAction(
              label: "OK",
              onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
            ),
          ));
        });
      }
    }

    //if it's settings or stats, then go back to the main menu.
    else if (machine.current == settings || machine.current == records)
      setState(() {
        _askedToQuit = false;
        mainMenu.enter();
      });

    //anything else, we ignore.
  }

  @override
  Widget build(BuildContext context) {
    var mode;

    //main menu
    //---------
    if (machine.current == mainMenu) {
      mode = Stack(children: <Widget>[
//        Image(image: null)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Text("BREATHE", style: LogoTextStyle()),
                )),
            Expanded(
              child: MenuButton(
                text: "BEGIN",
                style: BeginMenuItemTextStyle(),
                callback: () => setState(() {
                      breathing.enter();
                    }),
              ),
            ),
            Expanded(
                child: MenuButton(
              text: "RECORDS",
              style: RecordsMenuItemTextStyle(),
              callback: () => setState(() {
                    records.enter();
                  }),
            )),
            Expanded(
                child: MenuButton(
              text: "SETTINGS",
              style: SettingsMenuItemTextStyle(),
              callback: () => setState(() {
                    settings.enter();
                  }),
            )),
          ],
        ),
      ]);
    }

    //records and settings
    //--------------------
    else if (machine.current == records) {
      mode = Records(exitRecords);
    } else if (machine.current == settings) {
      mode = Settings(exitSettings);
    }

    //breathing states
    //----------------
    else if (machine.current == deepBreath) {
      mode = DeepBreath(exitDeepBreath);
    } else if (machine.current == shallowBreath) {
      mode = ShallowBreath(exitShallowBreath);
    } else if (machine.current == holdBreath) {
      mode = HoldBreath(exitHoldBreath);
    } else if (machine.current == recoverBreath) {
      mode = RecoverBreath(exitRecoverBreath);
    } else if (machine.current == victory) {
      mode = Victory(exitVictory, List<int>.from(_holds));
    }

    //present the state.
    return Scaffold(
      key: _key,
      body: Container(padding: const EdgeInsets.all(16.0), child: mode),
    );
  }
}

//For the main menu.
class MenuButton extends StatelessWidget {
  MenuButton({this.text, this.callback, this.style});
  final String text;
  final TextStyle style;
//  final Icon icon;
  final callback;

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //TODO: AESTHETICS: maybe put some sort of image here?
        FlatButton(
          onPressed: callback,
          padding: EdgeInsets.all(5.0),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
      ],
    );
  }
}
