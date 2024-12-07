import 'package:flutter/material.dart';
import 'medicine.dart';  // Use the shared Medicine model
import 'cart.dart';

class MedicineDetailPage extends StatefulWidget {
  final Medicine medicine; // This will use the shared Medicine model
  final List<Map<String, dynamic>> cart; // Reference to the shared cart list

  const MedicineDetailPage({
    super.key,
    required this.medicine,
    required this.cart,
  });

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  int quantity = 1;

  // Method to increment the quantity of the selected medicine
  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

// Method to decrement the quantity of the selected medicine
  void decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  void _addToCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add to Cart"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select Quantity:"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(
                        "$quantity",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff2f9a8f), // Set background color
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white, // Set text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Add padding between the buttons
                      ElevatedButton(
                        onPressed: () {
                          // Add the medicine to the shared cart list
                          widget.cart.add({
                            'name': widget.medicine.medication_name,
                            'quantity': quantity,
                            'price': widget.medicine.price,
                            'image': widget.medicine.image,
                          });

                          // Show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "$quantity x ${widget.medicine.medication_name} added to cart."),
                            ),
                          );

                          // Close the dialog and page
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); // Close the details page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2f9a8f), // Set background color
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white, // Set text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
            ),
            ),
              ],

            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine.medication_name),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pat.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Medicine image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 350,
                        child: Image.asset(
                          widget.medicine.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Medicine name
                    Text(
                      widget.medicine.medication_name,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Medicine description
                    Text(
                      widget.medicine.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Medicine price
                    Text(
                      "₪${widget.medicine.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Add to Cart button
                    ElevatedButton(
                      onPressed: () {
                        _addToCart(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2f9a8f),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}