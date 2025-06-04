class Session {
  final int? id;
  final int tableId;
  final String sessionCode;
  final String status;
  final DateTime? createdAt;

  Session({
    this.id,
    required this.tableId,
    required this.sessionCode,
    this.status = 'active',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_id': tableId,
      'session_code': sessionCode,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      tableId: map['table_id'],
      sessionCode: map['session_code'],
      status: map['status'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
