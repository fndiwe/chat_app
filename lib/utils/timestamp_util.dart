import 'package:cloud_firestore/cloud_firestore.dart';


class TimestampUtil {
  // Weekday list
  static const List<String> weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  // Months list
  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  String calculateDuration(Timestamp timestamp) {
    final Duration difference =
        DateTime.now().difference(timestamp.toDate());
    final int differenceInDays = difference.inDays;
    final int differenceInHours = difference.inHours;
    final int differenceInMinutes = difference.inMinutes;
    final int differenceInSeconds = difference.inSeconds;
    return difference.inDays >= 365
        ? "${(difference.inDays / 365).floor()}y"
        : differenceInDays >= 30
            ? "${(differenceInDays / 30).floor()}mo"
            : differenceInDays >= 7
                ? "${(differenceInDays / 7).floor()}w"
                : differenceInHours >= 24
                    ? "${(differenceInHours / 24).floor()}d"
                    : differenceInMinutes >= 60
                        ? "${(differenceInMinutes / 60).floor()}h"
                        : differenceInSeconds >= 60
                            ? "${(differenceInSeconds / 60).floor()}m"
                            : "${differenceInSeconds}s";
  }
}
