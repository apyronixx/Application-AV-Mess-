import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project_bucarest/screens/welcome_screen.dart';


class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  String selectedRoom = 'Room 1';
  List<String> selectedParticipants = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int selectedDuration = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Room:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedRoom,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRoom = newValue!;
                  });
                },
                items: <String>['Room 1', 'Room 2', 'Room 3', 'Room 4']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20.0),
              Text(
                  ((AppLocalizations.of(context)!.chooseParticipants)),
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  List<String> participants = snapshot.data!.docs
                      .map((DocumentSnapshot document) => document['email'].toString())
                      .toList();

                  return Wrap(
                    children: participants
                        .map(
                          (participant) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip(
                          label: Text(participant),
                          selected: selectedParticipants.contains(participant),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedParticipants.add(participant);
                              } else {
                                selectedParticipants.remove(participant);
                              }
                            });
                          },
                        ),
                      ),
                    )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Choose Date and Time:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: ColorConstants.kPrimaryColor),
                    child: const Text('Pick Date'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: ColorConstants.kPrimaryColor),
                    child: const Text('Pick Time'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                'Choose Duration (in minutes): $selectedDuration',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Slider(

                value: selectedDuration.toDouble(),
                min: 15,
                max: 120,
                onChanged: (value) {
                  setState(() {
                    selectedDuration = value.toInt();
                  });
                },
                activeColor: ColorConstants.kPrimaryColor,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Show a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Meeting Schedule'),
                        content: Text(
                          'Room: $selectedRoom\nParticipants: ${selectedParticipants.join(", ")}\nDate and Time: $selectedDate ${selectedTime.format(context)}\nDuration: $selectedDuration minutes',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Close the dialog and schedule the meeting
                              Navigator.of(context).pop();
                              scheduleMeeting();
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: ColorConstants.kPrimaryColor),
                child: const Text('Schedule Meeting'),

              ),
            ],
          ),
        ),
      ),
    );
  }

  void scheduleMeeting() async {
    final meetingsCollection = FirebaseFirestore.instance.collection('meetings');

    // Add a meeting document to the 'meetings' collection
    await meetingsCollection.add({
      'room': selectedRoom,
      'participants': selectedParticipants,
      'start_time': Timestamp.fromDate(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
      ),
      'duration': selectedDuration,
    });
  }
}
