import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

String generateUniqueFileName() {
    final uuid = Uuid();
    return uuid.v4();
  }

class FirestoreService {
  
  final CollectionReference animals = FirebaseFirestore.instance.collection('animals');
  final CollectionReference exhibits = FirebaseFirestore.instance.collection('exhibits');
  final CollectionReference facilities = FirebaseFirestore.instance.collection('facilities');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  //mark exhibit as visited
  Future<void> markExhibitAsVisited(String userId, String exhibitId) async {
    final userDoc = users.doc(userId);
    final visitedExhibits = userDoc.collection('visitedExhibits');

    await visitedExhibits.doc(exhibitId).set({'isVisited': true});
  }

  //mark animal as visited
  Future<void> markAnimalAsVisited(String userId, String animalId) async {
    final userDoc = users.doc(userId);
    final visitedAnimals = userDoc.collection('visitedAnimals');

    await visitedAnimals.doc(animalId).set({'isVisited': true});
  }

  //unmark exhibit as visited
  Future<void> unmarkExhibitAsVisited(String userId, String exhibitId) async {
    final userDoc = users.doc(userId);
    final visitedExhibits = userDoc.collection('visitedExhibits');

    await visitedExhibits.doc(exhibitId).delete();
  }

  //unmark animal as visited
  Future<void> unmarkAnimalAsVisited(String userId, String animalId) async {
    final userDoc = users.doc(userId);
    final visitedAnimals = userDoc.collection('visitedAnimals');

    await visitedAnimals.doc(animalId).delete();
  }

  //check if exhibit is visited
  Future<bool> isExhibitVisited(String userId, String exhibitId) async {
    final userDoc = users.doc(userId);
    final visitedExhibitDoc = userDoc.collection('visitedExhibits').doc(exhibitId);

    final snapshot = await visitedExhibitDoc.get();
    return snapshot.exists && snapshot.data()?['isVisited'] == true;
  }

  //check if animal is visited
  Future<bool> isAnimalVisited(String userId, String animalId) async {
    final userDoc = users.doc(userId);
    final visitedAnimalDoc = userDoc.collection('visitedAnimals').doc(animalId);

    final snapshot = await visitedAnimalDoc.get();
    return snapshot.exists && snapshot.data()?['isVisited'] == true;
  }


  //retrieve users
  Stream<QuerySnapshot> getUsersStream() {
    final usersStream = users.snapshots();
    return usersStream;
  }

  //retrieve registered visitors list
  Stream<QuerySnapshot> getVisitorUsersStream() {
    final visitorUsersStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'visitor')
      .snapshots();
    return visitorUsersStream;
  }

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

  //for animals

  //first image to display in showDetails card on map
  Future<String?> getFirstAnimalImageUrl(String docID) async {
    DocumentSnapshot snapshot = await animals.doc(docID).get();
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data != null && data['imageLinks'] is List && (data['imageLinks'] as List).isNotEmpty) {
      return data['imageLinks'][0];
    }
    return null;
  }

  //retrieve animal images
  Future<List<String>> getAnimalImages(String docID) async {
    DocumentSnapshot doc = await animals.doc(docID).get();
    if (doc.data() is Map<String, dynamic>) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> urls = data['imageLinks'] as List<dynamic>? ?? [];
      return urls.map((url) => url as String).toList();
    }
    return [];
  }

  //upload the images into firebase storage
  Future<List<String>> uploadAnimalImages(List<Uint8List> files, String docID) async {
    var documentRef = animals.doc(docID);
    DocumentSnapshot doc = await documentRef.get();
    if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('imageLinks') && (doc.data() as Map<String, dynamic>)['imageLinks'].isNotEmpty) {
      await deleteOldAnimalImages(docID);
    }
    List<String> downloadUrls = [];
    String folderName = 'animalImages';

    for (var file in files) {
      String fileName = Uuid().v4();
      String filePath = '$folderName/$docID/$fileName';

      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  //save animal images URL in firebase
  Future<void> saveAnimalImageUrls(String docID, List<String> imageUrls) async {
    var documentRef = FirebaseFirestore.instance.collection('animals').doc(docID);
    await documentRef.update({
      'imageLinks': imageUrls
    });
  }

  //delete images from the firebase storage
  Future<void> deleteOldAnimalImages(String docID) async {
    String folderName = 'animalImages';
    String directoryPath = '$folderName/$docID';

    Reference dirRef = FirebaseStorage.instance.ref().child(directoryPath);
    ListResult result = await dirRef.listAll();
    List<Reference> files = result.items;

    for (var file in files) {
      try {
        await file.delete();
        print("Deleted file: ${file.fullPath}");
      } catch (e) {
        print("Failed to delete file: ${file.fullPath}. Error: $e");
      }
    }
  }

  //upload animal images
  Future<void> addUpdateAnimalImages(String docID, List<Uint8List> newImages) async {
    List<String> newimageUrls = await uploadAnimalImages(newImages, docID);
    await saveAnimalImageUrls(docID, newimageUrls);
  }

  //upload animal description and images
  Future<void> addUpdateAnimalDescriptionImage(String docID, String animalDesc, List<Uint8List> newImages) async {
    List<String> newImageUrls = await uploadAnimalImages(newImages, docID);
    await saveAnimalImageUrls(docID, newImageUrls);
    await animals.doc(docID).update({
      'animalDesc': animalDesc
    });
  }

  //upload animal description
  Future<void> addUpdateAnimalDescription(String docID, String animalDesc) async {
    return animals.doc(docID).update({
      'animalDesc': animalDesc
    });
  }

  //read
  Stream<QuerySnapshot> getAnimalsStream() {
    final animalsStream = animals.snapshots();
    return animalsStream;
  }

  //read individual based on doc id
  Stream<DocumentSnapshot> getAnimalIndividual(String docID) {
    final animalIndividual = animals.doc(docID).snapshots();
    return animalIndividual;
  }

  Future<String?> getAnimalDescription(String docID) async {
    try {
      DocumentSnapshot snapshot = await animals.doc(docID).get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['animalDesc'] as String?;
      }
      return null;

    } catch (e) {
      print("Failed to fetch animal description: $e");
      return null;
    }
  }

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

  //for exhibits

  //read individual based on doc id
  Stream<DocumentSnapshot> getExhibitIndividual(String docID) {
    final exhibitIndividual = exhibits.doc(docID).snapshots();
    return exhibitIndividual;
  }

  Future<String?> getExhibitDescription(String docID) async {
    try {
      DocumentSnapshot snapshot = await exhibits.doc(docID).get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['exhibitDesc'] as String?;
      }
      return null;

    } catch (e) {
      print("Failed to fetch exhibit description: $e");
      return null;
    }
  }

  //to display in popup card on map
  Future<String?> getFirstExhibitImageUrl(String docID) async {
    DocumentSnapshot snapshot = await exhibits.doc(docID).get();
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data != null && data['imageLinks'] is List && (data['imageLinks'] as List).isNotEmpty) {
      return data['imageLinks'][0];
    }
    return null;
  }

  //retrieve exhibit images
  Future<List<String>> getExhibitImages(String docID) async {
    DocumentSnapshot doc = await exhibits.doc(docID).get();
    if (doc.data() is Map<String, dynamic>) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> urls = data['imageLinks'] as List<dynamic>? ?? [];
      return urls.map((url) => url as String).toList();
    }
    return [];
  }

  //upload the images into firebase storage
  Future<List<String>> uploadExhibitImages(List<Uint8List> files, String docID) async {
    var documentRef = exhibits.doc(docID);
    DocumentSnapshot doc = await documentRef.get();
    if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('imageLinks') && (doc.data() as Map<String, dynamic>)['imageLinks'].isNotEmpty) {
      await deleteOldExhibitImages(docID);
    }
    List<String> downloadUrls = [];
    String folderName = 'exhibitImages';

    for (var file in files) {
      String fileName = Uuid().v4();
      String filePath = '$folderName/$docID/$fileName';

      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  //save exhibit images URL into firebase
  Future<void> saveExhibitImageUrls(String docID, List<String> imageUrls) async {
    var documentRef = FirebaseFirestore.instance.collection('exhibits').doc(docID);
    await documentRef.update({
      'imageLinks': imageUrls
    });
  }

  //delete images from the firebase storage
  Future<void> deleteOldExhibitImages(String docID) async {
    String folderName = 'exhibitImages';
    String directoryPath = '$folderName/$docID';
    Reference dirRef = FirebaseStorage.instance.ref().child(directoryPath);
    ListResult result = await dirRef.listAll();
    List<Reference> files = result.items;

    for (var file in files) {
      try {
        await file.delete();
        print("Deleted file: ${file.fullPath}");
      } catch (e) {
        print("Failed to delete file: ${file.fullPath}. Error: $e");
      }
    }
  }

  //upload exhibit images
  Future<void> addUpdateExhibitImages(String docID, List<Uint8List> newImages) async {
    List<String> newimageUrls = await uploadExhibitImages(newImages, docID);
    await saveExhibitImageUrls(docID, newimageUrls);
  }

  //upload exhibit description and images
  Future<void> addUpdateExhibitDescriptionImage(String docID, String exhibitDesc, List<Uint8List> newImages) async {
    List<String> newImageUrls = await uploadExhibitImages(newImages, docID);
    await saveExhibitImageUrls(docID, newImageUrls);
    await exhibits.doc(docID).update({
      'exhibitDesc': exhibitDesc
    });
  }

  //upload exhibit description
  Future<void> addUpdateExhibitDescription(String docID, String exhibitDesc) async {
    return exhibits.doc(docID).update({
      'exhibitDesc': exhibitDesc
    });
  }


/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

  //for facilities

  //to display in popup card on map
  Future<String?> getFirstFacilityImageUrl(String docID) async {
    DocumentSnapshot snapshot = await facilities.doc(docID).get();
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data != null && data['imageLinks'] is List && (data['imageLinks'] as List).isNotEmpty) {
      return data['imageLinks'][0];
    }
    return null;
  }

  //retrieve facility images
  Future<List<String>> getFacilityImages(String docID) async {
    DocumentSnapshot doc = await facilities.doc(docID).get();
    if (doc.data() is Map<String, dynamic>) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> urls = data['imageLinks'] as List<dynamic>? ?? [];
      return urls.map((url) => url as String).toList();
    }
    return [];
  }

  //upload the images into firebase storage
  Future<List<String>> uploadFacilityImages(List<Uint8List> files, String docID) async {
    var documentRef = facilities.doc(docID);
    DocumentSnapshot doc = await documentRef.get();
    if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('imageLinks') && (doc.data() as Map<String, dynamic>)['imageLinks'].isNotEmpty) {
      await deleteOldFacilityImages(docID);
    }
    List<String> downloadUrls = [];
    String folderName = 'facilityImages';

    for (var file in files) {
      String fileName = Uuid().v4();
      String filePath = '$folderName/$docID/$fileName';

      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  //save facility images URL into firebase
  Future<void> saveFacilityImageUrls(String docID, List<String> imageUrls) async {
    var documentRef = FirebaseFirestore.instance.collection('facilities').doc(docID);
    await documentRef.update({
      'imageLinks': imageUrls
    });
  }

  //delete images from the firebase storage
  Future<void> deleteOldFacilityImages(String docID) async {
    String folderName = 'facilityImages';
    String directoryPath = '$folderName/$docID';
    Reference dirRef = FirebaseStorage.instance.ref().child(directoryPath);
    ListResult result = await dirRef.listAll();
    List<Reference> files = result.items;

    for (var file in files) {
      try {
        await file.delete();
        print("Deleted file: ${file.fullPath}");
      } catch (e) {
        print("Failed to delete file: ${file.fullPath}. Error: $e");
      }
    }
  }

  //upload facility images
  Future<void> addUpdateFacilityImages(String docID, List<Uint8List> newImages) async {
    List<String> newimageUrls = await uploadFacilityImages(newImages, docID);
    await saveFacilityImageUrls(docID, newimageUrls);
  }

  //upload facility description and images
  Future<void> addUpdateFacilityDescriptionImage(String docID, String facilityDesc, List<Uint8List> newImages) async {
    List<String> newImageUrls = await uploadFacilityImages(newImages, docID);
    await saveFacilityImageUrls(docID, newImageUrls);
    await facilities.doc(docID).update({
      'facilityDesc': facilityDesc
    });
  }

  //upload facility description
  Future<void> addUpdateFacilityDescription(String docID, String facilityDesc) async {
    return facilities.doc(docID).update({
      'facilityDesc': facilityDesc
    });
  }

  //retrieve list of facilities
  Stream<QuerySnapshot> getFacilitiesStream() {
    final facilitiesStream = facilities.snapshots();
    return facilitiesStream;
  }

  //read individual based on doc id
  Stream<DocumentSnapshot> getFacilityIndividual(String docID) {
    final facilityIndividual = facilities.doc(docID).snapshots();
    return facilityIndividual;
  }

  Future<String?> getFacilityDescription(String docID) async {
    try {
      DocumentSnapshot snapshot = await facilities.doc(docID).get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['facilityDesc'] as String?;
      }
      return null;

    } catch (e) {
      print("Failed to fetch facility description: $e");
      return null;
    }
  }
}

