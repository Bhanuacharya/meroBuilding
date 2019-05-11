import 'package:flutter/material.dart';

import './location_data.dart';

class Product {
  final String id;
  final String verificationStatus;
  final String creationDate;
  final String userEmail;
  final String image;
  final String userId;

  Product(
      {@required this.id,
      @required this.verificationStatus,
      @required this.creationDate,
      @required this.userEmail,
      @required this.image,
      @required this.userId,});
}
