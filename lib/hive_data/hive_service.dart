import 'package:hive/hive.dart';
import 'hive_model.dart';

class FruitService {
  final Box<Fruit> _box;

  FruitService(this._box);

  // Initialize the box with default fruits if empty
  Future<void> initializeFruits() async {
    if (_box.isEmpty) {
      List<Fruit> fruits = [
        Fruit(
          name: 'Amaranthus',
          description: 'A leafy vegetable, rich in iron. Perfect for soups and stews.',
          spacing: 1,
          sun: 'Partial Sun',
          water: 'Low',
          season: 'Spring',
          frost: 'Sensitive',
          imagePath: 'assets/images/amaranthus.png',
        ),
        Fruit(
          name: 'Brinjal',
          description: 'A versatile vegetable, ideal for grilling. Thrives in warm weather.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'Medium',
          season: 'Summer',
          frost: 'Tolerant',
          imagePath: 'assets/images/brinjal.png',
        ),
        Fruit(
          name: 'Broccoli',
          description: 'High in vitamin C, great for salads. Requires cooler temperatures.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'High',
          season: 'Fall',
          frost: 'Sensitive',
          imagePath: 'assets/images/broccolli.png',
        ),
        Fruit(
          name: 'Cabbage',
          description: 'A green leafy vegetable. Suitable for stir-fries and slaws.',
          spacing: 1,
          sun: 'Partial Sun',
          water: 'Medium',
          season: 'Winter',
          frost: 'Tolerant',
          imagePath: 'assets/images/cabbage.png',
        ),
        Fruit(
          name: 'Celery',
          description: 'A green leafy vegetable. Suitable for stir-fries and slaws.',
          spacing: 1,
          sun: 'Partial Sun',
          water: 'Medium',
          season: 'Winter',
          frost: 'Tolerant',
          imagePath: 'assets/images/celery.png',
        ),
        Fruit(
          name: 'Carrot',
          description: 'A root vegetable, rich in beta-carotene. Best grown in sandy soil.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'Low',
          season: 'Spring',
          frost: 'Sensitive',
          imagePath: 'assets/images/carrot.png',
        ),
        Fruit(
          name: 'Cauliflower',
          description: 'A cruciferous vegetable, ideal for roasting. Prefers cool weather.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'High',
          season: 'Fall',
          frost: 'Sensitive',
          imagePath: 'assets/images/cauliflower.png',
        ),
        Fruit(
          name: 'Chilies',
          description: 'Spicy and vibrant, adds heat to dishes. Needs hot, dry conditions.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'Low',
          season: 'Summer',
          frost: 'Tolerant',
          imagePath: 'assets/images/chillies.png',
        ),
        Fruit(
          name: 'Mint',
          description: 'A fragrant herb, perfect for teas. Grows well in moist soil.',
          spacing: 1,
          sun: 'Partial Sun',
          water: 'High',
          season: 'Spring',
          frost: 'Sensitive',
          imagePath: 'assets/images/mint.png',
        ),
        Fruit(
          name: 'Okra',
          description: 'A pod vegetable, essential for stews. Thrives in warm, wet climates.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'Medium',
          season: 'Summer',
          frost: 'Tolerant',
          imagePath: 'assets/images/okra.png',
        ),
        Fruit(
          name: 'Spinach',
          description: 'A leafy green, packed with nutrients. Best grown in cooler weather.',
          spacing: 1,
          sun: 'Partial Sun',
          water: 'High',
          season: 'Fall',
          frost: 'Sensitive',
          imagePath: 'assets/images/spinach.png',
        ),
        Fruit(
          name: 'Tomatoes',
          description: 'A juicy fruit, great for sauces. Requires a lot of sunlight and water.',
          spacing: 1,
          sun: 'Full Sun',
          water: 'High',
          season: 'Summer',
          frost: 'Tolerant',
          imagePath: 'assets/images/tomatoes.png',
        ),
      ];

      for (var fruit in fruits) {
        await addFruit(fruit);
      }
    }
  }

  // Retrieve all fruits from the box
  List<Fruit> getAllFruits() {
    return _box.values.toList();
  }

  // Add a new fruit to the box
  Future<void> addFruit(Fruit fruit) async {
    await _box.put(fruit.name, fruit);
  }

  // Update an existing fruit in the box
  Future<void> updateFruit(Fruit fruit) async {
    await _box.put(fruit.name, fruit);
  }

  // Delete a fruit from the box
  Future<void> deleteFruit(String fruitName) async {
    await _box.delete(fruitName);
  }

  // Save the state of the garden
  Future<void> saveGardenState(String gardenName, List<Fruit> garden) async {
    final gardenBox = await Hive.openBox<List>('gardenBox');
    gardenBox.put(gardenName, garden.map((fruit) => fruit.key).toList());
  }

  // Load the state of the garden
  Future<List<Fruit>> loadGardenState(String gardenName) async {
    final gardenBox = await Hive.openBox<List>('gardenBox');
    final fruitKeys = gardenBox.get(gardenName, defaultValue: []);
    return fruitKeys!.map((key) => _box.get(key)).whereType<Fruit>().toList();
  }
}
