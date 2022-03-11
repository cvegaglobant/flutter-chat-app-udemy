import 'package:chatapp/global/enviroments.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  io.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void connect() async {
    final token = await AuthService.getToken();

    // Dart client
    _socket = io.io(
      Enviroments.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .setExtraHeaders({
            'x-token': token,
          })
          .build(),
    );

    _socket.on(
      'connect',
      (_) {
        _serverStatus = ServerStatus.online;
        notifyListeners();
      },
    );

    _socket.on(
      'disconnect',
      (_) {
        _serverStatus = ServerStatus.offline;
        notifyListeners();
      },
    );
  }

  void disconnect() {
    _socket.disconnect();
  }
}
