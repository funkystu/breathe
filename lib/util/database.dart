import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:breathe/util/misc.dart';

import 'dart:async';
import 'dart:io';

//Helper classes
class Day {
  Day();

  int day;

  int breaths;
  int deepBreaths;
  int shallowBreaths;
  int recoveries; //number of recovery inhales, holds, and exhales

  Duration deepInhaleTime;
  Duration deepExhaleTime;
  Duration shallowInhaleTime;
  Duration shallowExhaleTime;
  Duration totalHoldTime;

  Day.fromMap(Map map) {
    day = map["DAYID"];
    deepBreaths = map["DEEPBREATHS"];
    shallowBreaths = map["SHALLOWBREATHS"];
    breaths = deepBreaths + shallowBreaths;
    recoveries = map["RECOVERYBREATHS"];

    deepInhaleTime = Duration(milliseconds: map["DEEPINHALETIME"]);
    deepExhaleTime = Duration(milliseconds: map["DEEPEXHALETIME"]);
    shallowInhaleTime = Duration(milliseconds: map["SHALLOWINHALETIME"]);
    shallowExhaleTime = Duration(milliseconds: map["SHALLOWEXHALETIME"]);
    totalHoldTime = Duration(milliseconds: map["TOTALHOLDTIME"]);
  }
}

class Hold {
  Hold();
  int day;
  Duration duration;

  Hold.fromMap(Map map) {
    day = map["DAYID"];
    duration = Duration(milliseconds: map["DURATION"]);
  }
}

//an interface for storing this application's data to a sqlite db file.
class BreathDatabase {
  static final BreathDatabase _instance = BreathDatabase._internal();

  factory BreathDatabase() => _instance; //allows for multiple instances.

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  BreathDatabase._internal();

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //TODO: MECHANICS: naming the database file? change this for different user accounts? why?
    String path = join(documentsDirectory.path, "breathe.db");
    var theDB = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDB;
  }

  //CREATE TABLES
  void _onCreate(Database db, int version) async {
    await db.execute('''
    create table DAYS(
    DAYID integer primary key,
    
    DEEPBREATHS integer not null,
    DEEPINHALETIME integer not null,
    DEEPEXHALETIME integer not null,
    
    SHALLOWBREATHS integer not null,
    SHALLOWINHALETIME integer not null,
    SHALLOWEXHALETIME integer not null,
    
    RECOVERYBREATHS integer not null,
    TOTALHOLDTIME integer not null)''');

    await db.execute('''
    create table HOLDS(
    HOLDID integer primary key autoincrement,
    DAYID integer not null,
    DURATION integer not null)
    ''');
  }

  Future closeDB() async {
    var dbClient = await db;
    dbClient.close();
  }

  //READ
  //----
  Future<List> getDays() async {
    int today = Today();
    int yearAgo = today - 365;
    var dbClient = await db;
    List<Map> res = await dbClient.query("DAYS",
        where: "DAYID <= ? AND DAYID >= ?",
        whereArgs: [today, yearAgo],
        orderBy: "DAYID");
    return res.map((m) => Day.fromMap(m)).toList();
  }

  Future<List> getHolds() async {
    int today = Today();
    int yearAgo = today - 365;
    var dbClient = await db;
    List<Map> res = await dbClient.query("HOLDS",
        where: "DAYID <= ? AND DAYID >= ?",
        whereArgs: [today, yearAgo],
        orderBy: "HOLDID");
    return res.map((m) => Hold.fromMap(m)).toList();
  }

  //CREATE & UPDATE
  //------
  Future<int> recordSession(
      int deepBreaths,
      int deepInhaleTime,
      int deepExhaleTime,
      int shallowBreaths,
      int shallowInhaleTime,
      int shallowExhaleTime,
      int recoveryBreaths,
      List<int> holds) async {
    var dbClient = await db;
    //verify or create.
    int today = Today();
    List<Map> q =
        await dbClient.query("DAYS", where: "DAYID = ?", whereArgs: [today]);

    bool exists = q.length > 0;
    var map = Map<String, dynamic>();
    if (!exists) {
      map["DAYID"] = Today();
      map["DEEPBREATHS"] = 0;
      map["DEEPINHALETIME"] = 0;
      map["DEEPEXHALETIME"] = 0;
      map["SHALLOWBREATHS"] = 0;
      map["SHALLOWINHALETIME"] = 0;
      map["SHALLOWEXHALETIME"] = 0;
      map["RECOVERYBREATHS"] = 0;
      map["TOTALHOLDTIME"] = 0;
      await dbClient.insert("DAYS", map);
    } else
      map = Map<String, dynamic>.from(q.first);

    //add this session's data.
    map["DEEPBREATHS"] += deepBreaths;
    map["DEEPINHALETIME"] += deepInhaleTime;
    map["DEEPEXHALETIME"] += deepExhaleTime;
    map["SHALLOWBREATHS"] += shallowBreaths;
    map["SHALLOWINHALETIME"] += shallowInhaleTime;
    map["SHALLOWEXHALETIME"] += shallowExhaleTime;
    map["RECOVERYBREATHS"] += recoveryBreaths;
    map["TOTALHOLDTIME"] += holds.reduce((a, b) => a + b);

    //add holds to total time and to the database
    int total = 0;
    int res = 0;

    for (int hold in holds) total += hold;
    for (int hold in holds) {
      try {
        var h = Map<String, dynamic>();
        h["DAYID"] = Today();
        h["DURATION"] = hold;
        res = await dbClient.insert("HOLDS", h);
      } catch (e) {
        print("ERROR: " + e.toString());
      }
    }

    map["TOTALHOLDTIME"] += total;

    //add the session to the database.
    try {
      res = await dbClient.insert("DAYS", map);
    } catch (e) {
      try {
        res = await dbClient
            .update("DAYS", map, where: "DAYID = ?", whereArgs: [map["DAYID"]]);
      } catch (e2) {
        print("error writing to database.");
      }
    }
    return res;
  }

  //DELETE
  //-----
  Future<int> deleteDatabase() async {
    var dbClient = await db;
    var res = await dbClient.delete("DAYS");
    res = await dbClient.delete("HOLDS");
    return res;
  }
}
