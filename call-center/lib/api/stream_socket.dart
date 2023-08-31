import 'dart:async';

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
