import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:unipos_app_335/models/produkmodel.dart';
import 'dart:async';
import 'dart:convert';

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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT,
        productId TEXT,
        payload TEXT,
        timestamp INTEGER
      )
    ''');
    await _createTransactionTables(db);
    await db.execute('''
      CREATE TABLE product_variants (
        productid TEXT PRIMARY KEY,
        payload TEXT,
        timestamp INTEGER
      )
    ''');
  }

  Future<void> _createTransactionTables(Database db) async {
    await db.execute('''
      CREATE TABLE offline_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id TEXT,
        member_id TEXT,
        discount_id TEXT,
        payment_method TEXT,
        value REAL,
        status TEXT,
        timestamp INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE offline_transaction_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        offline_transaction_id INTEGER,
        product_id TEXT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        description TEXT,
        FOREIGN KEY (offline_transaction_id) REFERENCES offline_transactions (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT,
          productId TEXT,
          payload TEXT,
          timestamp INTEGER
        )
      ''');
    }
    if (oldVersion < 3) {
      await _createTransactionTables(db);
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE product_variants (
          productid TEXT PRIMARY KEY,
          payload TEXT,
          timestamp INTEGER
        )
      ''');
    }
  }

  // MARK: Product Operations
  Future<void> saveProducts(List<ModelDataProduk> products) async {
    final db = await database;
    Batch batch = db.batch();
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

  // MARK: Variant Operations
  Future<void> saveProductVariants(String productId, List<dynamic> variants) async {
    final db = await database;
    await db.insert('product_variants', {
      'productid': productId,
      'payload': json.encode(variants),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<dynamic>?> getProductVariants(String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_variants',
      where: 'productid = ?',
      whereArgs: [productId],
    );
    if (maps.isNotEmpty) {
      return json.decode(maps.first['payload']);
    }
    return null;
  }
}
