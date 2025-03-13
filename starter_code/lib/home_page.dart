import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/add_new_task.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widgets/date_selector.dart';
import 'package:frontend/widgets/task_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTask(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),
        ],
      ),
      // THIS CONTAIN STREAM THAT REBUILD ACCORDING TO CHANGES IN DATABASE, SUPPORT REAL TIME DATA ACCESS
      body: Center(
        child: Column(
          children: [
            const DateSelector(),
            StreamBuilder(
              // Fetches data in real time
              stream: FirebaseFirestore.instance
                  .collection("tasks")
                  .where("creator",
                      isEqualTo: FirebaseAuth.instance.currentUser!
                          .uid) //Fetch docs, where creator has currentUser id. Filtered docs based on Users
                  .snapshots(),
              /* QuerySnapshot → Represents multiple documents from a Firestore query.
              DocumentSnapshot → Represents a single document from Firestore.*/
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text("No data here :()");
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: ValueKey(index),
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            await FirebaseFirestore.instance
                                .collection("tasks")
                                .doc(snapshot.data!.docs[index]
                                    .id) // Delete doc based on id
                                .delete();
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: TaskCard(
                                color: hexToColor(
                                  snapshot.data!.docs[index]
                                      .data()['color']
                                      .toString(),
                                ),
                                headerText:
                                    snapshot.data!.docs[index].data()['title'],
                                descriptionText: snapshot.data!.docs[index]
                                    .data()['description'],
                                scheduledDate: snapshot.data!.docs[index]
                                    .data()['date']
                                    .toString(),
                              ),
                            ),
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: strengthenColor(
                                  const Color.fromRGBO(246, 222, 194, 1),
                                  0.69,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                '10:00AM',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // THIS CONTAIN FUTUREBUILDER, ONLY FETCH DATA WHEN APP STARTED AND DOES NOT SUPPORT REALTIME DATA ACCESS
      // body: Center(
      //   child: Column(
      //     children: [
      //       const DateSelector(),
      //       FutureBuilder(
      //         // Fetches data once and does not listen for changes. It only Fetches when we restart app
      //         // That means it does not Fetch data in real time
      //         future: FirebaseFirestore.instance.collection("tasks").get(),
      //         /* QuerySnapshot → Represents multiple documents from a Firestore query.
      //         DocumentSnapshot → Represents a single document from Firestore.*/
      //         builder: (context, snapshot) {
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return const Center(
      //               child: CircularProgressIndicator(),
      //             );
      //           }
      //           if (!snapshot.hasData) {
      //             return const Text("No data here :()");
      //           }
      //           return Expanded(
      //             child: ListView.builder(
      //               itemCount: snapshot.data!.docs.length,
      //               itemBuilder: (context, index) {
      //                 return Row(
      //                   children: [
      //                     Expanded(
      //                       child: TaskCard(
      //                         color: hexToColor(
      //                           snapshot.data!.docs[index]
      //                               .data()['color']
      //                               .toString(),
      //                         ),
      //                         headerText:
      //                             snapshot.data!.docs[index].data()['title'],
      //                         descriptionText: snapshot.data!.docs[index]
      //                             .data()['description'],
      //                         scheduledDate: snapshot.data!.docs[index]
      //                             .data()['date']
      //                             .toString(),
      //                       ),
      //                     ),
      //                     Container(
      //                       height: 10,
      //                       width: 10,
      //                       decoration: BoxDecoration(
      //                         color: strengthenColor(
      //                           const Color.fromRGBO(246, 222, 194, 1),
      //                           0.69,
      //                         ),
      //                         shape: BoxShape.circle,
      //                       ),
      //                     ),
      //                     const Padding(
      //                       padding: EdgeInsets.all(12.0),
      //                       child: Text(
      //                         '10:00AM',
      //                         style: TextStyle(
      //                           fontSize: 17,
      //                         ),
      //                       ),
      //                     )
      //                   ],
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
