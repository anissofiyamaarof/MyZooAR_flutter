
import 'package:cloud_firestore/cloud_firestore.dart';

class CalculatedSection {

  static Future<double> calculateVisitedPercentage(String userId, String subCollectionName) async {
    var userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    var subCollection = userDoc.collection(subCollectionName);
    var totalQuerySnapshot = await subCollection.get();
    int visitedCount = totalQuerySnapshot.size;
    var mainCollection = FirebaseFirestore.instance.collection(subCollectionName == 'visitedAnimals' ? 'animals' : 'exhibits');
    var totalMainQuerySnapshot = await mainCollection.get();
    int totalCount = totalMainQuerySnapshot.size;

    // Calculate percentage
    if (totalCount == 0) {
      return 0.0;
    } else {
      return (visitedCount / totalCount) * 100;
    }
  }

  static Future<Map<String, int>> getTotalCounts(String userId) async {
    
    final visitedAnimalsCount = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('visitedAnimals')
      .where('isVisited', isEqualTo: true)
      .get()
      .then((query) => query.size);

    final visitedExhibitsCount = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('visitedExhibits')
      .where('isVisited', isEqualTo: true)
      .get()
      .then((query) => query.size);

    final totalAnimals = await FirebaseFirestore.instance
      .collection('animals')
      .get()
      .then((query) => query.size);

    final totalExhibits = await FirebaseFirestore.instance
      .collection('exhibits')
      .get()
      .then((query) => query.size);

    return {
      'visitedAnimals': visitedAnimalsCount,
      'visitedExhibits': visitedExhibitsCount,
      'totalAnimals' : totalAnimals,
      'totalExhibits' : totalExhibits,
    };
  }



  //ADMIN
  static Future<Map<String, dynamic>> getAdminStats(String year) async {
    int yearNumber = int.parse(year);
    int totalVisitors = 0;
    int over50PercentAnimalsVisitors = 0;
    int over50PercentExhibitsVisitors = 0;
    List<int> monthlyVisitors = List<int>.filled(12, 0);

    final snapshot = await FirebaseFirestore.instance.collection('users')
        .where('timestamp', isGreaterThanOrEqualTo: DateTime(yearNumber, 1, 1))
        .where('timestamp', isLessThan: DateTime(yearNumber + 1, 1, 1))
        .get();

    totalVisitors = snapshot.docs.length;

    //calculate monthly visitors
    for (var doc in snapshot.docs) {
      Timestamp? timestamp = doc['timestamp'];
      if (timestamp != null) {
        DateTime date = timestamp.toDate();
        int month = date.month - 1; // Month is 1-12, but index is 0-11
        monthlyVisitors[month]++;
      }

      String userId = doc.id;
      double animalVisitPercentage = await calculateVisitedPercentage(userId, 'visitedAnimals');
      double exhibitVisitPercentage = await calculateVisitedPercentage(userId, 'visitedExhibits');

      if (animalVisitPercentage >= 50.0) {
        over50PercentAnimalsVisitors++;
      }
      if (exhibitVisitPercentage >= 50.0) {
        over50PercentExhibitsVisitors++;
      }
    }
    
    return {
      'totalVisitors': totalVisitors,
      'over50PercentAnimalsVisitors': over50PercentAnimalsVisitors,
      'over50PercentExhibitsVisitors': over50PercentExhibitsVisitors,
      'monthlyVisitors': monthlyVisitors,
    };
  }
}