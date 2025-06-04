import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/session.dart';
import '../models/restaurant_table.dart';
import '../models/product.dart';
import '../models/order.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  Session? _currentSession;
  RestaurantTable? _currentTable;
  List<Product> _cart = [];
  List<Order> _orders = [];
  String _currentUserRole = '';

  // Getters
  User? get currentUser => _currentUser;
  Session? get currentSession => _currentSession;
  RestaurantTable? get currentTable => _currentTable;
  List<Product> get cart => List.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  String get currentUserRole => _currentUserRole;
  bool get isLoggedIn => _currentUser != null;
  bool get hasActiveSession => _currentSession != null;
  int get cartItemCount => _cart.length;
  double get cartTotal => _cart.fold(0.0, (sum, product) => sum + product.price);

  // Authentication
  void setCurrentUser(User? user) {
    _currentUser = user;
    _currentUserRole = user?.role ?? '';
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentUserRole = '';
    _currentSession = null;
    _currentTable = null;
    _cart.clear();
    _orders.clear();
    notifyListeners();
  }

  // Session management
  void setCurrentSession(Session? session) {
    _currentSession = session;
    notifyListeners();
  }

  void setCurrentTable(RestaurantTable? table) {
    _currentTable = table;
    notifyListeners();
  }

  void endSession() {
    _currentSession = null;
    _currentTable = null;
    _cart.clear();
    notifyListeners();
  }

  // Cart management
  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  bool isInCart(Product product) {
    return _cart.any((item) => item.id == product.id);
  }

  int getProductQuantityInCart(Product product) {
    return _cart.where((item) => item.id == product.id).length;
  }

  // Orders management
  void setOrders(List<Order> orders) {
    _orders = orders;
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void removeOrder(int orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

  // Utility methods
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> getPendingOrders() {
    return getOrdersByStatus('pending');
  }

  List<Order> getInProgressOrders() {
    return getOrdersByStatus('in_progress');
  }

  List<Order> getCompletedOrders() {
    return getOrdersByStatus('completed');
  }

  // Role checking
  bool get isAdmin => _currentUserRole == 'admin';
  bool get isClient => _currentUserRole == 'client';
  bool get isKitchen => _currentUserRole == 'kitchen';

  // Debug methods
  void debugPrintState() {
    print('=== App State Debug ===');
    print('Current User: ${_currentUser?.name} (${_currentUser?.role})');
    print('Current Session: ${_currentSession?.sessionCode}');
    print('Current Table: ${_currentTable?.number}');
    print('Cart Items: ${_cart.length}');
    print('Orders: ${_orders.length}');
    print('====================');
  }
}