import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/milk_can.dart';

class MongoDatabase {
  static Db? _db;
  static DbCollection? _cansCollection;
  
  // The provided connection string
  static const String _connUri = "mongodb+srv://pinjarkaryash25_db_user:fDJ8UkoL2HqPLCzi@cluster0.omi3yqa.mongodb.net/MILKORA?retryWrites=true&w=majority";

  static Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      _db = await Db.create(_connUri);
      await _db!.open();
      _cansCollection = _db!.collection('milk_cans');
      
      // Auto-seed if the collection is empty
      final count = await _cansCollection!.count();
      if (count == 0) {
        await seedMockData();
      }
    } catch (e) {
      debugPrint("Error connecting to MongoDB: $e");
    }
  }

  static Future<List<MilkCan>> getCans() async {
    try {
      if (_db == null || !_db!.isConnected) {
        await connect();
      }
      if (_cansCollection == null) return MilkCan.mockCans;
      
      final cansData = await _cansCollection!.find().toList();
      if (cansData.isEmpty) return MilkCan.mockCans;

      return cansData.map((json) => MilkCan.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching cans: $e");
      return MilkCan.mockCans; // Fallback to mock data if there's an error
    }
  }

  static Future<void> seedMockData() async {
    try {
      if (_cansCollection != null) {
        for (var can in MilkCan.mockCans) {
          await _cansCollection!.insert(can.toJson());
        }
        debugPrint("Mock data seeded successfully.");
      }
    } catch (e) {
      debugPrint("Error seeding mock data: $e");
    }
  }
}
