class TimeUtils {
  /// Parse time string like "7:00 AM", "10:00 AM", "2:30 PM" to DateTime
  static DateTime parseTimeString(String timeString) {
    // Remove extra spaces and convert to uppercase
    String cleanTime = timeString.trim().toUpperCase();

    // Split into time part and AM/PM part
    List<String> parts = cleanTime.split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    String timePart = parts[0];
    String amPm = parts[1];

    // Split time into hours and minutes
    List<String> timeParts = timePart.split(':');
    if (timeParts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    // Convert to 24-hour format
    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }

    // Return DateTime with today's date but the parsed time
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Find the next upcoming bus time from a list of times
  static Map<String, dynamic>? findNextBusTime(
    List<Map<String, dynamic>> times,
    DateTime currentTime,
  ) {
    if (times.isEmpty) return null;

    Map<String, dynamic>? nextTime;
    Duration? shortestDuration;

    for (var timeData in times) {
      try {
        String timeString = timeData['time'] ?? '';
        if (timeString.isEmpty) continue;

        DateTime busTime = parseTimeString(timeString);

        // If the bus time is earlier than current time, consider it for tomorrow
        if (busTime.isBefore(currentTime)) {
          busTime = busTime.add(Duration(days: 1));
        }

        Duration timeUntil = busTime.difference(currentTime);

        if (shortestDuration == null || timeUntil < shortestDuration) {
          shortestDuration = timeUntil;
          nextTime = Map<String, dynamic>.from(timeData);
          nextTime['timeUntil'] = timeUntil;
          nextTime['actualDateTime'] = busTime;
        }
      } catch (e) {
        // Skip invalid time formats
        continue;
      }
    }

    return nextTime;
  }

  /// Find the next upcoming times for both To DSC and From DSC
  static Map<String, Map<String, dynamic>?> findNextBusTimes(
    List<Map<String, dynamic>> startTimes,
    List<Map<String, dynamic>> departureTimes,
  ) {
    DateTime now = DateTime.now();

    return {
      'toDSC': findNextBusTime(startTimes, now),
      'fromDSC': findNextBusTime(departureTimes, now),
    };
  }

  /// Format duration to readable string (e.g., "2h 30m", "45m", "5m")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  /// Check if a given time is today or tomorrow relative to current time
  static String getRelativeDay(DateTime busTime, DateTime currentTime) {
    DateTime today = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );
    DateTime busDay = DateTime(busTime.year, busTime.month, busTime.day);

    if (busDay == today) {
      return 'Today';
    } else if (busDay == today.add(Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return 'Later';
    }
  }

  /// Format time to 12-hour format string
  static String formatTime12Hour(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String amPm = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $amPm';
  }
}
