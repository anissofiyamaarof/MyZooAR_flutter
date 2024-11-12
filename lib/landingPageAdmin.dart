import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/manage_information/categoryInfo.dart';
import 'package:flutter1/register_visitor/registerVisitor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'main_page/map.dart';


class ZooMapPageAdmin extends StatefulWidget {
  @override
  _ZooMapPageAdminState createState() => _ZooMapPageAdminState();
}

class _ZooMapPageAdminState extends State<ZooMapPageAdmin> {
  LatLng initialPosition = LatLng(37.7749, -122.4194);
  final transformationController = TransformationController();
  TapDownDetails? tapDetails;
  bool isMap = false;
  bool isRegisterVisitor = false;
  bool isCategoryInfo = false;
  bool mapSelected = false;
  bool registerSelected = false;
  bool categoryInfoSelected = false;
  Matrix4? iconInitialTransform;
  User? user = FirebaseAuth.instance.currentUser;

  late BitmapDescriptor mapMarker;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    mapSelected = true;
    registerSelected = false;
    categoryInfoSelected = false;
    isMap = true;
    isRegisterVisitor = false;
    isCategoryInfo = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAnnouncementPopup(context);
    });
  }

  Future<void> _checkAdminStatus() async {
    setState(() {});
  }

  Future<String> _getAnnouncementText() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('announcements').doc('announcementDoc').get();
    if (doc.exists) {
      return doc['text'] ?? 'No announcement available.';
    }
    return 'No announcement available.';
  }

  Future<void> _updateAnnouncementText(String newText) async {
    await FirebaseFirestore.instance.collection('announcements').doc('announcementDoc').set({
      'text': newText,
    });
  }

  void _showAnnouncementPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        bool isEditing = false;

        return FutureBuilder<String>(
          future: _getAnnouncementText(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            String announcementText = snapshot.data ?? 'No announcement available.';
            _textController.text = announcementText;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 15, left: 20, right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Announcement',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            if (!isEditing)
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        isEditing
                            ? Column(
                                children: [
                                  SizedBox(height: 12.0),
                                  TextField(
                                    controller: _textController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Edit Announcement',
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            isEditing = false;
                                          });
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _updateAnnouncementText(_textController.text);
                                          setState(() {
                                            isEditing = false;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Text(
                                announcementText,
                                style: TextStyle(fontSize: 14.0),
                              ),
                        if (!isEditing)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (user != null)
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                                    if (userData['role'] == 'admin') {
                                      return IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        },
                                      );
                                    }
                                  }
                                  return SizedBox();
                                },
                              ),
                            ],
                          ),
                        if (user == null)
                          SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout, color: Color(0xFF44552C)),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamed(context, '/logout');
          }
        ),
        title: Row(
          children: [
            SizedBox(width: 20),
            Image.asset(
              'assets/images/logozooflutter.png',
              width: 43.0,
              height: 43.0,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 20),
            const Text(
              'MYZOOAR', 
              style: TextStyle(
                color: Color(0xFF44552C),
                fontWeight: FontWeight.bold, 
                fontFamily: 'Bobby Jones',
                letterSpacing: 3.0,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.description,
              color: Color(0xFF44552C),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/viewanalysisadmin');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded, 
              color: Color(0xFF44552C)
            ), 
            onPressed: () {
              Navigator.pushNamed(context, '/visitorInfo');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Container(
            color: Color(0xFF44552C),
            height: 53.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildTabItem(context, 'Map',(){
                  setState(() {
                    mapSelected = true;
                    registerSelected = false;
                    categoryInfoSelected = false;
                    isMap = true;
                    isRegisterVisitor = false;
                    isCategoryInfo = false;
                  });
                },mapSelected),
                _buildTabItem(context, 'Register',(){
                  setState(() {
                    mapSelected = false;
                    registerSelected = true;
                    categoryInfoSelected = false;
                    isMap = false;
                    isRegisterVisitor = true;
                    isCategoryInfo = false;
                  });
                },registerSelected),
                _buildTabItem(context, 'Manage',(){
                  setState(() {
                    mapSelected = false;
                    registerSelected = false;
                    categoryInfoSelected = true;
                    isMap = false;
                    isRegisterVisitor = false;
                    isCategoryInfo = true;
                  });
                },categoryInfoSelected),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: <Widget>[
          if(isMap)
          const Center(child: MapPage(),),
          if(isRegisterVisitor)
          const Center(child: RegisterVisitor(),),
          if(isCategoryInfo)
          Center(child: CategoryInfo()),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, VoidCallback onPressed, bool isSelected) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: isSelected ? Color(0xFF947021) : Colors.transparent,
        height: 53.0,
        width: 100.0,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
