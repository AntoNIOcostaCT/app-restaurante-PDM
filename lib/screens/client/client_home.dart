import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/product.dart';
import '../../models/restaurant_table.dart';
import '../../models/session.dart';
import '../../models/order.dart';
import '../../services/product_service.dart';
import '../../services/table_service.dart';
import '../../services/session_service.dart';
import '../../services/order_service.dart';
import 'dart:math';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  final _productService = ProductService();
  final _tableService = TableService();
  final _sessionService = SessionService();
  final _orderService = OrderService();
  
  List<Product> _products = [];
  List<RestaurantTable> _tables = [];
  List<Product> _cart = [];
  Session? _currentSession;
  String _selectedCategory = 'Todos';
  bool _isLoading = true;
  bool _showTableSelection = false;
  bool _showMenu = false;
  
  final List<String> _categories = [
    'Todos', 'Bebidas', 'Entradas', 'Carnes', 'Peixes', 'Vegetariano', 'Sobremesas'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await _productService.getAllProducts();
      final tables = await _tableService.getAllTables();
      
      setState(() {
        _products = products;
        _tables = tables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erro ao carregar dados: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectTable(RestaurantTable table) async {
    if (table.status != 'available') {
      _showErrorSnackBar('Mesa não disponível');
      return;
    }

    try {
      // Generate session code
      final sessionCode = _generateSessionCode();
      
      final session = Session(
        tableId: table.id!,
        sessionCode: sessionCode,
        status: 'active',
        createdAt: DateTime.now(),
      );

      final createdSession = await _sessionService.createSession(session);
      await _tableService.updateTableStatus(table.id!, 'occupied');

      if (createdSession != null) {
        setState(() {
          _currentSession = createdSession;
          _showTableSelection = false;
          _showMenu = true;
        });
        _showSuccessSnackBar('Mesa ${table.number} selecionada! Código: $sessionCode');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar mesa: $e');
    }
  }

  String _generateSessionCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    _showSuccessSnackBar('${product.name} adicionado ao carrinho');
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) {
      _showErrorSnackBar('Carrinho vazio');
      return;
    }

    if (_currentSession == null) {
      _showErrorSnackBar('Nenhuma mesa selecionada');
      return;
    }

    try {
      final user = context.read<AppState>().currentUser;
      final userName = user?.name ?? 'Convidado';
      
      final totalAmount = _cart.fold(0.0, (sum, product) => sum + product.price);
      
      final order = Order(
        sessionId: _currentSession!.id!,
        userName: userName,
        totalAmount: totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final success = await _orderService.createOrder(order, _cart);
      
      if (success) {
        setState(() {
          _cart.clear();
        });
        _showSuccessSnackBar('Pedido realizado com sucesso!');
      } else {
        _showErrorSnackBar('Erro ao realizar pedido');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao realizar pedido: $e');
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Todos') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  double get _cartTotal {
    return _cart.fold(0.0, (sum, product) => sum + product.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoWaiter'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_currentSession != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Mesa ${_tables.firstWhere((t) => t.id == _currentSession?.tableId).number}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: Badge(
              label: Text(_cart.length.toString()),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: _showCartDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: _currentSession == null
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _showTableSelection = true),
              backgroundColor: Colors.purple,
              label: const Text('Selecionar Mesa'),
              icon: const Icon(Icons.table_restaurant),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_showTableSelection) {
      return _buildTableSelection();
    } else if (_showMenu || _currentSession != null) {
      return _buildMenu();
    } else {
      return _buildWelcome();
    }
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 100,
            color: Colors.purple,
          ),
          const SizedBox(height: 20),
          const Text(
            'Bem-vindo ao NoWaiter!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Selecione uma mesa para começar',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showTableSelection = true),
            icon: const Icon(Icons.table_restaurant),
            label: const Text('Selecionar Mesa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showTableSelection = false),
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                'Selecione uma Mesa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _tables.length,
            itemBuilder: (context, index) {
              final table = _tables[index];
              final isAvailable = table.status == 'available';
              
              return GestureDetector(
                onTap: isAvailable ? () => _selectTable(table) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                    border: Border.all(
                      color: isAvailable ? Colors.green : Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant,
                        size: 30,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Mesa ${table.number}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      Text(
                        '${table.capacity} lugares',
                        style: TextStyle(
                          fontSize: 12,
                          color: isAvailable ? Colors.green.shade600 : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenu() {
    return Column(
      children: [
        // Category tabs
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: Colors.purple.shade100,
                  checkmarkColor: Colors.purple,
                ),
              );
            },
          ),
        ),
        
        // Products grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              
              return Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.description!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '€${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _addToCart(product),
                                icon: const Icon(Icons.add_shopping_cart),
                                color: Colors.purple,
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Carrinho de Compras'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _cart.isEmpty
              ? const Center(child: Text('Carrinho vazio'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final product = _cart[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('€${product.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                _removeFromCart(index);
                                Navigator.of(context).pop();
                                _showCartDialog();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '€${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          if (_cart.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _placeOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Fazer Pedido'),
            ),
        ],
      ),
    );
  }
}