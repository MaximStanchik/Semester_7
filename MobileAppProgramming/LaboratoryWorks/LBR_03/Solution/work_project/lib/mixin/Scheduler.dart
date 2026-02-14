mixin Scheduler {
  void scheduleMeeting(DateTime date) {
    print('Scheduling meeting on: ${date.toLocal()}');
  }

  void sendMessage(String message) {
    print('Sending message: $message' + ' hi!');
  }
}