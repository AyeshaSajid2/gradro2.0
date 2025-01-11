import 'package:connect/utils/freeman.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';

import 'const/duration_adapter.dart';
import 'const/offset_adopter.dart';
import 'hive_data/hive_model.dart';
import 'hive_data/hive_service.dart';
import 'hive_data/track_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(FruitAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(OffsetAdapter());
  // Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(TrackAdapter());

  // Open boxes
  final fruitBox = await Hive.openBox<Fruit>('fruitBox');
  await Hive.openBox<Track>('trackBox');
  final fruitService = FruitService(fruitBox);
  await fruitService.initializeFruits();

  final savedFruitsBox = await Hive.openBox('gardenState');
  final List<Fruit> gardenFruits = (savedFruitsBox.get('gardenFruits')
              as List<dynamic>?)
          ?.map((item) => item as Fruit) // Explicitly cast each item to Fruit
          .toList() ??
      []; // Return an empty list if null

  // Set device orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  // Run the app
  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        builder: (context, child) {
          return FreemanApp();
        },
      ),
    ),
  );
}
