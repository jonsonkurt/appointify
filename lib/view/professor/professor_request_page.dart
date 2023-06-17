import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../student/profile_controller.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  String name = '';
  StreamSubscription<DatabaseEvent>? nameSubscription;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _dateController.text = DateFormat.yMMMd('en_US').format(selectedDate);
      }
    });
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((selectedTime) {
      if (selectedTime != null) {
        _timeController.text = selectedTime.format(context);
      }
    });
  }

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference appointmentsRef =
        FirebaseDatabase.instance.ref('appointments/');
    DatabaseReference studentsRef = FirebaseDatabase.instance.ref('students/');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Requests', style: TextStyle(fontSize: 30, fontFamily: "GothamRnd"),
            ),
            const Divider(
              color: Colors.black,
              thickness: 2,
            ),
            SearchBox(onSearch: _handleSearch),
            Expanded(
              child: FirebaseAnimatedList(
                query: appointmentsRef
                    .orderByChild('requestStatusProfessor')
                    .equalTo("$userID-PENDING"),
                itemBuilder: (context, snapshot, animation, index) {
                  // Modify strings based on your needs
                  String studentName =
                      snapshot.child('studentName').value.toString();
                  String studentSection =
                      snapshot.child('section').value.toString();
                  String profID = snapshot.child('professorID').value.toString();
                  String appointID = snapshot.child('appointID').value.toString();
                  String studID = snapshot.child("studentID").value.toString();
                  // Filter professors based on the entered name
                  if (name.isNotEmpty &&
                      !studentName.toLowerCase().contains(name.toLowerCase())) {
                    return Container(); // Hide the professor card if it doesn't match the search criteria
                  }
        
                  return SizedBox(
                    height: 210,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.grey,
                        margin:
                            const EdgeInsets.only(top: 20, left: 17, right: 17),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(height: 15),
                            Flexible(
                              child: FirebaseAnimatedList(
                                query: studentsRef.orderByChild('UID').equalTo(
                                    snapshot.child('studentID').value.toString()),
                                itemBuilder:
                                    (context, snapshot, animation, index) {
                                  return SizedBox(
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 35, 35, 35),
                                                width: 2,
                                              )),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: ProfileController().image ==
                                                      null
                                                  ? snapshot
                                                              .child(
                                                                  'profilePicStatus')
                                                              .value
                                                              .toString() ==
                                                          "None"
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 35,
                                                        )
                                                      : Image(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(snapshot
                                                              .child(
                                                                  'profilePicStatus')
                                                              .value
                                                              .toString()),
                                                          loadingBuilder: (context,
                                                              child,
                                                              loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return const CircularProgressIndicator();
                                                          },
                                                          errorBuilder: (context,
                                                              object, stack) {
                                                            return const Icon(
                                                              Icons.error_outline,
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      35,
                                                                      35,
                                                                      35),
                                                            );
                                                          },
                                                        )
                                                  : Image.file(File(
                                                          ProfileController()
                                                              .image!
                                                              .path)
                                                      .absolute)),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              studentSection,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
        
                            
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 10),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Text(snapshot
                            //           .child('studentName')
                            //           .value
                            //           .toString()),
                            //       Text(snapshot.child('section').value.toString()),
                            //     ],
                            //   ),
                            // ),
                            Container(
                              alignment: Alignment.center,
                              margin: const  EdgeInsets.only(top: 10),
                              width: 340,
                              height: 30,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.black,
                                      ),
                                      Text(snapshot
                                          .child('date')
                                          .value
                                          .toString()),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.watch_later_outlined,
                                        color: Colors.black,
                                      ),
                                      Text(snapshot
                                          .child('time')
                                          .value
                                          .toString()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
        
                            // Modify button based on what you need
        
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Accept button
                                  ElevatedButton.icon(
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color(0xFFFF9343)),
                                      fixedSize:
                                          MaterialStatePropertyAll(Size(100, 20)),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)))),
                                    ),
                                    icon: const Icon(Icons.check,
                                        size: 17, color: Colors.white),
                                    label: const Text(
                                      'Accept',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    onPressed: () async {
                                      await appointmentsRef
                                          .child(appointID)
                                          .update({
                                        'requestStatusProfessor':
                                            "$profID-UPCOMING",
                                        'status': "$studID-UPCOMING",
                                        'requestStatus': "UPCOMING",
                                        // 'profilePicStatus':
                                      });
                                    },
                                  ),
                                  // Reschedule button
                                  ElevatedButton.icon(
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color(0xFFFF9343)),
                                      fixedSize:
                                          MaterialStatePropertyAll(Size(100, 20)),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)))),
                                    ),
                                    icon: const Icon(Icons.calendar_month,
                                        size: 17, color: Colors.white),
                                    label: const Text(
                                      'Reschedule',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Reschedule'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _dateController,
                                                        onTap: _showDatePicker,
                                                        readOnly: true,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Select appointment date',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _timeController,
                                                        onTap: _showTimePicker,
                                                        readOnly: true,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Select appointment time',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () async {
                                                  await appointmentsRef
                                                      .child(appointID.toString())
                                                      .update({
                                                    "countered": "yes",
                                                    "requestStatusProfessor":
                                                        "$profID-RESCHEDULE",
                                                    "counteredDate":
                                                        _dateController.text,
                                                    "counteredTime":
                                                        _timeController.text,
                                                    "requestStatus": "RESCHEDULE",
                                                  });
        
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  // Reject button
                                  ElevatedButton.icon(
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color(0xFFFF9343)),
                                      fixedSize:
                                          MaterialStatePropertyAll(Size(80, 20)),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)))),
                                    ),
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 17, color: Colors.white),
                                    label: const Text(
                                      'Reject',
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String profNotes = '';
        
                                            return AlertDialog(
                                              title: const Text(
                                                  'State your reason.'),
                                              content: TextField(
                                                onChanged: (value) {
                                                  profNotes = value;
                                                },
                                                maxLines: null,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                decoration: const InputDecoration(
                                                  hintText:
                                                      'Enter your paragraph',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () async {
                                                    await appointmentsRef
                                                        .child(
                                                            appointID.toString())
                                                        .update({
                                                      'notes': profNotes,
                                                      'requestStatusProfessor':
                                                          "$profID-CANCELED",
                                                      'status':
                                                          "$studID-CANCELED",
                                                      'requestStatus': "CANCELED",
                                                    });
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchBox({required this.onSearch, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/30,
      right:MediaQuery.of(context).size.width/30
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search, color: Color(0xFFFF9343),),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        onChanged: widget.onSearch,
      ),
    );
  }
}
