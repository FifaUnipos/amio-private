import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/produkmodel.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'unipos_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        productid TEXT PRIMARY KEY,
        name TEXT,
        price REAL,
        price_after REAL,
        price_online_shop REAL,
        price_online_shop_after REAL,
        isActive INTEGER,
        isPPN INTEGER,
        typeproducts TEXT,
        product_image TEXT,
        discount_type TEXT,
        discount INTEGER
      )
    ''');
  }

  // MARK: Product Operations
  Future<void> saveProducts(List<ModelDataProduk> products) async {
    final db = await database;
    Batch batch = db.batch();
    
    // Clear old products first or use conflictAlgorithm
    batch.delete('products');
    
    for (var product in products) {
      batch.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<ModelDataProduk>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return ModelDataProduk.fromJson(maps[i]);
    });
  }

  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }
}
