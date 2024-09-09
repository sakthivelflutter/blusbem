import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:serialble/features/choosedevice/screen/choosedevice.dart';
import 'package:serialble/features/home/screen/home_screen.dart';
import 'package:serialble/theme/theme.dart';
 late final status ;
void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  status = await Permission.storage.request();
  GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Terminal Manager',
      theme: defaultTheme,
      debugShowCheckedModeBanner: false,
      home: const SelectBondedDevicePage(checkAvailability: false,),
    );
  }
}
