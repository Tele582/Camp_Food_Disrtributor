// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_distributor/refugees.dart';

class DetailScreen extends StatelessWidget {
  // In the constructor, require a Refugee.
  DetailScreen({
    Key? key,
    required this.refugee,
    required this.refugeeid,
  }) : super(key: key);

  // Declare field that holds the Refugee.
  final Refugee refugee;
  final String refugeeid;
  //text field controllers for editing other refugee user fields
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();
  final _controller3 = TextEditingController();
  final _controller4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Use the 'Refugee' to create the UI.

    return Scaffold(
      appBar: AppBar(
        //page title
        title: Text(refugee.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          //input refugee age
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: "Age (Years)"),
              ),
            ),
          ]),
          //input refugee weight
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller2,
                decoration: const InputDecoration(hintText: "Weight (kg)"),
              ),
            ),
          ]),
          //input refugee gender
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller3,
                decoration: const InputDecoration(hintText: "Gender (M/F)"),
              ),
            ),
          ]),
          //input refugee conribution
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller4,
                decoration: const InputDecoration(hintText: "Contribution"),
              ),
            ),
          ]),
          //save other added refugee details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                _saveRest();
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ), // color: Colors.blue,
            ),
          ),

          // // i used this to test the function.
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextButton(
          //     onPressed: () {
          //       addPoints();
          //     },
          //     child: const Text(
          //       "Testing",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     style: TextButton.styleFrom(
          //       backgroundColor: Colors.blue,
          //     ), // color: Colors.blue,
          //   ),
          // ),

          // reading other refugee data fields from firestore (database)
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("Refugees")
                .doc(refugeeid)
                .snapshots(),
            builder: (_, snapshot) {
              if (snapshot.hasError) return Text('Error = ${snapshot.error}');
              // data read
              if (snapshot.hasData) {
                var output = snapshot.data!.data();
                var refAge = output!['Age'];
                var refWt = output['weight'];
                var refGender = output['Gender'];
                var refContrib = output['Contribution'];
                var refPoints = output['Points'];

                //total Points initialized
                // double totalCampPoints = 0;

                // where i hopefully, intend to add all points to get totalCampPpoints

                addPoints();

                var totalCampPoints = addPoints();

                //calculate percentage of food to be received by refugee
                //using personal points divided by total Points..

                var percent = refPoints / totalCampPoints;

                //displaying read and calculated data
                return Text(
                    " Age = $refAge years \n Weight = $refWt kg \n Gender = $refGender \n Camp Contribution = $refContrib"
                    "\n\n Your Points: $refPoints \n\n [Total Camp Points: $totalCampPoints] \n\n You get $percent% of total camp's FOOD.");
              }

              return const Center(child: CircularProgressIndicator());
            },
          )
        ]),
      ),
    );
  }

  addPoints() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection("Refugees").get();
    var total = 0.0;
    final List<DocumentSnapshot> documents = result.docs;
    for (var data in documents) {
      var map = data.data() as Map;
      total = total + map['Points'];
    }
    // print(total);
    return total;
  }

  // function to save refugee details
  void _saveRest() {
    final refugeeAge = _controller.text;
    final refugeeWeight = _controller2.text;
    final refugeeGender = _controller3.text;
    final refugeeContib = _controller4.text;

    // assign points based on input data
    double points = 0;
    if (double.parse(refugeeAge) > 15) {
      points += 10;
    } else {
      points += 5;
    }
    if (double.parse(refugeeWeight) > 45) {
      points += 15;
    } else {
      points += 10;
    }
    if (refugeeGender.toLowerCase().startsWith("f")) {
      points += 10;
    } else if (refugeeGender.toLowerCase().startsWith("m")) {
      points += 12.5;
    }

    // total number of points per person (to be stored after)
    double finalPoints = points;

    FirebaseFirestore.instance.collection("Refugees").doc(refugeeid).update({
      "Age": refugeeAge,
      "weight": refugeeWeight,
      "Gender": refugeeGender,
      "Contribution": refugeeContib,
      "Points": finalPoints,
    });

    _controller.clear();
    _controller2.clear();
    _controller3.clear();
    _controller4.clear();
  }
}
