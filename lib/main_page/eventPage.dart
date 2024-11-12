import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/services/notificationService.dart'; 

class EventPage extends StatefulWidget {
  final Function(String) onEventSelected;

  const EventPage({Key? key, required this.onEventSelected}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String selectedCategory = 'Animal Show';

  List<Map<String, String>> animalShowCards = [
    {
      'image': 'assets/images/animalshow.jpg',
      'title': 'Multi-Animal Show (Sea Lion/Macaws)',
      'location': 'Animal Show Amphitheatre',
      'day': 'Closed on Friday only EXCEPT school & public holidays',
      'time': '11:00 A.M',
      'id': '1'
    },
    {
      'image': 'assets/images/animalshow.jpg',
      'title': 'Multi-Animal Show (Sea Lion/Macaws)',
      'location': 'Animal Show Amphitheatre',
      'day': 'Closed on Friday only EXCEPT school & public holidays',
      'time': '03:00 P.M',
      'id': '2'
    },
  ];

  List<Map<String, String>> animalFeedingCards = [
    {
      'image': 'assets/images/animalshow.jpg',
      'title': 'Animal Feeding Session',
      'location': 'Children\'s World',
      'day': 'Weekends and public holiday',
      'time': '12:00 P.M - 01:00 P.M',
      'id': '3'
    },
    {
      'image': 'assets/images/animalshow.jpg',
      'title': 'Animal Feeding Session',
      'location': 'Javan Deer',
      'day': 'Weekends and public holiday',
      'time': '02:00 P.M - 03:00 P.M',
      'id': '4'
    },
  ];

  void _handleCardTap(String eventId) {
    widget.onEventSelected(eventId);
  } 

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFA7AE9C),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20,bottom: 8, left: 30, right: 8),
              child: Text('Choose event:', 
              style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),),
            ),

            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 20, left: 30, right: 30),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 7.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio(
                      value: 'Animal Show',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value as String;
                        });
                      },
                    ),
                    Text('Animal Show'),
                    Radio(
                      value: 'Animal Feeding',
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value as String;
                        });
                      },
                    ),
                    Text('Animal Feeding'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: _buildCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCards() {
    List<Map<String, String>> cardsData =
        selectedCategory == 'Animal Show' ? animalShowCards : animalFeedingCards;

    return cardsData.map((card) {
      return Card(
        margin: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Image.asset(
                  card['image']!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 5, left: 10, right: 5),
              child: Column(
                children: [
                  Text(
                    card['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Location: ${card['location']}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Day: ${card['day']}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    card['time']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFF947021),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                      color: Color(0xFF44552C),
                    ),
                    child: TextButton.icon(
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.alarm, color: Colors.white),
                      ),
                      label: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Notify Me',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () async{
                        int hour = 00;
                        int minute = 00;

                        if (card['id'] == '1') {
                          hour = 09;
                          minute = 15;
                          _handleCardTap(card['id']!);
                        } else if (card['id'] == '2') {
                          hour = 10;
                          minute = 06;
                          _handleCardTap(card['id']!);
                        } else if (card['id'] == '3') {
                          hour = 09;
                          minute = 49;
                          _handleCardTap(card['id']!);
                        } else if (card['id'] == '4') {
                          hour = 10;
                          minute = 20;
                          _handleCardTap(card['id']!);
                        }

                        await NotificationService.showNotification(
                          title: "Event Starts Soon!", 
                          body: "Get ready! ${card['title']} starts in 15 minutes",
                          payload: {
                            "navigate": "true",
                            "eventId": card['id']!,
                          },
                          scheduled: true,
                          hour: hour,
                          minute: minute,
                          notificationLayout: NotificationLayout.BigText
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reminder set successfully!"))
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF44552C),
                        padding: EdgeInsets.symmetric(vertical: 18),
                        minimumSize: Size(double.infinity, 56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}