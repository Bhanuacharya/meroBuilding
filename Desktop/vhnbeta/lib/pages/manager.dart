import 'package:flutter/material.dart';

import './editpagetest.dart';
import './list_page.dart';


import '../scoped_modal/main.dart';
import 'package:scoped_model/scoped_model.dart';

class Manager extends StatefulWidget {
  
  final MainModel model;

  Manager(this.model);

  _ManagerState createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.create),
                  text: 'Create',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Manage',
                ),
              ],
            ),
            title: Text('Manage VHN'),
            centerTitle: true,
          ),
          body: TabBarView(
            children: <Widget>[
              ProductEditPage(),
              ListPage(widget.model),
            ],
          ),
        ),
      ),
    );
  }
}
