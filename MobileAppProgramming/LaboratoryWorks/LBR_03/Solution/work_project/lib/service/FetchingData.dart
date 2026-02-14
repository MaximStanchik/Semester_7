import 'dart:async';

Future<String> fetchData() async {
  print('Fetching data...');

  await Future.delayed(Duration(seconds: 2));

  return 'Data fetched successfully!';
}

Future<void> callFuture() {
  return Future.delayed(Duration(seconds: 3), () {
    print("Future completed after 3 seconds.");
  });
}