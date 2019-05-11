import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './scoped_modal/main.dart';
import './pages/home.dart';
import './pages/manager.dart';
import './pages/map.dart';
import './pages/editpagetest.dart';
import './pages/auth.dart';

// import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

 @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.deepPurpleAccent,
            buttonColor: Colors.deepPurple),
        routes: {
          '/': (BuildContext context) => !_isAuthenticated ? AuthPage() :HomePage(_model),
          '/manager': (BuildContext context) => !_isAuthenticated ? AuthPage() :Manager(_model),
          '/map': (BuildContext context) => !_isAuthenticated ? AuthPage() :MapDetails(),
          '/products': (BuildContext context) => !_isAuthenticated ? AuthPage() :ProductEditPage(),

        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : HomePage(_model));
        },
      ),
    );
  }
}