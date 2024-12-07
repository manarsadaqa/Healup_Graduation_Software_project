import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart; // Cart list

  CartPage({required this.cart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Method to calculate the total price of the cart
  double getTotalPrice() {
    double total = 0.0;
    for (var item in widget.cart) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  // Method to increment the quantity of an item
  void incrementQuantity(int index) {
    setState(() {
      widget.cart[index]['quantity']++;
    });
  }

  // Method to decrement the quantity of an item
  void decrementQuantity(int index) {
    setState(() {
      if (widget.cart[index]['quantity'] > 1) {
        widget.cart[index]['quantity']--;
      } else {
        widget.cart.removeAt(index); // Remove item if quantity reaches 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        backgroundColor: Color(0xff2f9a8f),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back.jpg'), // Add your image path here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Cart content
          widget.cart.isEmpty
              ? Center(
            child: Text(
              "Your cart is empty.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.cart.length,
                  itemBuilder: (context, index) {
                    final item = widget.cart[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: item['image'].isNotEmpty
                            ? Image.network(
                          item['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'images/default_medicine.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "₪${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    decrementQuantity(index);
                                  },
                                ),
                                Text(
                                  "${item['quantity']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    incrementQuantity(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.cart.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${item['name']} removed"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total: ₪${getTotalPrice().toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Logic for checking out or proceeding further
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Checkout successful!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text("Proceed to Checkout"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
