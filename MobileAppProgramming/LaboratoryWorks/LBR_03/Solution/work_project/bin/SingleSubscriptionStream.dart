import 'dart:async';

void main() {
  StreamController<int> controller = StreamController<int>();

  Timer.periodic(Duration(seconds: 1), (timer) {
    if (timer.tick > 5) {
      controller.close();
      timer.cancel();
    } else {
      controller.add(timer.tick);
    }
  });

  controller.stream.listen((data) {
    print('Single Subscription Stream Listener 1: $data');
  });

  try {
    controller.stream.listen((data) {
      print('This will not work: $data');
    });
  } catch (e) {
    print('Error: $e'); 
  }
}