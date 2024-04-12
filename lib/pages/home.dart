// ignore_for_file: prefer_const_constructors, unused_local_variable, sort_child_properties_last, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitness/services/firestore.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();
  //text controler
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController flatNumberController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  void openNoteBox(String? docID,
      {String? name, String? phoneNumber, String? flatNumber, String? job}) {
    nameController.text = name ?? '';
    phoneNumberController.text = phoneNumber ?? '';
    flatNumberController.text = flatNumber ?? '';
    jobController.text = job ?? '';

    String errorMessage = ''; // Initialize error message

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(docID != null
                ? "Update flat member data"
                : "Insert flat member data"),
            content: Container(
              height: 450, // Adjust the height as needed
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage
                      .isNotEmpty) // Show error message if not empty
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  TextField(
                    controller: flatNumberController,
                    decoration: InputDecoration(labelText: 'Flat Number'),
                  ),
                  TextField(
                    controller: jobController,
                    decoration: InputDecoration(labelText: 'Job'),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    // Check if fields are valid
                    // Check if phone number and flat number already exist
                    firestoreService
                        .checkExistingPhoneNumberAndFlatNumber(
                      phoneNumberController.text,
                      flatNumberController.text,
                    )
                        .then((exists) {
                      if (!exists) {
                        // add a new note or update existing note
                        if (docID == null) {
                          firestoreService.addflat(
                            nameController.text,
                            phoneNumberController.text,
                            flatNumberController.text,
                            jobController.text,
                          );
                        } else {
                          firestoreService.updateflat(
                            docID,
                            nameController.text,
                            phoneNumberController.text,
                            flatNumberController.text,
                            jobController.text,
                          );
                        }
                        nameController.clear();
                        phoneNumberController.clear();
                        flatNumberController.clear();
                        jobController.clear();
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          errorMessage =
                              'Phone number or flat number already exists.';
                        });
                      }
                    });
                  } else {
                    // Set error message
                    setState(() {
                      errorMessage = 'Please fill in all fields.';
                    });
                  }
                },
                child: Text(docID != null ? "Update" : "Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _validateFields() {
    // Check if any of the required fields are empty
    if (nameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        flatNumberController.text.isEmpty ||
        jobController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> deleteflat(String docID) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this document?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to indicate cancellation
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to indicate deletion
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await firestoreService.deleteeflat(docID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flat Members List',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 199, 230, 255),
                const Color.fromARGB(255, 170, 230, 172)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(null),
        child: Icon(Icons.add),
        backgroundColor: Colors.orange, // Change background color
        elevation: 4, // Add elevation for a raised appearance
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the border radius
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getFlatesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.separated(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;
                  Map<String, dynamic>? data =
                      document.data() as Map<String, dynamic>?;
                  String name = data?["name"];
                  String phoneNumber = data?["phoneNumber"];
                  String flatNumber = data?["flatNumber"];
                  String job = data?["job"];

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                        backgroundColor: Colors.blue,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ), // Name
                          SizedBox(height: 4),
                          Text(
                            'Phone : $phoneNumber',
                            style: TextStyle(
                                color: Color.fromARGB(255, 41, 38, 38),
                                fontSize: 17),
                          ), // Phone number
                          Text(
                            'Flat No : $flatNumber',
                            style: TextStyle(
                                color: Color.fromARGB(255, 41, 38, 38),
                                fontSize: 17),
                          ), // Flat number
                          Text(
                            'Job : $job',
                            style: TextStyle(
                                color: Color.fromARGB(255, 41, 38, 38),
                                fontSize: 17),
                          ), // Occupation
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Update button
                          IconButton(
                            onPressed: () => openNoteBox(
                              docID,
                              name: data?["name"],
                              phoneNumber: data?["phoneNumber"],
                              flatNumber: data?["flatNumber"],
                              job: data?["job"],
                            ),
                            icon: Icon(Icons.edit, color: Colors.green),
                          ),
                          // Delete button
                          IconButton(
                            onPressed: () => deleteflat(docID),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    thickness: 0,
                  );
                },
              );
            } else {
              return const Text("No Notes ....");
            }
          }),
    );
  }
}
