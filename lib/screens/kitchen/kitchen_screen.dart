import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen>
    with TickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
    
    // Refresh orders every 30 seconds
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadOrders();
        _startPeriodicRefresh();
      }
    });
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _orderService.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      
      // Update app state
      if (mounted) {
        context.read<AppState>().setOrders(orders);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erro ao carregar pedidos: $e');
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      final success = await _orderService.updateOrderStatus(order.id!, newStatus);
      if (success) {
        await _loadOrders();
        _showSuccessSnackBar('Estado do pedido atualizado');
      } else {
        _showErrorSnackBar('Erro ao atualizar estado do pedido');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar pedido: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<Order> _getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cozinha - NoWaiter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AppState>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Pendentes',
              icon: Badge(
                label: Text('${_getOrdersByStatus('pending').length}'),
                child: const Icon(Icons.schedule),
              ),
            ),
            Tab(
              text: 'Preparação',
              icon: Badge(
                label: Text('${_getOrdersByStatus('in_progress').length}'),
                // CORREÇÃO: Icons.cooking não existe, usar Icons.restaurant
                child: const Icon(Icons.restaurant),
              ),
            ),
            Tab(
              text: 'Prontos',
              icon: Badge(
                label: Text('${_getOrdersByStatus('completed').length}'),
                child: const Icon(Icons.check_circle),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text('Carregando pedidos...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('pending'),
                _buildOrdersList('in_progress'),
                _buildOrdersList('completed'),
              ],
            ),
    );
  }

  Widget _buildOrdersList(String status) {
    final orders = _getOrdersByStatus(status);
    
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, status);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, String currentStatus) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(currentStatus),
          child: Text(
            order.id.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Mesa ${order.sessionId} - ${order.userName ?? "Cliente"}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: €${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            Text(
              order.createdAt != null ? _formatDateTime(order.createdAt!) : 'Data não disponível',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: _buildStatusActions(order, currentStatus),
        children: [
          _buildOrderItemsList(order),
        ],
      ),
    );
  }

  Widget _buildStatusActions(Order order, String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order, 'in_progress'),
          icon: const Icon(Icons.restaurant, size: 16),
          label: const Text('Iniciar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
        );
      case 'in_progress':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order, 'completed'),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Pronto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
        );
      case 'completed':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order, 'delivered'),
          icon: const Icon(Icons.delivery_dining, size: 16),
          label: const Text('Entregue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOrderItemsList(Order order) {
    return FutureBuilder<List<OrderItem>>(
      future: _orderService.getOrderItems(order.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar itens: ${snapshot.error}'),
          );
        }

        final items = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Itens do Pedido:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => _buildOrderItem(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.quantity}x ${item.productName ?? "Produto"}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '€${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.restaurant;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Nenhum pedido pendente';
      case 'in_progress':
        return 'Nenhum pedido em preparação';
      case 'completed':
        return 'Nenhum pedido pronto';
      default:
        return 'Nenhum pedido encontrado';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}