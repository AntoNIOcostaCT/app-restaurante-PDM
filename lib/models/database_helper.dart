import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nowaiter.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'client'
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        available BOOLEAN DEFAULT 1,
        image_url TEXT
      )
    ''');

    // Tables table (restaurant tables)
    await db.execute('''
      CREATE TABLE restaurant_tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER UNIQUE NOT NULL,
        capacity INTEGER NOT NULL,
        status TEXT DEFAULT 'available'
      )
    ''');

    // Sessions table (for group orders)
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_id INTEGER NOT NULL,
        session_code TEXT UNIQUE NOT NULL,
        status TEXT DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (table_id) REFERENCES restaurant_tables (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        user_name TEXT,
        total_amount REAL DEFAULT 0,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES sessions (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    // Sample users
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@nowaiter.com',
      'password': 'admin123',
      'role': 'admin'
    });

    // Sample products
    final categories = ['Bebidas', 'Entradas', 'Carnes', 'Peixes', 'Vegetariano', 'Sobremesas'];
    final sampleProducts = [
      {'name': 'Água', 'description': 'Água natural 50cl', 'price': 1.5, 'category': 'Bebidas'},
      {'name': 'Coca-Cola', 'description': 'Refrigerante 33cl', 'price': 2.5, 'category': 'Bebidas'},
      {'name': 'Vinho Tinto', 'description': 'Vinho da casa', 'price': 12.0, 'category': 'Bebidas'},
      {'name': 'Pão com Manteiga', 'description': 'Pão caseiro com manteiga', 'price': 3.0, 'category': 'Entradas'},
      {'name': 'Azeitonas', 'description': 'Azeitonas da casa', 'price': 4.5, 'category': 'Entradas'},
      {'name': 'Bife à Portuguesa', 'description': 'Bife com ovo e batatas', 'price': 15.5, 'category': 'Carnes'},
      {'name': 'Frango Assado', 'description': 'Meio frango assado com batatas', 'price': 12.0, 'category': 'Carnes'},
      {'name': 'Bacalhau à Brás', 'description': 'Bacalhau desfiado com batatas e ovos', 'price': 14.0, 'category': 'Peixes'},
      {'name': 'Salmão Grelhado', 'description': 'Salmão grelhado com legumes', 'price': 18.0, 'category': 'Peixes'},
      {'name': 'Salada Mista', 'description': 'Salada com ingredientes frescos', 'price': 8.5, 'category': 'Vegetariano'},
      {'name': 'Mousse de Chocolate', 'description': 'Mousse caseira de chocolate', 'price': 4.5, 'category': 'Sobremesas'},
    ];

    for (var product in sampleProducts) {
      await db.insert('products', product);
    }

    // Sample restaurant tables
    for (int i = 1; i <= 20; i++) {
      await db.insert('restaurant_tables', {
        'number': i,
        'capacity': i <= 10 ? 4 : 6,
        'status': 'available'
      });
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}