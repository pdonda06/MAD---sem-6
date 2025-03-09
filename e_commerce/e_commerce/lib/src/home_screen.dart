import 'package:flutter/material.dart';
import 'login_signup_screen.dart';

class Item {
  final String name;
  final String description;
  final double price;

  Item(this.name, this.description, this.price);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Item> _items = [
    Item('Laptop', 'High-performance gaming laptop', 999.99),
    Item('Smartphone', 'Latest model with great camera', 699.99),
    Item('Headphones', 'Noise-cancelling wireless headphones', 199.99),
    Item('Smartwatch', 'Fitness tracking and notifications', 299.99),
    Item('Tablet', '10-inch display with stylus support', 449.99),
    Item('Gaming Console', '4K gaming with wireless controllers', 499.99),
    Item('Camera', 'Mirrorless camera with 4K video', 899.99),
    Item('Speakers', 'Wireless surround sound system', 399.99),
    Item('Monitor', '27-inch 4K HDR display', 349.99),
    Item('Keyboard', 'Mechanical RGB gaming keyboard', 129.99),
    Item('Mouse', 'Wireless gaming mouse with RGB', 79.99),
    Item('Microphone', 'USB condenser microphone', 149.99),
    Item('Webcam', '1080p webcam with auto-focus', 89.99),
    Item('Power Bank', '20000mAh fast charging', 49.99),
    Item('External SSD', '1TB portable SSD drive', 159.99),
    Item('Router', 'Dual-band WiFi 6 router', 199.99),
    Item('Printer', 'All-in-one wireless printer', 249.99),
    Item('Game Controller', 'Wireless game controller', 59.99),
    Item('Graphics Card', '8GB GDDR6 gaming GPU', 599.99),
    Item('Docking Station', 'USB-C dock with multiple ports', 179.99),
  ];

  final List<Item> _cart = [];
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _addToCart(Item item) {
    setState(() {
      _cart.add(item);
    });

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFromCart(Item item) {
    setState(() {
      _cart.remove(item);
    });
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${item.name} removed from cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple, // Change AppBar color
          title: const Text(
            'Tech Store',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 5, // Adding shadow to cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            color: Colors.deepPurple,
                            onPressed: () => _addToCart(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return Hero(
                          tag: item.name, // Unique tag for each item
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 500),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.remove_shopping_cart),
                                      color: Colors.red,
                                      onPressed: () => _removeFromCart(item),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Text(
                    'Total: \$${_cart.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
