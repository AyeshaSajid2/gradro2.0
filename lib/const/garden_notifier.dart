import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../hive_data/hive_model.dart';

final garden1Provider = StateNotifierProvider<GardenNotifier, List<Fruit>>((ref) {
  return GardenNotifier();
});

final gardenNameProvider = StateNotifierProvider<GardenNameNotifier, List<String>>((ref) {
  return GardenNameNotifier();
});

class GardenNameNotifier extends StateNotifier<List<String>> {
  GardenNameNotifier() : super(["Garden 1", "Garden 2", "Garden 3", "Garden 4", "Garden 5"]);

  void updateGardenName(int index, String name) {
    state = [
      ...state.sublist(0, index),
      name,
      ...state.sublist(index + 1),
    ];
  }
}

class GardenNotifier extends StateNotifier<List<Fruit>> {
  GardenNotifier() : super([]);

  void addFruit(Fruit fruit) {
    state = [...state, fruit];
  }

  void removeFruit(Fruit fruit) {
    state = state.where((f) => f != fruit).toList();
  }

  // Clear all fruits from the garden
  void clearGarden() {
    state = [];
  }

  // Load fruits from a data source (example Hive)
  void loadFruits(List<Fruit> fruits) {
    state = fruits;
  }
}



// State provider for Garden2Screen
final garden2Provider = StateNotifierProvider<Garden2Notifier, List<Fruit>>((ref) {
  return Garden2Notifier();
});

final garden3Provider = StateNotifierProvider<Garden3Notifier, List<Fruit>>((ref) {
  return Garden3Notifier();
});

final garden4Provider = StateNotifierProvider<Garden4Notifier, List<Fruit>>((ref) {
  return Garden4Notifier();
});

final garden5Provider = StateNotifierProvider<Garden5Notifier, List<Fruit>>((ref) {
  return Garden5Notifier();
});

// Notifier class for Garden1
class Garden1Notifier extends StateNotifier<List<Fruit>> {
  Garden1Notifier() : super([]);

  void addFruit(Fruit fruit) {
    state = [...state, fruit];
  }

  void removeFruit(Fruit fruit) {
    state = state.where((f) => f != fruit).toList();
  }
}


// Notifier class for Garden2
class Garden2Notifier extends StateNotifier<List<Fruit>> {
  Garden2Notifier() : super([]);

  void addFruit(Fruit fruit) {
    state = [...state, fruit];
  }

  void removeFruit(Fruit fruit) {
    state = state.where((f) => f != fruit).toList();
  }
  // Clear all fruits from the garden
  void clearGarden() {
    state = [];
  }

  // Load fruits from a data source (example Hive)
  void loadFruits(List<Fruit> fruits) {
    state = fruits;
  }
}

// Notifier class for Garden3
class Garden3Notifier extends StateNotifier<List<Fruit>> {
  Garden3Notifier() : super([]);

  void addFruit(Fruit fruit) {
    state = [...state, fruit];
  }

  void removeFruit(Fruit fruit) {
    state = state.where((f) => f != fruit).toList();
  }

  // Clear all fruits from the garden
  void clearGarden() {
    state = [];
  }

  // Load fruits from a data source (example Hive)
  void loadFruits(List<Fruit> fruits) {
    state = fruits;
  }
}

// Notifier class for Garden4
class Garden4Notifier extends StateNotifier<List<Fruit>> {
  Garden4Notifier() : super([]);

  void addFruit(Fruit fruit) {
    state = [...state, fruit];
  }

  void removeFruit(Fruit fruit) {
    state = state.where((f) => f != fruit).toList();
  }

  // Clear all fruits from the garden
  void clearGarden() {
    state = [];
  }

  // Load fruits from a data source (example Hive)
  void loadFruits(List<Fruit> fruits) {
    state = fruits;
  }
}

// Notifier class for Garden5
class Garden5Notifier extends StateNotifier<List<Fruit>> {
  Garden5Notifier() : super([]);

  void addFruit(Fruit fruit) {
    state = [...state, fruit];
  }

  void removeFruit(Fruit fruit) {
    state = state.where((f) => f != fruit).toList();
  }

  // Clear all fruits from the garden
  void clearGarden() {
    state = [];
  }

  // Load fruits from a data source (example Hive)
  void loadFruits(List<Fruit> fruits) {
    state = fruits;
  }
}



