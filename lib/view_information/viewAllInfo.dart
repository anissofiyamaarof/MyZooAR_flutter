import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter1/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAnimalInfo extends StatefulWidget {
  final String docID;
  final String category;
  ViewAnimalInfo({Key? key, required this.docID, required this.category}) : super(key: key);
  
  @override
  _ViewAnimalInfoState createState() => _ViewAnimalInfoState();
}

class _ViewAnimalInfoState extends State<ViewAnimalInfo> {
  final FirestoreService firestoreService = FirestoreService();
  int _current = 0;
  List<String> animalImageUrls = [];
  List<String> exhibitImageUrls = [];
  List<String> facilityImageUrls = [];

  @override
  void initState() {
    super.initState();
    loadImageUrls();
  }

  void loadImageUrls() async {
    if (widget.category == 'Animal'){
      animalImageUrls = await firestoreService.getAnimalImages(widget.docID);
    }
    else if (widget.category == 'Exhibit'){
      exhibitImageUrls = await firestoreService.getExhibitImages(widget.docID);
    }
    else if (widget.category == 'Facility'){
      facilityImageUrls = await firestoreService.getFacilityImages(widget.docID);
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls;
    if (widget.category == 'Animal') {
      imageUrls = animalImageUrls;
    } else if (widget.category == 'Exhibit') {
      imageUrls = exhibitImageUrls;
    } else if (widget.category == 'Facility') {
      imageUrls = facilityImageUrls;
    } else {
      imageUrls = [];
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 5.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              if(widget.category == 'Animal')
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: firestoreService.getAnimalIndividual(widget.docID),
                  builder: (context, snapshot) { 
                    if(snapshot.hasData && snapshot.data!.data() != null){
                      DocumentSnapshot document = snapshot.data!;
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String animalName = data['animalName'] ?? '';

                    return Text(animalName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Bobby Jones',
                          letterSpacing: 3.0,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    else{
                      return const Text("Null");
                    }
                  },
                ),
              ),
              
              if(widget.category == 'Exhibit')
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: firestoreService.getExhibitIndividual(widget.docID),
                  builder: (context, snapshot) { 
                    if(snapshot.hasData && snapshot.data!.data() != null){
                      DocumentSnapshot document = snapshot.data!;
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String exhibitName = data['exhibitName'] ?? '';

                    return Text(exhibitName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Bobby Jones',
                          letterSpacing: 3.0,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    else{
                      return const Text("Null");
                    }
                  },
                ),
              ),

              if(widget.category == 'Facility')
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: firestoreService.getFacilityIndividual(widget.docID),
                  builder: (context, snapshot) { 
                    if(snapshot.hasData && snapshot.data!.data() != null){
                      DocumentSnapshot document = snapshot.data!;
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String facilityName = data['facilityName'] ?? '';

                    return Text(facilityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Bobby Jones',
                          letterSpacing: 3.0,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    else{
                      return const Text("Null");
                    }
                  },
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF44552C),
        ),
      ),
    
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20),
          imageUrls.isNotEmpty ? CarouselSlider(
            items: imageUrls.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              height: MediaQuery.of(context).size.height * 0.3,
              enableInfiniteScroll: true,
              aspectRatio: 2.0,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ): Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          ),
          SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageUrls.length, (index) => Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index ? Color(0xFF947021) : Colors.grey,
              ),
            )),
          ),
          SizedBox(height: 10),
          Container(
            height: 50,
            color: Color(0xFF947021),
            child: const Center(
              child: Text(
                'Get to know us!',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          if(widget.category == 'Animal')
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF947021),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: firestoreService.getAnimalIndividual(widget.docID),
                    builder: (context, snapshot) { 
                      if(snapshot.hasData && snapshot.data!.data() != null){
                        DocumentSnapshot document = snapshot.data!;
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String animalDesc = data['animalDesc'] ?? '';

                        return Text(animalDesc,
                          style: const TextStyle(fontSize: 15.0, color: Colors.white,),
                        );
                      }
                      else{
                        return const Text("Null");
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          if(widget.category == 'Exhibit')
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF947021),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: firestoreService.getExhibitIndividual(widget.docID),
                    builder: (context, snapshot) { 
                      if(snapshot.hasData && snapshot.data!.data() != null){
                        DocumentSnapshot document = snapshot.data!;
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String exhibitDesc = data['exhibitDesc'] ?? '';

                        return Text(exhibitDesc,
                          style: const TextStyle(fontSize: 15.0, color: Colors.white,),
                        );
                      }
                      else{
                        return const Text("Null");
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          if(widget.category == 'Facility')
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF947021),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: firestoreService.getFacilityIndividual(widget.docID),
                    builder: (context, snapshot) { 
                      if(snapshot.hasData && snapshot.data!.data() != null){
                        DocumentSnapshot document = snapshot.data!;
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String facilityDesc = data['facilityDesc'] ?? '';

                        return Text(facilityDesc,
                          style: const TextStyle(fontSize: 15.0, color: Colors.white,),
                        );
                      }
                      else{
                        return const Text("Null");
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
