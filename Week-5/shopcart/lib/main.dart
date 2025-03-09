import 'package:flutter/material.dart';

void main() {
  runApp(const BookCartApp());
}

class BookCartApp extends StatelessWidget {
  const BookCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Cart',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BookListScreen(),
    );
  }
}

class Book {
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  Book({required this.title, required this.price, required this.imageUrl, this.quantity = 1});
}

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final List<Book> books = [
    Book(title: "Manifest: 7 Steps to Living Your Best Life", price: 899, imageUrl: "https://m.media-amazon.com/images/I/715u7p+38+L._AC_UF1000,1000_QL80_.jpg"),
    Book(title: "Steal Like an Artist", price: 499, imageUrl: "https://miro.medium.com/v2/resize:fit:868/0*Z-1JuULerq8byvxY.jpg"),
    Book(title: "Man's Search for Meaning", price: 299, imageUrl: "https://m.media-amazon.com/images/I/61157LApbuL.jpg"),
    Book(title: "The Zahir", price: 399, imageUrl: "https://m.media-amazon.com/images/I/71LQZg2f59L._AC_UF1000,1000_QL80_.jpg"),
    Book(title: "Who Says You Can't You Do", price: 799, imageUrl: "https://m.media-amazon.com/images/I/81nSOIq+crL._AC_UF1000,1000_QL80_.jpg"),
  ];

  final List<Book> cart = [];

  void addToCart(Book book) {
    setState(() {
      var existingBook = cart.firstWhere(
        (b) => b.title == book.title,
        orElse: () => Book(title: "", price: 0, imageUrl: ""),
      );
      if (existingBook.title.isNotEmpty) {
        existingBook.quantity++;
      } else {
        cart.add(Book(title: book.title, price: book.price, imageUrl: book.imageUrl));
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Book Added"),
        content: Text("${book.title} has been added to your cart."),
        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text("OK"),
        //   ),
        // ],
      ),
    );
  }

  void goToCartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cart: cart, updateCart: updateCart),
      ),
    );
  }

  void updateCart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quill & Scroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: goToCartScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(book.imageUrl, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("\₹${book.price}", style: const TextStyle(fontSize: 14, color: Colors.green)),
                        ElevatedButton(
                          onPressed: () => addToCart(book),
                          child: const Text("Add to Cart"),
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
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<Book> cart;
  final VoidCallback updateCart;

  const CartScreen({super.key, required this.cart, required this.updateCart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void removeFromCart(Book book) {
    setState(() {
      book.quantity--;
      if (book.quantity == 0) {
        widget.cart.remove(book);
      }
    });
    widget.updateCart();
  }

  void addToCart(Book book) {
    setState(() {
      book.quantity++;
    });
    widget.updateCart();
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),
      body: widget.cart.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final book = widget.cart[index];
                      return ListTile(
                        leading: Image.network(book.imageUrl, width: 50, height: 50),
                        title: Text(book.title),
                        subtitle: Text("\₹${book.price} x ${book.quantity}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => removeFromCart(book),
                            ),
                            Text('${book.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => addToCart(book),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Total: \₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const BookCartApp());
// }

// class BookCartApp extends StatelessWidget {
//   const BookCartApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Book Cart',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const LoginScreen(),
//     );
//   }
// }

// // User Data (Mock Database)
// class User {
//   final String email;
//   final String password;

//   User({required this.email, required this.password});
// }

// List<User> users = []; // List to store registered users

// // Login Page
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   void login() {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();

//     // Check if the user exists
//     User? user = users.firstWhere(
//       (u) => u.email == email && u.password == password,
//       orElse: () => User(email: '', password: ''),
//     );

//     if (user.email.isNotEmpty) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const BookListScreen()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Login Failed"),
//           content: const Text("Invalid email or password."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: login,
//               child: const Text("Login"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignUpScreen()),
//                 );
//               },
//               child: const Text("Don't have an account? Sign Up"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // SignUp Page
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   void signUp() {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();

//     if (email.isNotEmpty && password.isNotEmpty) {
//       users.add(User(email: email, password: password));

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Sign Up Successful"),
//           content: const Text("You can now log in."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Error"),
//           content: const Text("Please enter all fields."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sign Up")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: signUp,
//               child: const Text("Sign Up"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Book List Screen (Main Screen)
// class Book {
//   final String title;
//   final double price;
//   final String imageUrl;
//   int quantity;

//   Book({required this.title, required this.price, required this.imageUrl, this.quantity = 1});
// }

// class BookListScreen extends StatefulWidget {
//   const BookListScreen({super.key});

//   @override
//   State<BookListScreen> createState() => _BookListScreenState();
// }

// class _BookListScreenState extends State<BookListScreen> {
//   final List<Book> books = [
//     Book(title: "Manifest: 7 Steps to Living Your Best Life", price: 899, imageUrl: "https://m.media-amazon.com/images/I/715u7p+38+L._AC_UF1000,1000_QL80_.jpg"),
//     Book(title: "Steal Like an Artist", price: 499, imageUrl: "https://miro.medium.com/v2/resize:fit:868/0*Z-1JuULerq8byvxY.jpg"),
//     Book(title: "Man's Search for Meaning", price: 299, imageUrl: "https://m.media-amazon.com/images/I/61157LApbuL.jpg"),
//     Book(title: "The Zahir", price: 399, imageUrl: "https://m.media-amazon.com/images/I/71LQZg2f59L._AC_UF1000,1000_QL80_.jpg"),
//     Book(title: "Who Says You Can't You Do", price: 799, imageUrl: "https://m.media-amazon.com/images/I/81nSOIq+crL._AC_UF1000,1000_QL80_.jpg"),
//   ];

//   final List<Book> cart = [];

//   void addToCart(Book book) {
//     setState(() {
//       var existingBook = cart.firstWhere(
//         (b) => b.title == book.title,
//         orElse: () => Book(title: "", price: 0, imageUrl: ""),
//       );
//       if (existingBook.title.isNotEmpty) {
//         existingBook.quantity++;
//       } else {
//         cart.add(Book(title: book.title, price: book.price, imageUrl: book.imageUrl));
//       }
//     });

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Book Added"),
//         content: Text("${book.title} has been added to your cart."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Quill & Scroll")),
//       body: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//         itemCount: books.length,
//         itemBuilder: (context, index) {
//           final book = books[index];
//           return Card(
//             child: Column(
//               children: [
//                 Expanded(child: Image.network(book.imageUrl, fit: BoxFit.cover)),
//                 Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Text("\₹${book.price}", style: const TextStyle(color: Colors.green)),
//                 ElevatedButton(
//                   onPressed: () => addToCart(book),
//                   child: const Text("Add to Cart"),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class CartScreen extends StatefulWidget {
//   final List<Book> cart;
//   final VoidCallback updateCart;

//   const CartScreen({super.key, required this.cart, required this.updateCart});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   void removeFromCart(Book book) {
//     setState(() {
//       book.quantity--;
//       if (book.quantity == 0) {
//         widget.cart.remove(book);
//       }
//     });
//     widget.updateCart();
//   }

//   void addToCart(Book book) {
//     setState(() {
//       book.quantity++;
//     });
//     widget.updateCart();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double total = widget.cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

//     return Scaffold(
//       appBar: AppBar(title: const Text("Shopping Cart")),
//       body: widget.cart.isEmpty
//           ? const Center(child: Text("Your cart is empty!"))
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: widget.cart.length,
//                     itemBuilder: (context, index) {
//                       final book = widget.cart[index];
//                       return ListTile(
//                         leading: Image.network(book.imageUrl, width: 50, height: 50),
//                         title: Text(book.title),
//                         subtitle: Text("\₹${book.price} x ${book.quantity}"),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.remove),
//                               onPressed: () => removeFromCart(book),
//                             ),
//                             Text('${book.quantity}'),
//                             IconButton(
//                               icon: const Icon(Icons.add),
//                               onPressed: () => addToCart(book),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text("Total: \₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//     );
//   }
// }