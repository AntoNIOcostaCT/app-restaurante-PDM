import '../models/database_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';

class OrderService {
  Future<bool> createOrder(Order order, List<Product> products) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Create order
      final orderId = await db.insert('orders', order.toMap());
      
      // Create order items
      for (var product in products) {
        final orderItem = OrderItem(
          orderId: orderId,
          productId: product.id!,
          quantity: 1,
          unitPrice: product.price,
        );
        await db.insert('order_items', orderItem.toMap());
      }
      
      return true;
    } catch (e) {
      print('Create order error: $e');
      return false;
    }
  }

  Future<List<Order>> getAllOrders() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('orders', orderBy: 'created_at DESC');
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'orders',
        {'status': status},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      return true;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT oi.*, p.name as product_name, p.price as product_price
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    ''', [orderId]);
    
    return maps.map((map) => OrderItem.fromMap(map)).toList();
  }
}