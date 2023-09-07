import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketEvent {
  static const String RECEIVE_BOOKING = "receive_booking";
}

class SocketApi {
  static final SocketApi _singleton = SocketApi._internal();

  factory SocketApi() {
    return _singleton;
  }

  SocketApi._internal();

  static final Socket _io = io(
      SOCKET_URL,
      OptionBuilder()
          .enableForceNewConnection()
          .setTransports(['websocket'])
          .setTimeout(5000)
          .setReconnectionDelay(10000)
          .enableReconnection()
          .disableAutoConnect()
          .setQuery({
            "service": "staffs",
          })
          .setAuthFn((callback) {
            callback({
              "token": accessToken,
            });
          })
          .build());

  static late String? accessToken;
  static void setAuthToken(String token) {
    accessToken = token;
  }

  static void init() {
    if (_io.connected) {
      log("Socket is connected: ${_io.id}", name: "SocketApi");
      return;
    }

    if (accessToken == null) {
      log("Socket is not connected", name: "SocketApi");
      throw Exception("Socket is not connected");
    }
    try {
      log("Socket is connecting", name: "SocketApi");
      _io.connect();

      _io.onConnect((dynamic data) {
        log("Socket is connected: ${_io.id}", name: "SocketApi");
        _io.emit("call", "coordSystem.connect");
      });

      _io.onConnectError((dynamic data) {
        log('Socket connect error: \n$data', name: "SocketApi");
      });

      _io.on('unauthorized', (dynamic data) {
        log('Socket unauthorized', name: "SocketApi");
      });

      _io.onError(
        (dynamic error) => {log("Socket error: \n$error", name: "SocketApi")},
      );

      _io.onDisconnect((dynamic data) {
        log('Socket disconnected', name: "SocketApi");
      });
    } catch (e, s) {
      log(e.toString(), name: "SocketApi", error: e, stackTrace: s);
    }
  }

  Socket get ins => _io;
}
