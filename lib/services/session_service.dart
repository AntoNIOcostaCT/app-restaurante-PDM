import '../models/database_helper.dart';
import '../models/session.dart';

class SessionService {
  Future<Session?> createSession(Session session) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('sessions', session.toMap());
      return Session(
        id: id,
        tableId: session.tableId,
        sessionCode: session.sessionCode,
        status: session.status,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Create session error: $e');
      return null;
    }
  }

  Future<Session?> getSessionByCode(String code) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'sessions',
      where: 'session_code = ?',
      whereArgs: [code],
    );
    
    if (maps.isNotEmpty) {
      return Session.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> updateSessionStatus(int sessionId, String status) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'sessions',
        {'status': status},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
      return true;
    } catch (e) {
      print('Update session status error: $e');
      return false;
    }
  }
}
