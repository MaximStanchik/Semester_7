import 'dart:async';

void main() {
  StreamController<int> controller = StreamController<int>.broadcast();

  Timer.periodic(Duration(seconds: 1), (timer) {
    if (timer.tick > 5) {
      controller.close();
      timer.cancel();
    } else {
      controller.add(timer.tick);
    }
  });

  controller.stream.listen((data) {
    print('Broadcast Stream Listener 1: $data');
  });

  controller.stream.listen((data) {
    print('Broadcast Stream Listener 2: $data');
  });

  controller.stream.listen((data) {
    print('Broadcast Stream Listener 3: $data');
  });

  controller.stream.listen((data) {
    print('Broadcast Stream Listener 4: $data');
  });
}