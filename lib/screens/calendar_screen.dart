import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class Meeting {
  DateTime startTime;
  DateTime endTime;
  String room;
  int duration;

  Meeting({
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.duration,
  });
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - DateTime.monday));
  List<Meeting> meetings = [];

  @override
  void initState() {
    super.initState();
    // Fetch meetings data from Firestore
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    DateTime startOfWeek = _currentWeek.subtract(Duration(days: _currentWeek.weekday - DateTime.monday));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

    QuerySnapshot meetingsSnapshot = await FirebaseFirestore.instance
        .collection('meetings')
        .where('start_time', isGreaterThanOrEqualTo: startOfWeek)
        .where('start_time', isLessThan: endOfWeek)
        .orderBy('start_time')
        .get();

    setState(() {
      meetings = meetingsSnapshot.docs.map((doc) {
        Timestamp startTimeStamp = doc['start_time'];
        int durationInMinutes = doc['duration'];

        // Ensure that 'room' field is not null
        String room = doc['room'] ?? 'Room Not Available';

        // Calculate end_time based on start_time and duration
        DateTime endTime =
        startTimeStamp.toDate().add(Duration(minutes: durationInMinutes));

        return Meeting(
          startTime: startTimeStamp.toDate(),
          endTime: endTime,
          room: room,
          duration: durationInMinutes,
        );
      }).toList();
    });

    print('Fetched Meetings: $meetings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context)!.calendar)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentWeek = _currentWeek.subtract(const Duration(days: 7));
                    _fetchMeetings(); // Refetch meetings for the updated week
                  });
                },
              ),
              Text(
                '${AppLocalizations.of(context)!.weekOf} ${_currentWeek.day}/${_currentWeek.month}/${_currentWeek.year}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    _currentWeek = _currentWeek.add(const Duration(days: 7));
                    _fetchMeetings(); // Refetch meetings for the updated week
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: _buildMeetingDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingDetails() {
    if (meetings.isNotEmpty) {
      DateTime currentDate = meetings.first.startTime;
      List<Widget> meetingWidgets = [];

      // Display day and date for the first meeting
      meetingWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${AppLocalizations.of(context)!.day} ${DateFormat('EEEE').format(currentDate)} | Date: ${DateFormat('d/MM').format(currentDate)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Build the rest of the meeting tiles
      meetingWidgets.addAll(
        meetings.map((meeting) {
          // Check if the date has changed
          if (currentDate.day != meeting.startTime.day) {
            currentDate = meeting.startTime;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${AppLocalizations.of(context)!.day} ${DateFormat('EEEE').format(currentDate)} | Date: ${DateFormat('d/MM').format(currentDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildMeetingTile(meeting),
              ],
            );
          } else {
            // Same date, just show the meeting
            return _buildMeetingTile(meeting);
          }
        }),
      );

      return ListView(
        children: meetingWidgets,
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: Text(
            (AppLocalizations.of(context)!.noMeetings),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  Widget _buildMeetingTile(Meeting meeting) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
            '${AppLocalizations.of(context)!.meetingIn} ${meeting.room}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)!.startAt} ${DateFormat('h:mm a').format(meeting.startTime)}, '
              '${AppLocalizations.of(context)!.lastsFor} ${meeting.duration} ${AppLocalizations.of(context)!.minutes}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
