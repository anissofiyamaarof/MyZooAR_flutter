import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/services/firestore.dart';
import 'package:intl/intl.dart';

class RegisterVisitor extends StatefulWidget {
  const RegisterVisitor({super.key});

  @override
  _RegisterVisitorState createState() => _RegisterVisitorState();
}

class _RegisterVisitorState extends State<RegisterVisitor> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ticketNumberController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String _errorMessage = '';
  List<String> categories = ['Form', 'List'];
  String selectedCategory = 'Form';
  final FirestoreService firestoreService = FirestoreService();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ticketNumberController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _registerVisitor() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String email = _emailController.text.trim();
    String fullName = _fullNameController.text.trim();
    String ticketNumber = _ticketNumberController.text.trim();
    String password = "ZooVisitor123"; // Fixed password

    if (email.isEmpty || fullName.isEmpty || ticketNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'fullName': fullName,
          'ticketNumber': ticketNumber,
          'timestamp': FieldValue.serverTimestamp(),
          'role': 'visitor',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The visitor is successfully registered!"))
        );
        _emailController.clear();
        _fullNameController.clear();
        _ticketNumberController.clear();

      } else {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              _errorMessage = "The email address is already in use.";
              break;
            case 'invalid-email':
              _errorMessage = "The email address is not valid.";
              break;
            case 'operation-not-allowed':
              _errorMessage = "Operation not allowed. Please contact support.";
              break;
            case 'weak-password':
              _errorMessage = "The password is too weak.";
              break;
            default:
              _errorMessage = "An error occurred. Please try again.";
          }
        } else {
          _errorMessage = "Some error occurred. Please try again.";
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 8, left: 30, right: 30),
                child: Center(
                  child: Text(
                    'VISITOR REGISTRATION',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bobby Jones',
                      color: Color(0xFF44552C),
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                margin: const EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: categories.map((category) => Expanded(
                    child: ListTile(
                      title: Text(category,
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.start,
                      ),
                      leading: Radio<String>(
                        value: category,
                        groupValue: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  )).toList(),
                ),
              ),
              SizedBox(height: 30),
              if (selectedCategory == "Form")
                ..._buildRegistrationForm(),
              if (selectedCategory == "List")
                _buildSearchBar(),
              SizedBox(height: 10),
              if (selectedCategory == "List")
                Expanded(
                  child: _buildUsersList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRegistrationForm() {
    String fixedPassword = "ZooVisitor123";

    return [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: fixedPassword),
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _ticketNumberController,
                decoration: InputDecoration(
                  labelText: 'Ticket Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerVisitor,
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'REGISTER',
                        style: TextStyle(color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search by name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getVisitorUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return const Text("No users...");
        }

        List<DocumentSnapshot> visitorsList = snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          bool matchesSearch = data['fullName'].toLowerCase().contains(_searchQuery);
          return matchesSearch;
        }).toList();

        return ListView.builder(
          itemCount: visitorsList.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = visitorsList[index];
            String docID = document.id;
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String facilityText = data['email'] ?? "N/A";
            return Card(
              margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                title: Text(facilityText, style: TextStyle(fontSize: 15.0)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showUserDetails(context, docID);
                      },
                      icon: const Icon(Icons.arrow_right_rounded, size: 40.0),
                    ),
                    IconButton(
                      onPressed: () {
                        _showEditTicketNumberDialog(context, docID, data['ticketNumber'], data['email']);
                      },
                      icon: const Icon(Icons.edit, size: 20.0),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showUserDetails(BuildContext context, String docID) {
    FirebaseFirestore.instance.collection('users').doc(docID).get().then((document) {
      if (document.exists) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        DateTime timestamp = (userData['timestamp'] as Timestamp).toDate();
        String formattedTimestamp = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(23),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Visitor Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 20),
                          Text('Email: ${userData['email']}'),
                          const SizedBox(height: 5),
                          Text('Full Name: ${userData['fullName']}'),
                          const SizedBox(height: 5),
                          Text('Ticket Number: ${userData['ticketNumber']}'),
                          const SizedBox(height: 5),
                          Text('Timestamp: $formattedTimestamp'),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(30, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Error', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 10),
                      Text('User data not found.'),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.only(top: 5, bottom: 20, left: 30, right: 15),
                      minimumSize: Size(30, 30), 
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Icon(Icons.close, size: 24), 
                  ),
                ),
              ],
            ),
          );
        });
      }
    });
  }

  void _showEditTicketNumberDialog(BuildContext context, String docID, String currentTicketNumber, String email) {
    TextEditingController _editTicketNumberController = TextEditingController(text: currentTicketNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: 
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Ticket Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 30),
                        TextField(
                          controller: TextEditingController(text: email),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          readOnly: true,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _editTicketNumberController,
                          decoration: InputDecoration(
                            labelText: 'Ticket Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newTicketNumber = _editTicketNumberController.text.trim();
                if (newTicketNumber.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('users').doc(docID).update({
                    'ticketNumber': newTicketNumber,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("The ticket number is successfully updated!"))
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
