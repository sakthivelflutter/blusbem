import 'package:flutter/material.dart';
import 'package:serialble/features/choosedevice/screen/choosedevice.dart';
import 'package:serialble/features/home/screen/home_screen.dart';
import 'package:serialble/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Flutter Demo',
      theme: defaultTheme,
      home: const SelectBondedDevicePage(checkAvailability: false,),
    );
  }
}
