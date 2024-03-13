import 'package:dslink/utils.dart';

void main() {
  Scheduler.after(Duration(seconds: 5), () {
    print("It's 5 seconds later.");
  });

  Scheduler.every(Interval.ONE_SECOND, () {
    print('One Second');
  });
}
