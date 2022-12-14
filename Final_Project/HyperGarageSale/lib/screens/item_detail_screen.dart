import 'package:flutter/material.dart';

class ItemDetail extends StatelessWidget {
  static String id = 'item_detail_screen';

  ItemDetail(
      {this.userD,
      this.priceD,
      this.titleD,
      this.descriptionD,
      this.imagePathD});

  final String userD;
  final String titleD;
  final String priceD;
  final String descriptionD;
  final List<String> imagePathD;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text('Hyper Garage Sale'),
      ),
      body: ListView(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: imagePathD.length == 0
                        ? null
                        : AspectRatio(
                            aspectRatio: 13 / 10,
                            child: Image.network(
                              imagePathD[0],
                              height: 80,
                              fit: BoxFit.fitWidth,
                            ),
                          )),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: imagePathD.length <= 1
                      ? null
                      : AspectRatio(
                          aspectRatio: 13 / 10,
                          child: Image.network(
                            imagePathD[1],
                            height: 80,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: imagePathD.length <= 2
                      ? null
                      : AspectRatio(
                          aspectRatio: 13 / 10,
                          child: Image.network(
                            imagePathD[2],
                            height: 80,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: imagePathD.length <= 3
                      ? null
                      : AspectRatio(
                          aspectRatio: 13 / 10,
                          child: Image.network(
                            imagePathD[3],
                            height: 80,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                titleD,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                '\$' + priceD,
                style: TextStyle(fontSize: 30),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'On sale by   ' + userD,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            descriptionD,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
