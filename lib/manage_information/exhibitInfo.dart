import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter1/services/firestore.dart';
import 'package:image_picker/image_picker.dart';

class ExhibitInfo extends StatefulWidget {
  @override
  _ExhibitInfoState createState() => _ExhibitInfoState();
}

class _ExhibitInfoState extends State<ExhibitInfo> {
  final ImagePicker _picker = ImagePicker();
  List<Uint8List> _images = [];

  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  bool _isLoading = true;
  String? docID;

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      List<Uint8List> imageDatas = [];
      for (XFile image in images) {
          final File file = File(image.path);
          final Uint8List imageData = await file.readAsBytes();
          imageDatas.add(imageData);
      }
      setState(() {
          _images = imageDatas;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context) != null) {
        setState(() {
          docID = ModalRoute.of(context)!.settings.arguments as String?;
        });
        _loadData(docID!);
      }
    });
  }

  Future<void> _loadData(String docID) async {
    try {
      String? exhibitDesc = await firestoreService.getExhibitDescription(docID);
      List<String> imageUrls = await firestoreService.getExhibitImages(docID);
      if (exhibitDesc != null) {
        textController.text = exhibitDesc;
      } else {
        print("No description available");
      }

      _images.clear();
      for (String url in imageUrls) {
        final response = await NetworkAssetBundle(Uri.parse(url)).load(url);
        final imageBytes = response.buffer.asUint8List();
        _images.add(imageBytes);
      }

    } catch (e) {
      print("Error loading data: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load data")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (textController.text.isNotEmpty && _images.isNotEmpty) {
        await firestoreService.addUpdateExhibitDescriptionImage(docID!, textController.text, _images);
      }
      else if (_images.isNotEmpty) {
        await firestoreService.addUpdateExhibitImages(docID!, _images);
      }
      else if (textController.text.isNotEmpty) {
        await firestoreService.addUpdateExhibitDescription(docID!, textController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No data inserted!"))
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e"))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 5.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: firestoreService.getExhibitIndividual(docID!),
                  builder: (context, snapshot) { 
                    if(snapshot.hasData){
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
              )
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: _saveData,
            ),
          ],
          centerTitle: true,
          backgroundColor: const Color(0xFF44552C),
        ),
      ),

      body: _isLoading 
      ? const Center(
        child: CircularProgressIndicator(),
        ) 
      : Container(
        color: const Color(0xFFA7AE9C),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 12),
                  child: Text('Exhibit Description', 
                  style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),),
                ),
                TextFormField(
                  controller:textController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  maxLines: 8,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: Text('Exhibit image(s)', 
                    style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                      ),
                      child: _images.isNotEmpty
                        ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Image.memory(_images[index], fit: BoxFit.cover);
                          },
                          scrollDirection: Axis.horizontal,
                        )
                        : const Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '*The first image will be displayed in this map section',
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      width: 250.0,
                      height: 150.0,
                      child: Image.asset(
                        'assets/images/editinfo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
