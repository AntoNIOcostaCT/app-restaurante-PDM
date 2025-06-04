import '../models/database_helper.dart';
import '../models/user.dart';

class UserService {
  Future<User?> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> createUser(User user) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('users', user.toMap());
      return true;
    } catch (e) {
      print('Create user error: $e');
      return false;
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}