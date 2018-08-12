import 'dart:core';
import 'package:flutter/material.dart';

TextStyle LogoTextStyle() {
  return TextStyle(
      letterSpacing: 12.0,
      fontFamily: "MonoSans",
      fontWeight: FontWeight.w700,
      fontSize: 62.0);
}

TextStyle TransparentLogoTextStyle() {
  return TextStyle(
      letterSpacing: 12.0,
      fontFamily: "MonoSans",
      fontWeight: FontWeight.w700,
      color: Colors.transparent,
      fontSize: 62.0);
}

TextStyle BeginMenuItemTextStyle() {
  return TextStyle(
    color: Colors.black87,
    letterSpacing: 4.0,
    fontSize: 43.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w500,
  );
}

TextStyle SettingsMenuItemTextStyle() {
  return TextStyle(
    color: Colors.black87,
    letterSpacing: 0.9,
    fontSize: 40.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w500,
  );
}

TextStyle RecordsMenuItemTextStyle() {
  return TextStyle(
    color: Colors.black87,
    letterSpacing: 1.0,
    fontSize: 43.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w500,
  );
}

TextStyle HeaderTextStyle() {
  return TextStyle(
      letterSpacing: 3.5,
      fontFamily: "MonoSans",
      fontWeight: FontWeight.w700,
      fontSize: 32.0);
}

TextStyle SubtitleTextStyle() {
  return TextStyle(
    color: Colors.black87,
    letterSpacing: 1.0,
    fontSize: 18.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w500,
  );
}

TextStyle DeleteTextStyle() {
  return TextStyle(
    color: Colors.black87,
    letterSpacing: 1.0,
    fontSize: 18.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w600,
  );
}

TextStyle DescriptionTextStyle() {
  return TextStyle(
    color: Colors.black,
//    letterSpacing: 1.0,
    fontSize: 16.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w500,
  );
}

TextStyle MicroTextStyle() {
  return TextStyle(
    color: Colors.black,
    fontSize: 12.0,
    fontFamily: "MonoSans",
    fontWeight: FontWeight.w500,
  );
}

int Today() {
  return DateTime.now().difference(DateTime.utc(2017).toLocal()).inDays.ceil();
}

//Nice one here from:
//https://stackoverflow.com/questions/95727/how-to-convert-floats-to-human-readable-fractions
String floatToRatio(num d) {
  if (d == 0.0) return "0:0";
  if (d >= 1.0) d = d - d.floor();
  if (d == 0.0) return "0:0";
  if (d < 0.47) {
    if (d < 0.25) {
      if (d < 0.16) {
        if (d < 0.12) // Note: fixed from .13
        {
          if (d < 0.11)
            return "1:9";
          else
            return "1:8";
        } else {
          if (d < 0.14)
            return "1:7";
          else
            return "1:6";
        }
      } else {
        if (d < 0.19)
          return "1:4";
        else
          return "2:7";
      }
    } else {
      if (d < 0.37) {
        if (d < 0.28)
          return "1:3";
        else {
          if (d < 0.31)
            return "2:5";
          else
            return "1:2";
        }
      } else {
        if (d < 0.42) {
          if (d < 0.4)
            return "3:5";
          else
            return "2:3";
        } else {
          if (d < 0.44)
            return "3:4";
          else
            return "4:5";
        }
      }
    }
  } else {
    if (d < 0.71) {
      if (d < 0.6) {
        if (d < 0.55)
          return "1:1";
        else {
          if (d < 0.57)
            return "5:4";
          else
            return "4:3";
        }
      } else {
        if (d < 0.62)
          return "3:2";
        else if (d < 0.66)
          return "5:3";
        else
          return "2:1";
      }
    } else {
      if (d < 0.80) {
        if (d < 0.74)
          return "5:2";
        else // d >= .74
        {
          if (d < 0.77) // Note: fixed from .78
            return "3:1";
          else
            return "7:2";
        }
      } else // d >= .8
      {
        if (d < 0.85) // Note: fixed from .86
        {
          if (d < 0.83)
            return "4:1";
          else
            return "5:1";
        } else // d >= .85
        {
          if (d < 0.87) // Note: fixed from .88
            return "6:1";
          else // d >= .87
          {
            if (d < 0.88) // Note: fixed from .89
              return "7:1";
            else // d >= .88
            {
              if (d < 0.90)
                return "8:1";
              else
                return "9:1";
            }
          }
        }
      }
    }
  }
}
