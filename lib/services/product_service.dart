import '../models/database_helper.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('products', orderBy: 'category, name');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<bool> createProduct(Product product) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('products', product.toMap());
      return true;
    } catch (e) {
      print('Create product error: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return true;
    } catch (e) {
      print('Update product error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }

  Future<Product?> getProductById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }
}