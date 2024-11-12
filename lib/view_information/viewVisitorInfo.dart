import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class VisitorInfo extends StatefulWidget {
  @override
  _VisitorInfoState createState() => _VisitorInfoState();
}

class _VisitorInfoState extends State<VisitorInfo> {
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
          title: const Row(
            children: [
              SizedBox(width: 30),
              Text(
                'VISITOR INFORMATION', 
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
          backgroundColor: Color(0xFF947021),
        ),
      ),


      
      body: Container( 
        color: Color(0xFF44552C),
        child:SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height:18.0),
              InkWell(
                onTap: () {
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    'assets/images/entrancezoo.jpg',
                    width: 320.0,
                    height: 155.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height:8.0),
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 6),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_filled, color: Color(0xFF44552C)),
                            SizedBox(width: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Operation Hours',
                                  style: TextStyle(
                                    color: Color(0xFF44552C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ), SizedBox(height: 5.0),
                                Text(
                                  'Open daily: 9:00 am – 5:00 pm\nLast admission: 4:00 pm',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
 
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.location_city_rounded, color: Color(0xFF44552C)),
                            const SizedBox(width: 16.0),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Address',
                                    style: TextStyle(
                                      color: Color(0xFF44552C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    'Jalan Taman ZooView, Taman ZooView, 68000 Ampang, Selangor',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                launchUrl(Uri.parse('https://maps.app.goo.gl/nAhBMT5GW4wTkVmV9'));
                              },
                              child: Text('Get direction', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.attach_money_rounded, color: Color(0xFF44552C)),
                                const SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Entrance Fee',
                                      style: TextStyle(
                                        color: Color(0xFF44552C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Image.asset(
                                      'assets/images/entrancefee.png',
                                      width: 285.0,
                                      height: 165.0,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 10.0),
                                    const Text(
                                      'FREE admission for kids below 36 months',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    const Text(
                                      '*Bring along the original passport / ID card\nat the ticket counter for verification',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_money_rounded, color: Color(0xFF44552C)),
                                SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'School Concession Rate and Others',
                                      style: TextStyle(
                                        color: Color(0xFF44552C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'Student: RM 15.00\nTeacher: FREE with every 10 students\nAdditional Teacher: RM 17.00',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '*A letter from school and students with uniform',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'Group Discount: Min. 20 pax\n(RM 2 off normal ticket rate)',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'FREE ADMISSION: Disable (OKU)',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '*Please show a valid OKU Card',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.pets, color: Color(0xFF44552C)),
                                SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Activities',
                                      style: TextStyle(
                                        color: Color(0xFF44552C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      'Multi-Animal Show', 
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      'Daily: 11:00 am - 3:00 pm\nFriday: 11:00 am - 3:30 pm',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      '*The above is subject to cancellation without prior notice',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.directions_bus_filled, color: Color(0xFF44552C)),
                                const SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tram Rides',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Image.asset(
                                      'assets/images/tramstation.png',
                                      width: 280.0,
                                      height: 151.0,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Image.asset(
                                      'assets/images/tramstation2.png',
                                      width: 280.0,
                                      height: 151.0,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 10.0),
                                    const Text(
                                      '*Kids below 2 years old - FREE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
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
    );
  }

}
