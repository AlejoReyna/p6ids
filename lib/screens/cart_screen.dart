// screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/email_service.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
      color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    child: Text('CHECKOUT'),
                    onPressed: cart.items.isEmpty ? null : () => _processCheckout(context),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Text(
                      'No hay productos en el carrito',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) => CartItemWidget(
                      cartItem: cart.items.values.toList()[i],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Future<void> _processCheckout(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    if (cart.items.isEmpty) return;

    final email = await _showEmailDialog(context);
    if (email == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator()),
      );

      // Crear la orden
      final order = cart.createOrder(email);
      
      // Guardar la orden
      final orderCreated = await _orderService.createOrder(order);
      if (!orderCreated) throw Exception('Error al crear la orden');

      // Enviar email
      final emailSent = await EmailService.sendOrderConfirmation(order);
      if (!emailSent) throw Exception('Error al enviar el email');

      // Limpiar carrito
      cart.clear();

      Navigator.of(context).pop(); // Cerrar loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Orden completada! Revisa tu email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la orden'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showEmailDialog(BuildContext context) {
    final _emailController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ingrese su email'),
        content: TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'ejemplo@correo.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Confirmar'),
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor ingrese un email válido')),
                );
                return;
              }
              Navigator.of(ctx).pop(email);
            },
          ),
        ],
      ),
    );
  }
}