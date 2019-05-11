import 'dart:convert';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/location_data.dart';
import '../models/member.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  List<Member> _member = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_member);
  }

  List<Product> get displayedProducts {
    return List.from(_member);
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }

    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> addProduct(String verificationStatus, String creationDate, String image) async {
    _isLoading = true;
    notifyListeners();
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> productData = {
      'verificationStatus': 0,
      'creationDate': creationDate,
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    final Map<String, dynamic> memberData = {
      'admin':'1',
      'verification':'0',
    };
    try {
      final http.Response response = await http.put(
          'https://virtual-home-number.firebaseio.com/products/$timestamp.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData),
          );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      //member add
      final http.Response response2 = await http.put(
          'https://virtual-home-number.firebaseio.com/products/${timestamp}/members/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(memberData),
          );

      if (response2.statusCode != 200 && response2.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    // .catchError((error) {
    //   _isLoading = false;
    //   notifyListeners();
    //   return false;
    // });
  }

  Future<bool> addMember(String userId,String vhn) async {
    _isLoading = true;
    notifyListeners();
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    final Map<String, String> memberData = {
      userId: '0',
    };
    try {
      final http.Response response = await http.put(
          'https://virtual-home-number.firebaseio.com/products/$vhn/members.json?auth=${_authenticatedUser.token}',
          body: json.encode(memberData),
          );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Member newMember = Member(
          id: responseData['name'],
          verificationStatus: '0',
          userId: userId,);
      _member.add(newMember);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    // .catchError((error) {
    //   _isLoading = false;
    //   notifyListeners();
    //   return false;
    // });
  }

  Future<bool> updateProduct(String verificationStatus, String creationDate, String image) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'verificationStatus': verificationStatus,
      'creationDate': creationDate,
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
      // 'price': price,
      // 'loc_lat': locData.latitude,
      // 'loc_lng': locData.longitude,
      // 'loc_address': locData.address,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
            'https://virtual-home-number.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(updateData))
        .then((http.Response reponse) {
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          verificationStatus: verificationStatus,
          creationDate: creationDate,
          image:
          'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    return http
        .delete(
            'https://virtual-home-number.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://virtual-home-number.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            verificationStatus: productData['verificationStatus'],
            creationDate: productData['creationDate'],
            image: productData['image'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            // isFavorite: productData['wishlistUsers'] == null
            //     ? false
            //     : (productData['wishlistUsers'] as Map<String, dynamic>)
            //         .containsKey(_authenticatedUser.id)
                    );
        fetchedProductList.add(product);
      });
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAOdL5tFFfwnviicwhie171And0dpR-_ME',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAOdL5tFFfwnviicwhie171And0dpR-_ME',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
