import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter1/services/firestore.dart';

class CategoryInfo extends StatefulWidget {
  @override
  _CategoryInfoState createState() => _CategoryInfoState();
}

class _CategoryInfoState extends State<CategoryInfo> {
  List<String> categories = ['Exhibit', 'Facility'];
  String selectedCategory = 'Exhibit';
  String? selectedExhibit;
  String? selectedExhibitDocID;
  List<Map<String, String>> exhibitList = [
    {'name': 'Exhibit 0', 'docID': 'exhibit0'}
    ];
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchExhibits();
  }

  void fetchExhibits() async {
    var exhibitsCollection = FirebaseFirestore.instance.collection('exhibits');
    var snapshot = await exhibitsCollection.get();
    var fetchedExhibits = snapshot.docs.map((doc) {
      return {
        'name': doc.data()['exhibitName'].toString(),
        'docID': doc.id
      };
    }).toList();

    setState(() {
      exhibitList = fetchedExhibits.cast<Map<String, String>>();
      if (exhibitList.isNotEmpty) {
        selectedExhibit = exhibitList[0]['name']!;
        selectedExhibitDocID = exhibitList[0]['docID']!;
      } else {
        selectedExhibit = 'Exhibit 1';
        selectedExhibitDocID = 'exhibit1';
      }
    });
  }


  Stream<List<DocumentSnapshot>> getAnimalsFromExhibitSelected(String exhibitName) async* {
    var exhibitQuerySnapshot = await FirebaseFirestore.instance
        .collection('exhibits')
        .where('exhibitName', isEqualTo: exhibitName)
        .limit(1)
        .get();

    if (exhibitQuerySnapshot.docs.isNotEmpty) {
      var exhibitRef = exhibitQuerySnapshot.docs.first.reference;

      yield* FirebaseFirestore.instance
          .collection('animals')
          .where('exhibitRef', isEqualTo: exhibitRef)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      yield [];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        color: Color(0xFFA7AE9C),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 8, left: 30, right: 30), 
              child: Center( 
                child: Text(
                  'MANAGE INFORMATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'Bobby Jones',
                    letterSpacing: 3.0,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30,bottom: 8, left: 30, right: 8),
              child: Text('Choose category:', 
              style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17),),
            ),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 15, left: 30, right: 30),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 7.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: categories.map((category) => Expanded(
                    child: ListTile(
                      title: Text(category,
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.start,
                      ),
                      leading: Radio<String>(
                        value: category,
                        groupValue: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),

            if (selectedCategory == "Exhibit")
            const Padding(
              padding: EdgeInsets.only(top: 10,bottom: 8, left: 30, right: 8),
              child: Text('Choose exhibit:', 
              style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17),),
            ),
            
            if (selectedCategory == "Exhibit")
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 15, left: 30, right: 30),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<Map<String, String>>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.0),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFEFF5F6),
                        ),
                        value: exhibitList.firstWhere((item) => item['name'] == selectedExhibit, orElse: () => exhibitList[0]),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF44552C)),
                        iconSize: 40,
                        style: const TextStyle(color: Colors.black),
                        onChanged: (Map<String, String>? newValue) {
                          setState(() {
                            selectedExhibit = newValue!['name']!;
                            selectedExhibitDocID = newValue['docID']!;
                          });
                        },
                        items: exhibitList.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> value) {
                          return DropdownMenuItem<Map<String, String>>(
                            value: value,
                            child: Text(value['name']!, style: const TextStyle(fontSize: 15.0)),
                          );
                        }).toList(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF44552C)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/exhibitinfo', arguments: selectedExhibitDocID);
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (selectedCategory == "Exhibit" && selectedExhibit != null)
            const Padding(
              padding: EdgeInsets.only(top: 10,bottom: 8, left: 30, right: 8),
              child: Text('Select from list:',
              style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17),),
            ),

            if (selectedCategory == "Exhibit" && selectedExhibit != null)
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: getAnimalsFromExhibitSelected(selectedExhibit!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var animalsList = snapshot.data!;
                      return ListView.builder(
                        itemCount: animalsList.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = animalsList[index];
                          String docID = document.id;
                          var doc = animalsList[index];
                          var data = doc.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 30.0),
                            elevation: 0,
                            child: ListTile(
                              title: Text(data['animalName'],
                              style: const TextStyle(fontSize: 15.0)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/animalinfo', arguments: docID);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Text("No animals found for this exhibit");
                    }
                  },
                ),
              ),
            
            if (selectedCategory == "Facility")

            const Padding(
              padding: EdgeInsets.only(top: 10,bottom: 8, left: 30, right: 8),
              child: Text('Select from list:', 
              style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17),),
            ),

            if (selectedCategory == "Facility")

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getFacilitiesStream(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    List facilitiesList = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: facilitiesList.length,
                      itemBuilder: (context, index){
                        DocumentSnapshot document = facilitiesList[index];
                        String docID = document.id;

                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                        if (data['facilityName'] != null) {
                          String facilityText = data['facilityName'];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 30.0),
                            elevation: 0,
                            child: ListTile(
                              title: Text(facilityText,
                              style: TextStyle(fontSize: 15.0)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/facilityinfo', arguments: docID);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    );
                  }
                  else{
                    return const Text("No facilities...");
                  }
                },
              )
            )
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }
}
