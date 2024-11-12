import 'dart:async';
import 'dart:ui' as ui; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:flutter1/main_page/visitedLocation_list.dart';
import 'package:flutter1/services/firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VisitedSection extends StatefulWidget {
  const VisitedSection({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VisitedSectionState createState() => _VisitedSectionState();

}

class _VisitedSectionState extends State<VisitedSection> {

  final Completer<GoogleMapController> _controller = Completer();
  final FirestoreService firestoreService = FirestoreService();
  bool _isLoading = false;
  String mapTheme = '';
  String? selectedCategory = 'All';
  final List<Marker> _markers = <Marker>[];
  List<Map<String, dynamic>> allLocations = VisitedLocationList().locations;
  static const CameraPosition _kGoogle = CameraPosition( 
      target: LatLng(3.2102, 101.7592), 
      zoom: 16, 
  );

  Future<Uint8List> getImages(String path, int width) async{ 
    ByteData data = await rootBundle.load(path); 
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width); 
    ui.FrameInfo fi = await codec.getNextFrame(); 
    return(await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List(); 
  } 
  
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
              _filterMarkers(value);
            });
          },
          items: <String>['All', 'Animal', 'Exhibit']
              .map<DropdownMenuItem<String>>((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 14,
            ),
        ),
      ),
    );
  }


 Future<bool> fetchIsVisited(String collectionName, String docId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection(collectionName).doc(docId).get();
    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['isVisited'] ?? false;
    }
    return false;
  }


  void _filterMarkers(String? category) async {
    setState(() {
      _isLoading = true;
    });
    _markers.clear();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    for (var location in allLocations) {
      if (category == 'All' || location['category'] == category) {
        bool isVisited;
        if (location['collectionName'] == 'exhibits') {
          isVisited = await firestoreService.isExhibitVisited(userId, location['docId']);
        } else if (location['collectionName'] == 'animals') {
          isVisited = await firestoreService.isAnimalVisited(userId, location['docId']);
        } else {
          isVisited = false;
        }
        final markerIconPath = isVisited ? location['visitedIcon'] : location['icon'];
        final markerIcon = await getImages(markerIconPath, 100);
        _markers.add(
          Marker(
            markerId: MarkerId(location['title']),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            position: LatLng(location['latitude'], location['longitude']),
            onTap: () async {
              if (location['collectionName'] == 'exhibits') {
                if (isVisited) {
                  await firestoreService.unmarkExhibitAsVisited(userId, location['docId']);
                } else {
                  await firestoreService.markExhibitAsVisited(userId, location['docId']);
                }
              } else if (location['collectionName'] == 'animals') {
                if (isVisited) {
                  await firestoreService.unmarkAnimalAsVisited(userId, location['docId']);
                } else {
                  await firestoreService.markAnimalAsVisited(userId, location['docId']);
                }
              }
              _filterMarkers(selectedCategory);
            },
            infoWindow: InfoWindow(title: location['title']),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }



  void _showTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Help',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                const Text(
                  'How to use the \'Visited\' tab?',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                const Text(
                  '1. Click the icon on the digital map to mark as visited.',
                  style: TextStyle(fontSize: 16.0),
                ),
                const Text(
                  '2. The icon\'s colour changes from white to grey, indicate that the place is visited.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override 
  void initState() {
    super.initState(); 
    DefaultAssetBundle.of(context).loadString('assets/maptheme/retro_theme.json').then((value){
      mapTheme = value;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGoogle,
            markers: Set<Marker>.from(_markers),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true, 
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // ignore: deprecated_member_use
              controller.setMapStyle(mapTheme);
              _filterMarkers(selectedCategory);
            },
          ),
          if(_isLoading)
            const Center(
              child: CircularProgressIndicator(),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: _buildFilterDropdown(),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: Column(
              children: [
                Tooltip(
                  message: 'This button shows a hint',
                  child: IconButton(
                    icon: const Icon(
                      Icons.help,
                      color: Color(0xFF44552C),
                      size: 25,
                    ),
                    onPressed: () {
                      _showTooltip(context);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.description,
                    color: Color(0xFF44552C),
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/viewanalysisvisitor');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
