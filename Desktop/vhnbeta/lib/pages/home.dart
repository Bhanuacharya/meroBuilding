import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter/material.dart';
import '../scoped_modal/main.dart';

class HomePage extends StatefulWidget {

  final MainModel model;

  HomePage(this.model);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home'),
        leading: Padding(
          padding: EdgeInsets.only(),
          child: IconButton(
            icon: Icon(Icons.add_location),
            onPressed: () {
              Navigator.pushNamed(context, '/manager');
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 5),
                  blurRadius: 12.5,
                  spreadRadius: 0.1,
                )
              ],
            ),
            margin: EdgeInsets.all(20),
            child: TextFormField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                icon: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.search),
                ),
                hintText: 'Enter VHN to search',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.0,
                    style: BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Chip(
                        label: Text('Thakali,Thamel'),
                        backgroundColor: Colors.lightGreen),
                  ),
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
            ),
          ),
        RaisedButton(
          onPressed: (){
            Navigator.pushNamed(context, '/map');
          },
          child: Text('Open Map'),
        )
        ],
      ),
    );
  }
}
