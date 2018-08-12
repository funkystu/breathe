class Local {
  static String _locale;
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Hello World',
    },
    'es': {
      'title': 'Hola Mundo',
    },
  };

  //TODO: AESTHETICS: do we really need string localization here?
  //etc...
  String get title {
    return _localizedValues[_locale]['title'];
  }
}
