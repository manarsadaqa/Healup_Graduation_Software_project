import 'package:flutter/material.dart';
import 'searchTab.dart';

// The MedicineDetailPage widget to display detailed information about a medicine
class MedicineDetailPage extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailPage({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        backgroundColor: const Color(0xff6be4d7), // Your app's color theme
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pat.jpg'), // Your background image
                fit: BoxFit.cover, // Cover the entire screen
              ),
            ),
          ),
          Center(
            // Center the content vertically and horizontally
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // Add scroll capability for smaller screens
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center items vertically
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Large image of the medicine with border radius
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          12), // Set the border radius here
                      child: Image.asset(
                        medicine.image,
                        height: 350,
                        width:
                            double.infinity, // Makes the image stretch to fit
                        fit: BoxFit
                            .cover, // Cover the area while maintaining aspect ratio
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Medicine name
                    Text(
                      medicine.name,
                      style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.black), // Adjust color for contrast
                      textAlign: TextAlign.left, // Center the text
                    ),
                    const SizedBox(height: 10),

                    // Medicine description
                    Text(
                      medicine.description,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight:
                              FontWeight.bold), // Adjust color for contrast
                      textAlign: TextAlign.left, // Center the text
                    ),
                    const SizedBox(height: 10),

                    // Medicine price
                    Text(
                      "₪${medicine.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.left, // Center the text
                    ),
                    const SizedBox(height: 20),

                    // Add to Cart button
                    ElevatedButton(
                      onPressed: () {
                        // Handle adding to cart
                        print('${medicine.name} added to the cart');
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
                            fontWeight: FontWeight.bold),
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
