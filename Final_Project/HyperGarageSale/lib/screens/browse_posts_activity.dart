import 'package:cloud_firestore/cloud_firestore.dart';
// firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hypergaragesale/model/post_data.dart';
import 'package:hypergaragesale/screens/item_detail_screen.dart';
import 'package:hypergaragesale/screens/new_post_activity.dart';
import 'package:intl/intl.dart';

import '../model/items.dart';
import '../model/items_repository.dart';

class BrowsePostsScreen extends StatefulWidget {
  static String id = 'browse_posts_screen';

  @override
  _BrowsePostsScreenState createState() => _BrowsePostsScreenState();
}

class _BrowsePostsScreenState extends State<BrowsePostsScreen> {
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  /// trigger the getCurrentUser()
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  /// Check to see if there is a current user who is signed in
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        // check the method
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // Action Bar
  void choiceAction<String>(String choice) {
    if (choice == Choice.addItem) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewPostScreen()));
    } else if (choice == Choice.signOut) {
      Navigator.pop(context);
    }
  }

  /// Make a collection of cards
  List<Card> _buildGridCards(BuildContext context) {
    List<Product> products = ProductsRepository.loadProducts(Category.all);

    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return products.map((product) {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: Image.asset(
                product.assetName,
                package: product.assetPackage,

                //Adjust the box size
                fit: BoxFit.fitWidth,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      formatter.format(product.price),
                      style: theme.textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            tooltip: 'Back',
            onPressed: () {
              /// Sign Out
              _auth.signOut();
              Navigator.pop(context);
            }),
        title: Text('Hyper Garage Sale'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Choice.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: MessagesStream(),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            IconButton(icon: Icon(Icons.home)),
            SizedBox(),
            IconButton(icon: Icon(Icons.person)),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ),
      floatingActionButton: AddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      child: Icon(Icons.add),
      onPressed: () {
        _onAdd(context);
      },
    );
  }

  _onAdd(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewPostScreen()));
//    Navigator.pushNamed(context, NewPostScreen.id);

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result sucessfully')));
  }
}

class Choice {
  static String addItem = 'Add Item';
  static String signOut = 'Sign Out';

  static List<String> choices = <String>[
    addItem,
    signOut,
  ];
}

/// Get the data from firebase
class MessagesStream extends StatelessWidget {
  List<Widget> itemList = [];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ),
          );
        }
        itemList = [];
        final messages = snapshot.data.docs;
        for (var message in messages) {
          final user = message.get('user');
          final price = message.get('price');
          final title = message.get('title');
          final description = message.get('description');
          final image_path = message.get('url');
          final item = PostData(
            user: user,
            price: price,
            title: title,
            description: description,
            imagePath: image_path.cast<String>(),
          );
          itemList.add(
            ListTile(
              title: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AspectRatio(
                      aspectRatio: 13 / 10,
                      child: Image.network(
                        item.imagePath == null
                            ? 'images/image.png'
                            : image_path[0],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '\$' + item.price,
                        style: theme.textTheme.bodyText2,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 8.0,
                        backgroundColor: Colors.black,
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        ),
                      ),
                      child: Text('Details'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemDetail(
                                      priceD: item.price,
                                      imagePathD: image_path.cast<String>(),
                                      userD: item.user,
                                      descriptionD: item.description,
                                      titleD: item.title,
                                    )));
                      }),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: itemList,
        );
      },
    );
  }
}
