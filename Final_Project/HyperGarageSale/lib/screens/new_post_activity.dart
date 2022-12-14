import 'dart:io';
import 'dart:math';

// camera
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hypergaragesale/model/TextCard.dart';
import 'package:hypergaragesale/model/errorr_notification.dart';
import 'package:hypergaragesale/model/post_data.dart';
import 'package:hypergaragesale/screens/camera_screen.dart';

class NewPostScreen extends StatefulWidget {
  static String id = 'new_post_screen';

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  PostData newPost = PostData();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  /// Add text editing controllers, to clear the text fields' values
  final _nameController = TextEditingController();
  final _originalController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  /// Check to see if there is a current user who is signed in
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data);
      }
    }
  }

  void uploadImage() async {
    var timeKey = new DateTime.now();

    // Upload image to firebase.
    FirebaseStorage storage = FirebaseStorage.instance;
    for (int i = 0; i < newPost.pictures.length; i++) {
      int randomNumber = Random().nextInt(100000);
      String imageLocation =
          'images${timeKey.millisecondsSinceEpoch}/image$randomNumber.jpg';
      final Reference postImageRef = storage.ref().child(imageLocation);
      final UploadTask uploadTask =
          postImageRef.putFile(File(newPost.pictures[i]));

      await uploadTask.whenComplete(() => _addPathToDatabase(imageLocation));
      print("Image url = " + newPost.url[i]);
    }

    // Add location and url to database
    await _firestore.collection('items').doc().set({
      'url': newPost.url,
      'title': newPost.title,
      'price': newPost.price,
      'description': newPost.description,
      'user': loggedInUser.email,
    });
  }

  Future<void> _addPathToDatabase(String text) async {
    try {
      // Get image URL from firebase
      FirebaseStorage storage = FirebaseStorage.instance;
      final ref = storage.ref().child(text);
      newPost.url.add(await ref.getDownloadURL());
    } catch (e) {
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
  }

  // Create a click button in the bottom of the application
  ElevatedButton createButton({String buttonName}) {
    return ElevatedButton(
      child: Text(
        buttonName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Hyer Garage Sale'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            TextCard(
              title: 'Title',
              hintText: 'What are you selling?',
              textIn: (newTitle) {
                newPost.title = newTitle;
              },
              price: false,
              numberKeyboard: false,
            ),
            SizedBox(height: 16),
            TextCard(
              title: 'Price',
              hintText: 'Enter your selling price!',
              textIn: (newValue) {
                newPost.price = newValue;
              },
              price: true,
              numberKeyboard: true,
            ),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Enter the description of the item',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      newPost.description = value;
                    },
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length == 0
                        ? null
                        : Image.file(
                            File(newPost.pictures[0]),
                            height: 80,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length <= 1
                        ? null
                        : Image.file(
                            File(newPost.pictures[1]),
                            height: 80,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length <= 2
                        ? null
                        : Image.file(
                            File(newPost.pictures[2]),
                            height: 80,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length <= 3
                        ? null
                        : Image.file(
                            File(newPost.pictures[3]),
                            height: 80,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.camera_alt),
        heroTag: 'picture',
        onPressed: () async {
          if (newPost.pictures.length == 4) {
            showErrorNotification(context, 'No More than 4 Pictures!!!');
          } else {
            final cameras = await availableCameras();
            final camera = cameras.first;
            if (cameras == null || cameras.length == 0) {
              print('No Camera!!!!');
            }
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraScreen(camera: camera),
              ),
            );
            print(result);
            setState(() {
              newPost.pictures.add(result);
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _nameController.clear();
                _originalController.clear();
                _descriptionController.clear();
                Navigator.pop(context, 'Cancel');
              },
            ),
            SizedBox(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
              ),
              child: Text(
                'Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                try {
                  uploadImage();
                  Navigator.pop(context, 'Post');
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ),
    );
  }

  void choiceAction(String choice) {
    print('working');
  }
}
