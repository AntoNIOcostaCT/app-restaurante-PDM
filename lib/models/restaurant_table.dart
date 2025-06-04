class RestaurantTable {
  final int? id;
  final int number;
  final int capacity;
  final String status;

  RestaurantTable({
    this.id,
    required this.number,
    required this.capacity,
    this.status = 'available',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'capacity': capacity,
      'status': status,
    };
  }

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    return RestaurantTable(
      id: map['id'],
      number: map['number'],
      capacity: map['capacity'],
      status: map['status'],
    );
  }
}