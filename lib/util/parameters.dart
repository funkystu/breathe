import 'package:shared_preferences/shared_preferences.dart';

//parameters for the program.
class Parameters {
  static int reps = 3; //cycles of shallow breaths and holds before deep breath
  static int sets = 1; //how many cycles until we're done for the session.

  static bool deepBreathsOn = true; //if we want to do deep breaths at all.
  static bool deepBreathsFirst = true; //if we want to do deep breaths first.
  static int deepBreathCount = 3; //how many deep breaths we want to do.

  static int shallowBreathCount = 35; //how many shallow breaths before a hold
  static int recoverBreathCount = 3; //how many breaths & holds for recovery?
  //duration of recovery holds

  static bool displayTimerDuringHold = true;

  static bool dontRecordData = false;
  static bool dbInitialized = false;
  //save and load from disk.
  static void save() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref
        .setInt("reps", reps)
        .then((val) => pref.setInt("sets", sets))
        .then((val) => pref.setBool("deepBreathsOn", deepBreathsOn))
        .then((val) => pref.setBool("deepBreathsFirst", deepBreathsFirst))
        .then((val) => pref.setInt("deepBreathCount", deepBreathCount))
        .then((val) => pref.setInt("shallowBreathCount", shallowBreathCount))
        .then((val) => pref.setInt("recoverBreathCount", recoverBreathCount))
        .then((val) =>
            pref.setBool("displayTimerDuringHold", displayTimerDuringHold))
        .then((val) => pref.setBool("dontRecordData", dontRecordData))
        .then((val) => pref.setBool("dbInitialized", dbInitialized));
  }

  static void load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    reps = pref.getInt("reps") ?? 3;
    sets = pref.getInt("sets") ?? 1;
    deepBreathsOn = pref.getBool("deepBreathsOn") ?? true;
    deepBreathsFirst = pref.getBool("deepBreathsFirst") ?? true;
    deepBreathCount = pref.getInt("deepBreathCount") ?? 3;
    shallowBreathCount = pref.getInt("shallowBreathCount") ?? 35;
    recoverBreathCount = pref.getInt("recoverBreathCount") ?? 3;
    displayTimerDuringHold = pref.getBool("displayTimerDuringHold") ?? true;
    dontRecordData = pref.getBool("dontRecordData") ?? false;
    dbInitialized = pref.getBool("dbInitialized") ?? false;
  }
}
