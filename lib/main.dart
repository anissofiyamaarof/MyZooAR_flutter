import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/firebase_auth_implementation/login_visitor.dart';
import 'package:flutter1/manage_information/exhibitInfo.dart';
import 'package:flutter1/landingPageAdmin.dart';
import 'package:flutter1/notification/clicked_noti.dart';
import 'package:flutter1/register_visitor/registerVisitor.dart';
import 'package:flutter1/services/notificationService.dart';
import 'package:flutter1/view_analysis/viewAnalysisAdmin.dart';
import 'package:flutter1/view_analysis/viewAnalysisVisitor.dart';
import 'package:flutter1/welcome.dart';
import 'main_page/map.dart';
import 'firebase_auth_implementation/login_admin.dart';
import 'manage_information/facilityInfo.dart';
import 'landingPageVisitor.dart';
import 'view_information/viewAllInfo.dart';
import 'view_information/viewVisitorInfo.dart';
import 'firebase_auth_implementation/logout.dart';
import 'manage_information/categoryInfo.dart';
import 'manage_information/animalInfo.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAxPv8ZlhFs5PtzBhw1pEuc-_VdeXknF4k",
      appId: "1:234928037239:android:6c6315e5e4a524ca88d572",
      messagingSenderId: "234928037239",
      projectId: "myzooar",
      storageBucket: 'gs://myzooar.appspot.com'
    )
  );
  AwesomeNotifications().initialize(
    null, 
    [
      NotificationChannel(
        channelKey: 'basic_channel', 
        channelName: 'Basic notifications', 
        channelDescription: 'Notification channel for basic tests')
    ],
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness:Brightness.light),
      ),
      home: SplashScreen(),
      routes: {
        '/welcome': (context) => Welcome(),
        '/loginadmin': (context) => LoginAdmin(),
        '/loginvisitor': (context) => LoginVisitor(),
        '/logout': (context) => LogoutScreen(),
        '/map': (context) => ZooMapPage(),
        '/mapadmin': (context) => ZooMapPageAdmin(),
        '/visitorInfo': (context) => VisitorInfo(),
        '/categoryInfo': (context) => CategoryInfo(),
        '/animalmap': (context) => MapPage(),
        '/animalinfo': (context) => AnimalInfo(),
        '/exhibitinfo': (context) => ExhibitInfo(),
        '/facilityinfo': (context) => FacilityInfo(),
        '/viewanimalinfo': (context) => ViewAnimalInfo(docID: '', category: ''),
        '/clickednoti': (context) => ClickedNoti(eventId: '',),
        '/registervisitor': (context) => RegisterVisitor(),
        '/viewanalysisvisitor': (context) => ViewAnalysisVisitor(),
        '/viewanalysisadmin': (context) => ViewAnalysisAdmin(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Welcome()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splashscreen.png'),
            fit: BoxFit.cover,
          ),
        ),
      ), 
    );
  }
}
