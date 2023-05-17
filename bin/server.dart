import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
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
          final userData = JWT.decode(request.uri.queryParameters['token']!);
          final data = await _getUserHandler(userData.payload['uid']);
          _log('[${DateTime.now()}] getUser result:$data');
          request.response
            ..write(data)
            ..close();
          break;
        case 'updateUser':
          final userData = JWT.decode(request.uri.queryParameters['token']!);
          final data = await _updateUserHandler(userData.payload);
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

Future<String?> _updateUserHandler(Map<String, dynamic>? userData) async {
  if (userData != null) {
    var doc = await Firestore.instance
        .collection("users")
        .document(userData['uid'])
        .create(userData);
    return jsonEncode(doc.map);
  }
  return null;
}
