import 'package:flutter/material.dart';

import '../screens/home.dart';
import 'freeman.dart';

// import 'package:freeman/src/Screens/vr_view.dart';

class Routes {
  static const String home = '/home';
  static const String camView = '/camView';
  static const String camView2 = '/camView2';

  // static const String vegDetails = '/vegDetails';
  // static const String vegList = '/vegList';
  // static const String objDet = '/objDet'; // Updated this to match convention

  // Define routes here
  static final routes = {
    home: (_) => HomePage(),
  };

  // Static method for pushing a new page
  static pushPage(Widget page) {
    Navigator.push(navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => page));
  }

  // Push named route (with arguments)
  static pushNamed(String route, {arguments}) {
    if (ModalRoute.of(navigatorKey.currentState!.context)?.settings.name !=
        route) {
      Navigator.pushNamed(
        navigatorKey.currentState!.context,
        route,
        arguments: arguments,
      );
    }
  }

  // Push named route with replacement
  static pushReplacementNamed(String route, {arguments}) {
    if (ModalRoute.of(navigatorKey.currentState!.context)?.settings.name !=
        route) {
      Navigator.pushReplacementNamed(
        navigatorKey.currentState!.context,
        route,
        arguments: arguments,
      );
    }
  }

  // Go back to the previous page
  static dynamic goBack({dynamic result}) {
    return Navigator.maybePop(navigatorKey.currentState!.context, result);
  }

  // Navigate to the home page
  static goToHome() {
    if (ModalRoute.of(navigatorKey.currentState!.context)?.settings.name !=
        home) {
      Navigator.pushNamed(
        navigatorKey.currentState!.context,
        home,
      );
    }
  }

  // Push named and remove all routes until home
  static void pushNamedAndRemoveUntil(String route) {
    if (ModalRoute.of(navigatorKey.currentState!.context)?.settings.name !=
        route) {
      Navigator.of(navigatorKey.currentState!.context)
          .pushNamedAndRemoveUntil(route, (route) => false);
    }
  }
}
