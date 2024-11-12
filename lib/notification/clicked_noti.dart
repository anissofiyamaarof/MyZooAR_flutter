import 'package:flutter/material.dart';
import 'package:flutter1/main_page/event_list.dart';

class ClickedNoti extends StatefulWidget {
  final String eventId;
  ClickedNoti({Key? key, required this.eventId}) : super(key: key);

  @override
  _ClickedNotiState createState() => _ClickedNotiState();
}

class _ClickedNotiState extends State<ClickedNoti> {
  late Map<String, String> eventDetails;

  @override
  void initState() {
    super.initState();
    if (widget.eventId == '1' || widget.eventId == '2') {
      eventDetails = EventList.animalShowCards.firstWhere(
      (card) => card['id'] == widget.eventId,
      orElse: () => {'image': '', 'title': 'Event not found', 'location': '', 'day': '', 'time': '', 'id': ''});
    } else if (widget.eventId == '3' || widget.eventId == '4') {
      eventDetails = EventList.animalFeedingCards.firstWhere(
      (card) => card['id'] == widget.eventId,
      orElse: () => {'image': '', 'title': 'Event not found', 'location': '', 'day': '', 'time': '', 'id': ''});
    } else {
      eventDetails = {'image': '', 'title': 'Event not found', 'location': '', 'day': '', 'time': '', 'id': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left:33, bottom: 5),
            child: Image.asset(
              'assets/icons/remindericon.png',
              width: 40,
              height: 40,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 33, top: 10 ,bottom: 20),
            child: Text(
              'Events starts in 15 minutes!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF44552C),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            color: Color(0xFFA7AE9C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(right: 30, left: 30, top: 0, bottom: 40),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Name: ${eventDetails['title']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Location: ${eventDetails['location']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Day: ${eventDetails['day']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Time: ${eventDetails['time']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/map');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44552C),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Back to apps'),
            ),
          ),
        ],
      ),
    );
  }
}
