import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:flutter1/services/firestore.dart';
import 'package:flutter1/view_information/viewAllInfo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter1/main_page/location_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  String mapTheme = '';
  String? selectedCategory = 'All';
  final FirestoreService firestoreService = FirestoreService();
  User? user = FirebaseAuth.instance.currentUser;

  static const CameraPosition _kGoogle = CameraPosition( 
      target: LatLng(3.2102, 101.7592), 
    zoom: 16, 
  );

  void showDetails(BuildContext context, String title2, String id, String category) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext bc) {
      Future<String?> future;
      if (category == 'Animal') {
        future = firestoreService.getFirstAnimalImageUrl(id);
      } else if (category == 'Exhibit') {
        future = firestoreService.getFirstExhibitImageUrl(id);
      } else if (category == 'Facility') {
        future = firestoreService.getFirstFacilityImageUrl(id);
      } else {
        future = Future.value(null);
      }

      return FutureBuilder<String?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          bool isNetworkImage = snapshot.hasData && snapshot.data!.isNotEmpty;
          ImageProvider<Object> imageProvider = isNetworkImage
              ? NetworkImage(snapshot.data!)
              : const AssetImage('assets/images/alt_camera.png') as ImageProvider<Object>;

          return Stack(
            children: [
              Positioned(
                left: 30,
                right: 30,
                bottom: 30,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      Container(
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFF44552C),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Text(
                                  title2,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ViewAnimalInfo(docID: id, category: category),
                                ));
                              },
                              child: Text('View\nDetails', style: TextStyle(color: Color(0xFF44552C))),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20.0),
                                ),),
                                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
  
  Uint8List? marketimages; 
  List<String> images = [
    'assets/icons/panda.png',
    'assets/icons/ape.png',
    'assets/icons/buffalo.png',
    'assets/icons/deer.png',
    'assets/icons/stork.png',
    ]; 
  
  final List<Marker> _markers = <Marker>[]; 
  
  Future<Uint8List> getImages(String path, int width) async{ 
    ByteData data = await rootBundle.load(path); 
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width); 
    ui.FrameInfo fi = await codec.getNextFrame(); 
    return(await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List(); 
  
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
          Positioned(
            right: 20,
            top: 20,
            child: _buildFilterDropdown(),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: TextButton(
              onPressed: () {
                //Navigator.pushNamed(context, '/arNavigation');
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              child: const Column(
                children: [
                  Text('View AR', style: TextStyle(color: Colors.black)),
                  Text('Navigation', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          items: <String>['All', 'Animal', 'Exhibit', 'Facility']
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

  List<Map<String, dynamic>> allLocations = LocationList().locations;
  void _filterMarkers(String? category) async {
    _markers.clear();
    for (var location in allLocations) {
      if (category == 'All' || location['category'] == category) {
        final markerIcon = await getImages(location['icon'], 100);
        _markers.add(
          Marker(
            markerId: MarkerId(location['title']),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            position: LatLng(location['latitude'], location['longitude']),
            onTap: () => showDetails(context, location['title2'],location['id'], location['category']),
          ),
        );
      }
    }
    setState(() {});
  }
}
