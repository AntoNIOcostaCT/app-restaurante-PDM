import '../models/database_helper.dart';
import '../models/restaurant_table.dart';

class TableService {
  Future<List<RestaurantTable>> getAllTables() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('restaurant_tables', orderBy: 'number');
    return maps.map((map) => RestaurantTable.fromMap(map)).toList();
  }

  Future<bool> updateTableStatus(int tableId, String status) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'restaurant_tables',
        {'status': status},
        where: 'id = ?',
        whereArgs: [tableId],
      );
      return true;
    } catch (e) {
      print('Update table status error: $e');
      return false;
    }
  }

  Future<RestaurantTable?> getTableById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'restaurant_tables',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return RestaurantTable.fromMap(maps.first);
    }
    return null;
  }
}
