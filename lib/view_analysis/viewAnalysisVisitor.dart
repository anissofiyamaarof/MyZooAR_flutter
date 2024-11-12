import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/services/calculatedSection.dart';

class ViewAnalysisVisitor extends StatefulWidget {
  @override
  _ViewAnalysisVisitorState createState() => _ViewAnalysisVisitorState();
}

class _ViewAnalysisVisitorState extends State<ViewAnalysisVisitor> {
  double animalsVisitedPercentage = 0.0;
  double exhibitsVisitedPercentage = 0.0;
  int visitedAnimalsCount = 0;
  int visitedExhibitsCount = 0;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 5.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Row(
              children: [
                SizedBox(width: 30),
                Text(
                  'VISITED SECTION ANALYSIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    fontFamily: 'Bobby Jones',
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: Color(0xFF44552C),
          ),
        ),
        body: const Center(
          child: Text("No user is logged in."),
        ),
      );
    }

    String userId = user!.uid;

    return Scaffold(
      backgroundColor: Color(0xFFA7AE9C),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 5.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Row(
            children: [
              SizedBox(width: 30),
              Center(
                child: Text(
                  'VISITED SECTION ANALYSIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    fontFamily: 'Bobby Jones',
                    letterSpacing: 3.0,
                  ),
                ),
              )
            ],
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF44552C),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FutureBuilder<Map<String, int>>(
                      future: CalculatedSection.getTotalCounts(userId),
                      builder: (context, countSnapshot) {
                        if (countSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (countSnapshot.hasError) {
                          return Text("Error: ${countSnapshot.error}");
                        } else {
                          final counts = countSnapshot.data ?? {'visitedAnimals': 0, 'totalAnimals': 0, 'visitedExhibits': 0, 'totalExhibits': 0};
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Visited Animals",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF44552C),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "${counts['visitedAnimals']} / ${counts['totalAnimals']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF44552C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Visited Exhibits",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF44552C),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "${counts['visitedExhibits']} / ${counts['totalExhibits']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF44552C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    FutureBuilder<double>(
                      future: CalculatedSection.calculateVisitedPercentage(userId, 'visitedAnimals'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          final animalsVisitedPercentage = snapshot.data ?? 0.0;
                          return FutureBuilder<double>(
                            future: CalculatedSection.calculateVisitedPercentage(userId, 'visitedExhibits'),
                            builder: (context, exhibitSnapshot) {
                              if (exhibitSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (exhibitSnapshot.hasError) {
                                return Text("Error: ${exhibitSnapshot.error}");
                              } else {
                                final exhibitsVisitedPercentage = exhibitSnapshot.data ?? 0.0;
                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 40),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA7AE9C),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            "Visited Animals Percentage",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            height: 200,
                                            child: PieChart(
                                              PieChartData(
                                                sections: [
                                                  PieChartSectionData(
                                                    color: Color(0xFF0069C5),
                                                    value: animalsVisitedPercentage,
                                                    title: 'Visited\n${animalsVisitedPercentage.toStringAsFixed(1)}%',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  PieChartSectionData(
                                                    color: Color(0XFFCDCDCD),
                                                    value: 100 - animalsVisitedPercentage,
                                                    title: 'Unvisit',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 40),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA7AE9C),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            "Visited Exhibit Percentage",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            height: 200,
                                            child: PieChart(
                                              PieChartData(
                                                sections: [
                                                  PieChartSectionData(
                                                    color: Color(0xFF0069C5),
                                                    value: exhibitsVisitedPercentage,
                                                    title: 'Visited\n${exhibitsVisitedPercentage.toStringAsFixed(1)}%',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  PieChartSectionData(
                                                    color: Color(0XFFCDCDCD),
                                                    value: 100 - exhibitsVisitedPercentage,
                                                    title: 'Unvisit',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
