import 'dart:async';
import 'dart:io';
import 'package:appointify/view/student/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  bool isEmptyPending = true;
  bool isEmptyUpcoming = true;
  bool isEmptyCompleted = true;
  bool isEmptyCanceled = true;
  String name = '';
  String picRef = '';
  StreamSubscription<DatabaseEvent>? nameSubscription,
      picSubscription,
      emptyPendingSubscription,
      emptyUpcomingSubscription,
      emptyCompletedSubscription,
      emptyCanceledSubscription;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    picSubscription?.cancel();
    emptyPendingSubscription?.cancel();
    emptyUpcomingSubscription?.cancel();
    emptyCompletedSubscription?.cancel();
    emptyCanceledSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference nameRef =
        FirebaseDatabase.instance.ref().child('students/$userID/firstName');
    nameSubscription = nameRef.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            name = event.snapshot.value.toString();
            isLoading = false;
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    // Database references and queries for empty views
    DatabaseReference emptyPendingRef =
        FirebaseDatabase.instance.ref('appointments');
    Query emptyPendingQuery = emptyPendingRef
        .orderByChild('status')
        .startAt("$userID-PENDING")
        .endAt("$userID-PENDING\uf8ff");
    Query emptyUpcomingQuery = emptyPendingRef
        .orderByChild('status')
        .startAt("$userID-UPCOMING")
        .endAt("$userID-UPCOMING\uf8ff");
    Query emptyCompletedQuery = emptyPendingRef
        .orderByChild('status')
        .startAt("$userID-COMPLETED")
        .endAt("$userID-COMPLETED\uf8ff");
    Query emptyCanceledQuery = emptyPendingRef
        .orderByChild('status')
        .startAt("$userID-CANCELED")
        .endAt("$userID-CANCELED\uf8ff");

    emptyPendingSubscription = emptyPendingQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyPending = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
    emptyUpcomingSubscription = emptyUpcomingQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyUpcoming = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
    emptyCompletedSubscription = emptyCompletedQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyCompleted = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
    emptyCanceledSubscription = emptyCanceledQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyCanceled = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    DatabaseReference appointmentsRef =
        FirebaseDatabase.instance.ref('appointments');
    DatabaseReference employeesRef =
        FirebaseDatabase.instance.ref('professors/');

    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                const SizedBox(
                  width: 350,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hi, $name!",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GothamRnd"),
                      ),
                    )),
                const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ready to Set an Appointment?",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GothamRnd"),
                      ),
                    )),
                const SizedBox(height: 10),
                Container(width: 350, height: 1, color: Colors.black),
                const SizedBox(height: 10),
                const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Status of Request",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GothamRnd"),
                      ),
                    )),
                const SizedBox(height: 10),
                if (isEmptyPending)
                  const SizedBox(
                    // color: Colors.red,
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No Available Data",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "GothamRnd"),
                        ),
                      ],
                    ),
                  ),
                if (!isEmptyPending)
                  Flexible(
                    child: SizedBox(
                      width: 350,
                      child: FirebaseAnimatedList(
                        query: appointmentsRef
                            .orderByChild('status')
                            .startAt("$userID-PENDING")
                            .endAt("$userID-PENDING\uf8ff"),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, snapshot, animation, index) {
                          DatabaseReference employees2Ref =
                              FirebaseDatabase.instance.ref(
                                  'professors/${snapshot.child('professorID').value.toString()}');
                          String inputDate =
                              snapshot.child("date").value.toString();
                          DateTime dateTime =
                              DateFormat('MMM dd, yyyy').parse(inputDate);
                          String outputDate =
                              DateFormat('MM-dd-yyyy').format(dateTime);
                          String inputTime =
                              snapshot.child("time").value.toString();
                          DateTime time = DateFormat('h:mm a').parse(inputTime);
                          String outputTime = DateFormat('HH:mm').format(time);
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String counteredInputDate = snapshot
                                      .child("counteredDate")
                                      .value
                                      .toString();
                                  String counteredInputTime = snapshot
                                      .child("counteredTime")
                                      .value
                                      .toString();
                                  return AlertDialog(
                                    titlePadding: const EdgeInsets.all(0),
                                    title: Container(
                                      height: 70,
                                      padding: const EdgeInsets.all(20),
                                      color: const Color(0xFF274C77),
                                      child: Text(
                                        snapshot
                                                    .child('countered')
                                                    .value
                                                    .toString() ==
                                                "no"
                                            ? snapshot
                                                .child('requestStatus')
                                                .value
                                                .toString()
                                            : "Reschedule",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: "GothamRnd",
                                            color: Colors.white),
                                      ),
                                    ),
                                    content: SizedBox(
                                      height:
                                          200, // Set the desired height here
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Professor name:',
                                            style: TextStyle(
                                                fontFamily: "GothamRnd"),
                                          ),
                                          Center(
                                            child: Text(
                                              snapshot
                                                  .child('professorName')
                                                  .value
                                                  .toString(),
                                              style: const TextStyle(
                                                fontFamily: "GothamRnd",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Designation:',
                                            style: TextStyle(
                                                fontFamily: "GothamRnd"),
                                          ),
                                          Center(
                                            child: Text(
                                              snapshot
                                                  .child('professorRole')
                                                  .value
                                                  .toString(),
                                              style: const TextStyle(
                                                fontFamily: "GothamRnd",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Requested Appointment:',
                                            style: TextStyle(
                                                fontFamily: "GothamRnd"),
                                          ),
                                          Center(
                                            child: Text(
                                              '${snapshot.child('date').value} - ${snapshot.child('time').value}',
                                              style: const TextStyle(
                                                fontFamily: "GothamRnd",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          if (snapshot
                                                  .child('countered')
                                                  .value ==
                                              "yes")
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Counter Proposal:',
                                                  style: TextStyle(
                                                      fontFamily: "GothamRnd"),
                                                ),
                                                Center(
                                                  child: Text(
                                                    '${snapshot.child('counteredDate').value} - ${snapshot.child('counteredTime').value}',
                                                    style: const TextStyle(
                                                      fontFamily: "GothamRnd",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (snapshot
                                                  .child('countered')
                                                  .value ==
                                              "yes")
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF274C77),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Adjust the radius as needed
                                                  ),
                                                ),
                                                child: const Text("Accept"),
                                                onPressed: () async {
                                                  DateTime dateTime = DateFormat(
                                                          'MMM dd, yyyy')
                                                      .parse(
                                                          counteredInputDate);
                                                  String outputDate =
                                                      DateFormat('MM-dd-yyyy')
                                                          .format(dateTime);

                                                  DateTime time = DateFormat(
                                                          'h:mm a')
                                                      .parse(
                                                          counteredInputTime);
                                                  String outputTime =
                                                      DateFormat('HH:mm')
                                                          .format(time);
                                                  await appointmentsRef
                                                      .child(snapshot
                                                          .child('appointID')
                                                          .value
                                                          .toString())
                                                      .update({
                                                    "requestStatus": "UPCOMING",
                                                    "date": snapshot
                                                        .child('counteredDate')
                                                        .value
                                                        .toString(),
                                                    "time": snapshot
                                                        .child('counteredTime')
                                                        .value
                                                        .toString(),
                                                    "requestStatusProfessor":
                                                        "${snapshot.child('professorID').value}-UPCOMING-$outputDate:$outputTime",
                                                    "status":
                                                        "$userID-UPCOMING-$outputDate:$outputTime",
                                                    "countered": "no",
                                                  });
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pop();
                                                }),
                                          if (snapshot
                                                  .child('countered')
                                                  .value ==
                                              "yes")
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF6096BA),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Adjust the radius as needed
                                                  ),
                                                ),
                                                child: const Text("Reject"),
                                                onPressed: () async {
                                                  await appointmentsRef
                                                      .child(snapshot
                                                          .child('appointID')
                                                          .value
                                                          .toString())
                                                      .update({
                                                    "requestStatus": "CANCELED",
                                                    "requestStatusProfessor":
                                                        "${snapshot.child('professorID').value}-CANCELED-$outputDate:$outputTime",
                                                    "status":
                                                        "$userID-CANCELED-$outputDate:$outputTime",
                                                  });
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pop();
                                                })
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            // Status of request list
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2.5,
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: StreamBuilder(
                                        stream: employees2Ref.onValue,
                                        builder:
                                            (context, AsyncSnapshot snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasData) {
                                            // Getting values from database
                                            Map<dynamic, dynamic> map =
                                                snapshot.data.snapshot.value;

                                            String profilePicStatus =
                                                map['profilePicStatus']
                                                    .toString();
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 0),
                                              child: Center(
                                                child: Container(
                                                  height: 70,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 35, 35, 35),
                                                        width: 2,
                                                      )),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: ProfileController()
                                                                  .image ==
                                                              null
                                                          ? map['profilePicStatus']
                                                                      .toString() ==
                                                                  "None"
                                                              ? const Icon(
                                                                  Icons.person,
                                                                  size: 20,
                                                                )
                                                              : Image(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image: NetworkImage(
                                                                      profilePicStatus),
                                                                  loadingBuilder:
                                                                      (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null) {
                                                                      return child;
                                                                    }
                                                                    return const CircularProgressIndicator();
                                                                  },
                                                                  errorBuilder:
                                                                      (context,
                                                                          object,
                                                                          stack) {
                                                                    return const Icon(
                                                                      Icons
                                                                          .error_outline,
                                                                      color: Color.fromARGB(
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
                                              ),
                                            );
                                          } else {
                                            return const Center(
                                                child: Text(
                                              'Something went wrong.',
                                            ));
                                          }
                                        },
                                      ),
                                    ),
                                    Text(
                                      snapshot
                                          .child('professorName')
                                          .value
                                          .toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: const TextStyle(
                                        color: Color(0xFF6096BA),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: "GothamRnd",
                                      ),
                                    ),
                                    Text(
                                      style: const TextStyle(
                                        color: Color(0xFF6096BA),
                                      ),
                                      snapshot
                                          .child('professorRole')
                                          .value
                                          .toString(),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      alignment: Alignment.center,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              35,
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF274C77),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight:
                                                  Radius.circular(20))),
                                      child: Text(
                                        snapshot
                                                    .child('countered')
                                                    .value
                                                    .toString() ==
                                                "no"
                                            ? snapshot
                                                .child('requestStatus')
                                                .value
                                                .toString()
                                            : "RESCHEDULE",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "GothamRnd",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Appointment",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GothamRnd"),
                      ),
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  height: 350,
                  width: 350,
                  child: ContainedTabBarView(
                    tabs: const [
                      Text(
                        'Upcoming',
                        style: TextStyle(fontSize: 15, fontFamily: "GothamRnd"),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(fontSize: 15, fontFamily: "GothamRnd"),
                      ),
                      Text(
                        'Canceled',
                        style: TextStyle(fontSize: 15, fontFamily: "GothamRnd"),
                      ),
                    ],
                    tabBarProperties: TabBarProperties(
                      width: 360,
                      height: 50,
                      indicator: const ContainerTabIndicator(
                        color: Color(0xFF6096BA),
                        radius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(1, -1),
                            ),
                          ],
                        ),
                      ),
                      position: TabBarPosition.top,
                      alignment: TabBarAlignment.center,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black38,
                    ),
                    views: [
                      // Tab for Upcoming
                      if (isEmptyUpcoming)
                        const SizedBox(
                          // color: Colors.red,
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No Available Data",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "GothamRnd"),
                              ),
                            ],
                          ),
                        ),
                      if (!isEmptyUpcoming)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            child: SizedBox(
                              width: 350,
                              height: 300,
                              child: FirebaseAnimatedList(
                                query: appointmentsRef
                                    .orderByChild('status')
                                    .startAt("$userID-UPCOMING")
                                    .endAt("$userID-UPCOMING\uf8ff"),
                                itemBuilder:
                                    (context, snapshot, animation, index) {
                                  String employeeName = snapshot
                                      .child('professorName')
                                      .value
                                      .toString();
                                  String employeePosition = snapshot
                                      .child('professorRole')
                                      .value
                                      .toString();
                                  String schedDate =
                                      snapshot.child('date').value.toString();
                                  String schedTime =
                                      snapshot.child('time').value.toString();
                                  return SizedBox(
                                      height: 100,
                                      child: Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          color: Colors.white,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: FirebaseAnimatedList(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  query: employeesRef
                                                      .orderByChild(
                                                          'profUserID')
                                                      .equalTo(snapshot
                                                          .child('professorID')
                                                          .value
                                                          .toString()),
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder: (context,
                                                      snapshot,
                                                      animation,
                                                      index) {
                                                    return SizedBox(
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15,
                                                                    top: 15),
                                                            child: Container(
                                                              height: 60,
                                                              width: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            35,
                                                                            35,
                                                                            35),
                                                                        width:
                                                                            2,
                                                                      )),
                                                              child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  child: ProfileController()
                                                                              .image ==
                                                                          null
                                                                      ? snapshot.child('profilePicStatus').value.toString() ==
                                                                              "None"
                                                                          ? const Icon(
                                                                              Icons.person,
                                                                              size: 35,
                                                                            )
                                                                          : Image(
                                                                              fit: BoxFit.cover,
                                                                              image: NetworkImage(snapshot.child('profilePicStatus').value.toString()),
                                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                                if (loadingProgress == null) {
                                                                                  return child;
                                                                                }
                                                                                return const CircularProgressIndicator();
                                                                              },
                                                                              errorBuilder: (context, object, stack) {
                                                                                return const Icon(
                                                                                  Icons.error_outline,
                                                                                  color: Color.fromARGB(255, 35, 35, 35),
                                                                                );
                                                                              },
                                                                            )
                                                                      : Image.file(File(ProfileController()
                                                                              .image!
                                                                              .path)
                                                                          .absolute)),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                employeeName,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        "GothamRnd"),
                                                              ),
                                                              Text(
                                                                employeePosition,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        "GothamRnd"),
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    35,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.8,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              2),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      schedDate,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontFamily:
                                                                              "GothamRnd"),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      schedTime,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontFamily:
                                                                              "GothamRnd"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )));
                                },
                              ),
                            ),
                          ),
                        ),

                      // Tab for Completed
                      if (isEmptyCompleted)
                        const SizedBox(
                          // color: Colors.red,
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No Available Data",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "GothamRnd"),
                              ),
                            ],
                          ),
                        ),
                      if (!isEmptyCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            child: SizedBox(
                              width: 350,
                              height: 300,
                              child: FirebaseAnimatedList(
                                query: appointmentsRef
                                    .orderByChild('status')
                                    .startAt("$userID-COMPLETED")
                                    .endAt("$userID-COMPLETED\uf8ff"),
                                itemBuilder:
                                    (context, snapshot, animation, index) {
                                  String employeeName = snapshot
                                      .child('professorName')
                                      .value
                                      .toString();
                                  String employeePosition = snapshot
                                      .child('professorRole')
                                      .value
                                      .toString();
                                  String schedDate =
                                      snapshot.child('date').value.toString();
                                  String schedTime =
                                      snapshot.child('time').value.toString();
                                  return SizedBox(
                                      height: 100,
                                      child: Card(
                                          elevation: 5,
                                          color: Colors.white,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: FirebaseAnimatedList(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  query: employeesRef
                                                      .orderByChild(
                                                          'profUserID')
                                                      .equalTo(snapshot
                                                          .child('professorID')
                                                          .value
                                                          .toString()),
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder: (context,
                                                      snapshot,
                                                      animation,
                                                      index) {
                                                    return SizedBox(
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15,
                                                                    top: 15),
                                                            child: Container(
                                                              height: 60,
                                                              width: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            35,
                                                                            35,
                                                                            35),
                                                                        width:
                                                                            2,
                                                                      )),
                                                              child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  child: ProfileController()
                                                                              .image ==
                                                                          null
                                                                      ? snapshot.child('profilePicStatus').value.toString() ==
                                                                              "None"
                                                                          ? const Icon(
                                                                              Icons.person,
                                                                              size: 35,
                                                                            )
                                                                          : Image(
                                                                              fit: BoxFit.cover,
                                                                              image: NetworkImage(snapshot.child('profilePicStatus').value.toString()),
                                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                                if (loadingProgress == null) {
                                                                                  return child;
                                                                                }
                                                                                return const CircularProgressIndicator();
                                                                              },
                                                                              errorBuilder: (context, object, stack) {
                                                                                return const Icon(
                                                                                  Icons.error_outline,
                                                                                  color: Color.fromARGB(255, 35, 35, 35),
                                                                                );
                                                                              },
                                                                            )
                                                                      : Image.file(File(ProfileController()
                                                                              .image!
                                                                              .path)
                                                                          .absolute)),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                employeeName,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        "GothamRnd",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                  employeePosition,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          "GothamRnd")),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    35,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.8,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              2),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                        schedDate,
                                                                        style: const TextStyle(
                                                                            fontFamily:
                                                                                "GothamRnd")),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                        schedTime,
                                                                        style: const TextStyle(
                                                                            fontFamily:
                                                                                "GothamRnd")),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )));
                                },
                              ),
                            ),
                          ),
                        ),

                      // Tab for Canceled
                      if (isEmptyCanceled)
                        const SizedBox(
                          // color: Colors.red,
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No Available Data",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "GothamRnd"),
                              ),
                            ],
                          ),
                        ),
                      if (!isEmptyCanceled)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            child: SizedBox(
                              width: 350,
                              height: 300,
                              child: FirebaseAnimatedList(
                                query: appointmentsRef
                                    .orderByChild('status')
                                    .startAt("$userID-CANCELED")
                                    .endAt("$userID-CANCELED\uf8ff"),
                                itemBuilder:
                                    (context, snapshot, animation, index) {
                                  String employeeName = snapshot
                                      .child('professorName')
                                      .value
                                      .toString();
                                  String employeePosition = snapshot
                                      .child('professorRole')
                                      .value
                                      .toString();
                                  String schedDate =
                                      snapshot.child('date').value.toString();
                                  String schedTime =
                                      snapshot.child('time').value.toString();
                                  return SizedBox(
                                      height: 100,
                                      child: GestureDetector(
                                        onTap: () {
                                          String profNotes = snapshot
                                              .child('notes')
                                              .value
                                              .toString();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  titlePadding:
                                                      const EdgeInsets.all(0),
                                                  title: Container(
                                                    height: 70,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    color:
                                                        const Color(0xFF274C77),
                                                    child: const Text(
                                                      'Professor Note',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily:
                                                              "GothamRnd",
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  content: Text(profNotes),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text('Close',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "GothamRnd")),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Card(
                                            elevation: 5,
                                            color: Colors.white,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: FirebaseAnimatedList(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    query: employeesRef
                                                        .orderByChild(
                                                            'profUserID')
                                                        .equalTo(snapshot
                                                            .child(
                                                                'professorID')
                                                            .value
                                                            .toString()),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemBuilder: (context,
                                                        snapshot,
                                                        animation,
                                                        index) {
                                                      return SizedBox(
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15,
                                                                      top: 15),
                                                              child: Container(
                                                                height: 60,
                                                                width: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border:
                                                                            Border.all(
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              35,
                                                                              35,
                                                                              35),
                                                                          width:
                                                                              2,
                                                                        )),
                                                                child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(100),
                                                                    child: ProfileController().image == null
                                                                        ? snapshot.child('profilePicStatus').value.toString() == "None"
                                                                            ? const Icon(
                                                                                Icons.person,
                                                                                size: 35,
                                                                              )
                                                                            : Image(
                                                                                fit: BoxFit.cover,
                                                                                image: NetworkImage(snapshot.child('profilePicStatus').value.toString()),
                                                                                loadingBuilder: (context, child, loadingProgress) {
                                                                                  if (loadingProgress == null) {
                                                                                    return child;
                                                                                  }
                                                                                  return const CircularProgressIndicator();
                                                                                },
                                                                                errorBuilder: (context, object, stack) {
                                                                                  return const Icon(
                                                                                    Icons.error_outline,
                                                                                    color: Color.fromARGB(255, 35, 35, 35),
                                                                                  );
                                                                                },
                                                                              )
                                                                        : Image.file(File(ProfileController().image!.path).absolute)),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            top:
                                                                                5,
                                                                            right:
                                                                                5),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .note_outlined,
                                                                          color:
                                                                              Color(0xFF6096BA),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                      employeeName,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              "GothamRnd",
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  Text(
                                                                      employeePosition,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              "GothamRnd")),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        35,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        1.8,
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      border: Border.all(
                                                                          width:
                                                                              2),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                            schedDate,
                                                                            style:
                                                                                const TextStyle(fontFamily: "GothamRnd")),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                            schedTime,
                                                                            style:
                                                                                const TextStyle(fontFamily: "GothamRnd")),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ));
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
