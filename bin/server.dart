import 'dart:convert';
import 'dart:io';

import 'package:firedart/firestore/firestore.dart';

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4004,
  );

  Firestore.initialize('fast-shopping-89c01');

  _log('[${DateTime.now()}] server started: port ${server.port}');

  try {
    await for (HttpRequest request in server) {
      final String? methodName = request.uri.queryParameters['methodName'];
      _log('[${DateTime.now()}] run method: $methodName');

      switch (methodName) {
        case 'getUser':
          final data =
              await _getUserHandler(request.uri.queryParameters['uid']);
          _log('[${DateTime.now()}] getUser result:$data');
          request.response
            ..write(data)
            ..close();
          break;
        case 'updateUser':
          final data =
              await _updateUserHandler(request.uri.queryParameters['userData']);
          _log('[${DateTime.now()}] updateUser result:$data');
          request.response
            ..write(data)
            ..close();
          break;
        default:
          _log(
              '[${DateTime.now()}]error : status code ${request.response.statusCode}');
          request.response
            ..write('Error')
            ..close();
          break;
      }
    }
  } catch (e) {
    _log('[${DateTime.now()}]server error: port $e');
  }

  _log('[${DateTime.now()}] server closed');
}

void _log(String newLog) {
  File file = File('../data/logs.log');
  file.openWrite(mode: FileMode.writeOnlyAppend).write('\n$newLog');
}

Future<String?> _getUserHandler(String? uid) async {
  if (uid != null) {
    var doc = await Firestore.instance.collection("users").document(uid).get();
    return jsonEncode(doc.map);
  }
  return null;
}

Future<String?> _updateUserHandler(String? userData) async {
  if (userData != null) {
    final data = json.decode(userData) as Map<String, dynamic>;

    var doc = await Firestore.instance
        .collection("users")
        .document(data['uid'])
        .create(data);
    return jsonEncode(doc.map);
  }
  return null;
}
