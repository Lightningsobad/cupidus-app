import 'package:flutter/material.dart';

import 'app/cupid_app.dart';
import 'core/di/service_locator.dart';

void main() {
  setupServiceLocator();
  runApp(const CupidApp());
}
