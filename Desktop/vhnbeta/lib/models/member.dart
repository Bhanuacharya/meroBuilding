import 'package:flutter/material.dart';

import './location_data.dart';

class Member {
  final String id;
  final String verificationStatus;
  final String userId;

  Member(
      {@required this.id,
      @required this.verificationStatus,
      @required this.userId,});
}
