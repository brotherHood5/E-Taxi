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
      print("Socket is connected1: ${_io.id}");
      return;
    }
    if (accessToken == null) {
      print("Socket is not connected");
      throw Exception("Socket is not connected");
    }

    _io.connect();

    _io.onConnect((dynamic data) {
      print("Socket is connected: ${_io.id}");
      _io.emit("call", "coordSystem.connect");
    });

    _io.onConnectError((dynamic data) {
      print('Socket connect error: \n$data');
    });

    _io.on('unauthorized', (dynamic data) {
      print('Socket unauthorized');
    });

    _io.onError(
      (dynamic error) => {print("Socket error: \n$error")},
    );

    _io.onDisconnect((dynamic data) {
      print('Socket disconnected');
    });
  }

  Socket get ins => _io;
}
