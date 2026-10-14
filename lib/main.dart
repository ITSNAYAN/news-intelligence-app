import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_api_app/feature/auth/presentation/auth_gate.dart';
import 'package:news_api_app/feature/auth/presentation/auth_provider.dart';
import 'package:news_api_app/feature/auth/spalsh_screen/splash_screen_ui.dart';
import 'package:news_api_app/feature/favorites/data/fav_data_source.dart';

Future<void> main() async {
  // to make sure the Flutter engine and framework services are ready before we run our
  // asynchronous code
   WidgetsFlutterBinding.ensureInitialized();
   // initialize hive here 
   //1 set up hive storage folder here 
   await Hive.initFlutter();
   await Hive.openBox(FavoritesLocalDataSource.boxName);

   //2 open the box once here . to save the data 
   final authBox = await Hive.openBox<String>('auth_box');

  runApp(
    //initialize the provider here 
    ProviderScope(
       overrides: [authBoxProvider.overrideWithValue(authBox)],
      child: const MainApp())
      );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:AuthGate(),
    );
  }
}
