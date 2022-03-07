import 'dart:io';

class Enviroments {
  static String apiUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3000/api' : 'localhost:3000/api';

  static String socketUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'localhost:3000';
}
