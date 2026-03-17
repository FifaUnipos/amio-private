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
      version: 9,
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
        transaction_id TEXT,
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
    await _createCacheTables(db);
    await _createDashboardCacheTable(db);
    await db.execute('''
      CREATE TABLE deletion_reasons (
        idkategori TEXT PRIMARY KEY,
        namakategori TEXT,
        typekategori TEXT
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
        timestamp INTEGER,
        payload TEXT,
        is_deleted INTEGER DEFAULT 0
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

  Future<void> _createCacheTables(Database db) async {
    await db.execute('''
      CREATE TABLE transaction_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        merchant_id TEXT,
        payload TEXT,
        timestamp INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE transaction_details_cache (
        transaction_id TEXT PRIMARY KEY,
        payload TEXT,
        timestamp INTEGER
      )
    ''');
  }

  Future<void> _createDashboardCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE dashboard_cache (
        key TEXT PRIMARY KEY,
        payload TEXT,
        timestamp INTEGER
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
    if (oldVersion < 5) {
      await _createCacheTables(db);
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE offline_transactions ADD COLUMN payload TEXT');
      } catch (e) {
        print("Error adding payload column: $e");
      }
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE offline_transactions ADD COLUMN is_deleted INTEGER DEFAULT 0');
        // Ensure sync_queue is ready for general use
        await db.execute('DROP TABLE IF EXISTS sync_queue');
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT,
            transaction_id TEXT,
            payload TEXT,
            timestamp INTEGER
          )
        ''');
      } catch (e) {
        print("Error upgrading to version 7: $e");
      }
    }
    if (oldVersion < 8) {
      try {
        await db.execute('''
          CREATE TABLE deletion_reasons (
            idkategori TEXT PRIMARY KEY,
            namakategori TEXT,
            typekategori TEXT
          )
        ''');
      } catch (e) {
        print("Error upgrading to version 8: $e");
      }
    }
    if (oldVersion < 9) {
      try {
        await _createDashboardCacheTable(db);
      } catch (e) {
        print("Error upgrading to version 9 (dashboard_cache): $e");
      }
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

  // MARK: Transaction Cache Operations
  Future<void> saveTransactionCache(String type, String merchantId, List<dynamic> payload) async {
    final db = await database;
    await db.delete('transaction_cache', where: 'type = ? AND merchant_id = ?', whereArgs: [type, merchantId]);
    await db.insert('transaction_cache', {
      'type': type,
      'merchant_id': merchantId,
      'payload': json.encode(payload),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<dynamic>?> getTransactionCache(String type, String merchantId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_cache',
      where: 'type = ? AND merchant_id = ?',
      whereArgs: [type, merchantId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return json.decode(maps.first['payload']);
    }
    return null;
  }

  Future<void> saveTransactionDetail(String transactionId, Map<String, dynamic> payload) async {
    final db = await database;
    await db.insert('transaction_details_cache', {
      'transaction_id': transactionId,
      'payload': json.encode(payload),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getTransactionDetail(String transactionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_details_cache',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    if (maps.isNotEmpty) {
      return json.decode(maps.first['payload']);
    }
    return null;
  }

  // MARK: Offline Transaction Operations
  Future<void> saveOfflineTransaction(Map<String, dynamic> transaction, List<Map<String, dynamic>> details) async {
    final db = await database;
    await db.transaction((txn) async {
      int offlineId = await txn.insert('offline_transactions', {
        'member_id': transaction['member_id'],
        'discount_id': transaction['discount_id'],
        'payment_method': transaction['payment_method'],
        'value': _toIntSafe(
          transaction['amount'] ?? 
          transaction['value'] ?? 
          (transaction['payments'] != null && (transaction['payments'] as List).isNotEmpty 
              ? transaction['payments'][0]['payment_value'] 
              : 0)
        ),
        'status': 'OFFLINE',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'payload': jsonEncode(transaction), // Store whole body here
      });

      for (var item in details) {
        await txn.insert('offline_transaction_details', {
          'offline_transaction_id': offlineId,
          'product_id': item['product_id'],
          'name': item['name'],
          'price': _toIntSafe(item['price'] ?? item['amount']),
          'quantity': _toIntSafe(item['quantity']),
          'description': item['description'],
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getOfflineTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> transactions = await db.query('offline_transactions', orderBy: 'timestamp DESC');
    
    List<Map<String, dynamic>> result = [];
    for (var tx in transactions) {
      List<dynamic> details = [];
      if (tx['payload'] != null) {
        final decoded = jsonDecode(tx['payload']);
        if (decoded is Map) {
          details = decoded['detail'] ?? [];
        } else {
          details = decoded;
        }
      }
      
      // If payload details are empty, try falling back to the separate table
      if (details.isEmpty) {
        final List<Map<String, dynamic>> dbDetails = await db.query(
          'offline_transaction_details',
          where: 'offline_transaction_id = ?',
          whereArgs: [tx['id']],
        );
        if (dbDetails.isNotEmpty) {
           details = dbDetails;
        }
      }
      
      Map<String, dynamic> txMap = Map<String, dynamic>.from(tx);
      txMap['details'] = details;
      result.add(txMap);
    }
    return result;
  }

  Future<void> clearOfflineTransactions() async {
    final db = await database;
    await db.delete('offline_transactions');
    await db.delete('offline_transaction_details');
  }

  Future<void> updateOfflineTransactionStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'offline_transactions',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteOfflineTransaction(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('offline_transactions', where: 'id = ?', whereArgs: [id]);
      await txn.delete('offline_transaction_details', where: 'offline_transaction_id = ?', whereArgs: [id]);
    });
  }

  Future<void> markOfflineTransactionDeleted(int id) async {
    final db = await database;
    await db.update(
      'offline_transactions',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addToSyncQueue(String action, String transactionId, Map<String, dynamic> payload) async {
    final db = await database;
    await db.insert('sync_queue', {
      'action': action,
      'transaction_id': transactionId,
      'payload': jsonEncode(payload),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  Future<void> deleteFromSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // MARK: Dashboard Cache Operations
  Future<void> saveDashboardCache(String key, Map<String, dynamic> payload) async {
    final db = await database;
    await db.insert(
      'dashboard_cache',
      {
        'key': key,
        'payload': json.encode(payload),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getDashboardCache(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dashboard_cache',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return json.decode(maps.first['payload']) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearDashboardCache() async {
    final db = await database;
    await db.delete('dashboard_cache');
  }

  // MARK: Deletion Reasons
  Future<void> saveDeletionReasons(List<dynamic> reasons) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('deletion_reasons');
      for (var reason in reasons) {
        await txn.insert('deletion_reasons', {
          'idkategori': reason['idkategori']?.toString(),
          'namakategori': reason['namakategori']?.toString(),
          'typekategori': reason['typekategori']?.toString(),
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getDeletionReasons() async {
    final db = await database;
    return await db.query('deletion_reasons');
  }

  int _toIntSafe(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.round();
    final s = v.toString().trim();
    final normalized = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    if (normalized.isEmpty) return def;
    final i = int.tryParse(normalized);
    if (i != null) return i;
    final d = double.tryParse(normalized);
    return d?.round() ?? def;
  }
}
