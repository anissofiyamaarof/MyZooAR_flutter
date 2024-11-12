import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/services/calculatedSection.dart';

class ViewAnalysisAdmin extends StatefulWidget {
  @override
  _ViewAnalysisAdminState createState() => _ViewAnalysisAdminState();
}

class _ViewAnalysisAdminState extends State<ViewAnalysisAdmin> {
  User? user = FirebaseAuth.instance.currentUser;
  String selectedYear = '2024';
  final List<String> years = ['2024', '2025', '2026'];
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final fetchedStats = await CalculatedSection.getAdminStats(selectedYear);
    setState(() {
      stats = fetchedStats;
      isLoading = false;
    });
  }

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
                  'DATA ANALYSIS',
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
                  'DATA ANALYSIS',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedYear,
                    items: years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(
                          year,
                          style: const TextStyle(color: Color(0xFF44552C)),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedYear = newValue!;
                      });
                      _fetchData();
                    },
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (stats.isNotEmpty)
                Column(
                  children: [
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Total Visitors based on Selected Year',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF44552C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              height: 300,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          switch (value.toInt()) {
                                            case 0:
                                              return Text('Jan');
                                            case 1:
                                              return Text('Feb');
                                            case 2:
                                              return Text('Mar');
                                            case 3:
                                              return Text('Apr');
                                            case 4:
                                              return Text('May');
                                            case 5:
                                              return Text('Jun');
                                            case 6:
                                              return Text('Jul');
                                            case 7:
                                              return Text('Aug');
                                            case 8:
                                              return Text('Sep');
                                            case 9:
                                              return Text('Oct');
                                            case 10:
                                              return Text('Nov');
                                            case 11:
                                              return Text('Dec');
                                            default:
                                              return Text('');
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(12, (index) {
                                        return FlSpot(
                                          index.toDouble(),
                                          (stats['monthlyVisitors'] != null &&
                                                  stats['monthlyVisitors'].length > index)
                                              ? stats['monthlyVisitors'][index].toDouble()
                                              : 0.0,
                                        );
                                      }),
                                      isCurved: false,
                                      barWidth: 2,
                                      color: Color(0xFF0069C5),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (LineBarSpot group) => Color(0xFF0069C5),
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((spot) {
                                          return LineTooltipItem(
                                            spot.y.toString(),
                                            const TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      color: Colors.white,
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                'Visitor Distribution Based on Visited Animal Percentage',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF44552C),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 25),
                            if (stats.containsKey('over50PercentAnimalsVisitors') &&
                                stats.containsKey('totalVisitors'))
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Color(0xFF0069C5),
                                        value: stats['over50PercentAnimalsVisitors'].toDouble(),
                                        title: '50% &\nOver\n${stats['over50PercentAnimalsVisitors']}',
                                        titleStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFCDCDCD),
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Color(0xFFCDCDCD),
                                        value: (stats['totalVisitors'] - stats['over50PercentAnimalsVisitors']).toDouble(),
                                        title: 'Below\n50%\n${(stats['totalVisitors'] - stats['over50PercentAnimalsVisitors'])}',
                                        titleStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0069C5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      color: Colors.white,
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                'Visitor Distribution Based on Visited Exhibit Percentage',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF44552C),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 25),
                            if (stats.containsKey('over50PercentExhibitsVisitors') &&
                                stats.containsKey('totalVisitors'))
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Color(0xFF0069C5),
                                        value: stats['over50PercentExhibitsVisitors'].toDouble(),
                                        title: '50% &\nOver\n${stats['over50PercentExhibitsVisitors']}',
                                        titleStyle: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFCDCDCD),
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Color(0xFFCDCDCD),
                                        value: (stats['totalVisitors'] - stats['over50PercentExhibitsVisitors']).toDouble(),
                                        title: 'Below\n50%\n${(stats['totalVisitors'] - stats['over50PercentExhibitsVisitors'])}',
                                        titleStyle: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0069C5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
