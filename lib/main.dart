// import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_distributor/countdown_page.dart';
import 'package:food_distributor/details.dart';
import 'package:food_distributor/refugees.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

@immutable
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: "Camp Food Distro",
      home: RefugeePage(),
      
    );
  }
}

class RefugeePage extends StatelessWidget {
  // RefugeePage({Key? key}) : super(key: key);
  final _controller = TextEditingController();

  TextEditingController searchTextController = TextEditingController();
  // Future<QuerySnapshot> futureSearchResults;

  emptyTheTextFormField() {
    searchTextController.clear();
  }

  controlSearching(String str) {
    Stream<QuerySnapshot<Map<String, dynamic>>> allUsers = FirebaseFirestore
        .instance
        .collection("Refugees")
        .where("name", isGreaterThanOrEqualTo: str)
        .snapshots();
    // setState(() {
    //   Future<QuerySnapshot> futureSearchResults = allUsers as Future<QuerySnapshot<Object?>>;
    // })
    setState(() {
      // futureSearchResults = allUsers as Future<QuerySnapshot<Object?>>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: const Text("Camp List"), //home title
          title: TextFormField(
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
            controller: searchTextController,
            decoration: const InputDecoration(
              hintText: "Search Camp List... ",
              hintStyle: TextStyle(color: Colors.cyan),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              // prefixText: "Camp List",
              prefixIcon:
                  Icon(Icons.person_pin, color: Colors.white, size: 30.0,),
              // suffixIcon: IconButton(
              //   onPressed:
              //   Navigator.push(context, MaterialPageRoute(
              //       builder: (context) => CountdownPage(
                      
              //           ),)),
              //     icon: Icon(
              //     Icons.clear,
              //     color: Colors.white,
              //   ),
              // ),
            ),
            onFieldSubmitted: controlSearching,
          ),
        ),
        body: 
        // futureSearchResults == null ? 
        displayAllUsers(context)
        // : displayUsersFoundScreen()
        );
  }

  displayAllUsers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(children: [
          //food srving countdown
          TextButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => 
                const CountdownPage()),
            );
            },
            child: const Text(
              "Count",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black87,
            ),),
          // text box to enter refugee name
          Expanded(
              child: TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Add New Camp Member (Name)"),
          )),
          //to save the name on database (ony name for now)
          TextButton(
            onPressed: () {
              _saveTask();
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ), // color: Colors.blue,
          ),

        ]),
        //show list of saved refugees
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("Refugees").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return Expanded(
              child: _buildList(snapshot.requireData),
            );
          },
        )
      ]),
    );
  }

  //save name function called at button click to save refugee name
  void _saveTask() {
    final refugeeName = _controller.text;
    double _points = 0;
    double totalPoints = 0;

    //save name and put default for unfilled fields
    FirebaseFirestore.instance.collection("Refugees").add({
      "name": refugeeName,
      "Address": "-",
      "Points": _points,
      "Total Point": totalPoints,
      "Age": "-",
      "weight": "-",
      "Gender": "-",
      "Contribution": "-",
    });

    _controller.clear();
  }

  //buildlist function called in StreamBuilder to display refugee list
  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.docs[index];

          return Dismissible(
            key: Key(doc.id),
            background: Container(
              color: Colors.red, //colour on slide deleting
            ),
            onDismissed: (direction) {
              //delete doc from database by sliding sideways
              FirebaseFirestore.instance
                  .collection("Refugees")
                  .doc(doc.id)
                  .delete();
            },
            //navigate to more refugee details on name click
            child: ListTile(
              title: Text(doc["name"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //passing refugee name and id along...
                    builder: (context) => DetailScreen(
                        refugee: Refugee(doc["name"]), refugeeid: doc.id),
                  ),  
                );
              },
            ),
          );
        });
  }

  Widget _searchList(QuerySnapshot snapshot) {
    return ListView.builder(
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.docs[index];

          List<Widget> searchedUsersResults = [];
          if (doc["name"].toString().startsWith(searchTextController.text)) {
            searchedUsersResults.add(doc["name"]);
          }

        return ListView(children: searchedUsersResults);

          // return Dismissible(
          //   key: Key(doc.id),
          //   background: Container(
          //     color: Colors.red, //colour on slide deleting
          //   ),
          //   onDismissed: (direction) {
          //     //delete doc from database by sliding sideways
          //     FirebaseFirestore.instance
          //         .collection("Refugees")
          //         .doc(doc.id)
          //         .delete();
          //   },
          //   //navigate to more refugee details on name click
          //   child: ListTile(
          //     title: Text(doc["name"]),
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           //passing refugee name and id along...
          //           builder: (context) => DetailScreen(
          //               refugee: Refugee(doc["name"]), refugeeid: doc.id),
          //         ),
          //       );
          //     },
          //   ),
          // );
        
        });
  }

  void setState(Null Function() param0) {}

  displayUsersFoundScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Refugees").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return Expanded(
          child: _searchList(snapshot.requireData),
        );
      },
    );
  }
}
