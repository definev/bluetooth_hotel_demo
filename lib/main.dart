import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:smarthotel/check_in_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Hotel Demo',
      theme: FlexThemeData.light(scheme: FlexScheme.purpleBrown),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.purpleBrown),
      home: const CheckInDemo(),
    );
  }
}
