import 'dart:async';

import 'package:grab_clone/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketApi {
  static final SocketApi _singleton = SocketApi._internal();

  factory SocketApi() {
    return _singleton;
  }

  SocketApi._internal();

  static final Socket _io = io(
      ApiConstants.socketUrl,
      OptionBuilder()
          .enableForceNewConnection()
          .setTransports(['websocket'])
          .setTimeout(5000)
          .setReconnectionDelay(10000)
          .enableReconnection()
          .disableAutoConnect()
          .setQuery({
            "service": "customers",
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
    // _io.io.options!["auth"] = {
    //   "token": accessToken,
    // };
    // print(_io.io.options!["auth"]);

    _io.connect();

    _io.onConnect((dynamic data) {
      print("Socket is connected: ${_io.id}");
    });

    _io.onConnectError((dynamic data) {
      print('Socket connect error: \n$data');
    });

    _io.on('unauthorized', (dynamic data) {
      print('Socket unauthorized');
    });

    _io.on("driver_update_location", (data) {
      print("Data");
      print(data);
    });

    _io.onError(
      (dynamic error) => {print("Socket error: \n$error")},
    );

    _io.onDisconnect((dynamic data) {
      print('Socket disconnected');
    });
  }

  void registerStreamEvent<T>(String event, StreamSocket<T> streamSocket) {
    _io.on(event, (dynamic data) {
      streamSocket.addResponse(data);
    });
  }

  void emit(String event, [dynamic data]) {
    _io.emit(event, data);
  }

  Socket get ins => _io;
}

class StreamSocket<T> {
  StreamSocket() {
    print('Init Stream Socket: ${T.toString()}');
  }

  final _socketResponse = StreamController<T>();

  void Function(T) get addResponse => _socketResponse.sink.add;

  Stream<T> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
