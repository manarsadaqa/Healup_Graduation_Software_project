import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'medicationList.dart'; // Make sure you have a page for displaying the medication list

class EditMedicationPage extends StatefulWidget {
  final String medicationId; // The ID of the medication to be edited

  EditMedicationPage({required this.medicationId});

  @override
  _EditMedicationPageState createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _scientificNameController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController(); // Added image field controller

  @override
  void initState() {
    super.initState();
    _fetchMedicationDetails();
  }

  // Fetch medication details to pre-fill the form
  Future<void> _fetchMedicationDetails() async {
    final url = 'http://10.0.2.2:5000/api/healup/medication/${widget.medicationId}'; // Use the correct URL for fetching medication details
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final medication = jsonDecode(response.body);
      _medicationNameController.text = medication['medication_name'];
      _scientificNameController.text = medication['scientific_name'];
      _stockQuantityController.text = medication['stock_quantity'].toString();
      _expirationDateController.text = medication['expiration_date'];
      _descriptionController.text = medication['description'] ?? '';
      _typeController.text = medication['type'];
      _priceController.text = medication['price'].toString();
      _imageController.text = medication['image']; // Set the image URL
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load medication details')),
      );
    }
  }

  // Update Medication function
  Future<void> _updateMedication() async {
    final url = 'http://10.0.2.2:5000/api/healup/medication/update/${widget.medicationId}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'medication_name': _medicationNameController.text,
        'scientific_name': _scientificNameController.text,
        'stock_quantity': int.parse(_stockQuantityController.text),
        'expiration_date': _expirationDateController.text,
        'description': _descriptionController.text,
        'type': _typeController.text,
        'price': double.parse(_priceController.text),
        'image': _imageController.text, // Include the image URL in the update request
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication updated successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MedicationListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medication')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Medication",
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _medicationNameController,
                label: 'Medication Name',
                icon: Icons.medication,
                validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
              ),
              _buildTextField(
                controller: _scientificNameController,
                label: 'Scientific Name',
                icon: Icons.science,
                validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
              ),
              _buildTextField(
                controller: _stockQuantityController,
                label: 'Stock Quantity',
                icon: Icons.storage,
                validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _expirationDateController,
                label: 'Expiration Date',
                icon: Icons.date_range,
                validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                validator: (value) => value!.isEmpty ? 'Please enter description' : null,
              ),
              _buildTextField(
                controller: _typeController,
                label: 'Type',
                icon: Icons.category,
                validator: (value) => value!.isEmpty ? 'Please enter type' : null,
              ),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.monetization_on,
                validator: (value) => value!.isEmpty ? 'Please enter price' : null,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              // _buildTextField(
              //   controller: _imageController,
              //   label: 'Image URL',
              //   icon: Icons.image,
              //   validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
              // ),
              // SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateMedication();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2f9a8f),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Update Medication',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 2),
          ),
        ),
        style: TextStyle(color: Colors.black, fontSize: 18),
        validator: validator,
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
// class EditMedicationPage extends StatefulWidget {
//   final String medicationId; // The ID of the medication to be edited
//
//   EditMedicationPage({required this.medicationId});
//
//   @override
//   _EditMedicationPageState createState() => _EditMedicationPageState();
// }
//
// class _EditMedicationPageState extends State<EditMedicationPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final TextEditingController _medicationNameController = TextEditingController();
//   final TextEditingController _scientificNameController = TextEditingController();
//   final TextEditingController _stockQuantityController = TextEditingController();
//   final TextEditingController _expirationDateController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _imageController = TextEditingController(); // Added image field controller
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMedicationDetails();
//   }
//
//   // Fetch medication details to pre-fill the form
//   Future<void> _fetchMedicationDetails() async {
//     // Assuming you're using your local API, adjust URL accordingly
//     final url = 'http://10.0.2.2:5000/api/healup/medication/update/${widget.medicationId}';
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final medication = jsonDecode(response.body);
//       _medicationNameController.text = medication['medication_name'];
//       _scientificNameController.text = medication['scientific_name'];
//       _stockQuantityController.text = medication['stock_quantity'].toString();
//       _expirationDateController.text = medication['expiration_date'];
//       _descriptionController.text = medication['description'] ?? '';
//       _typeController.text = medication['type'];
//       _priceController.text = medication['price'].toString();
//       _imageController.text = medication['image']; // Set the image URL
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load medication details')),
//       );
//     }
//   }
//
//   // Update Medication function
//   Future<void> _updateMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/update/${widget.medicationId}';
//     final response = await http.put(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'medication_name': _medicationNameController.text,
//         'scientific_name': _scientificNameController.text,
//         'stock_quantity': int.parse(_stockQuantityController.text),
//         'expiration_date': _expirationDateController.text,
//         'description': _descriptionController.text,
//         'type': _typeController.text,
//         'price': double.parse(_priceController.text),
//         'image': _imageController.text, // Include the image URL in the update request
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication updated successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update medication')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Edit Medication",
//           style: TextStyle(fontSize: 24),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/back.jpg'),
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.3),
//               BlendMode.darken,
//             ),
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildTextField(
//                 controller: _medicationNameController,
//                 label: 'Medication Name',
//                 icon: Icons.medication,
//                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
//               ),
//               _buildTextField(
//                 controller: _scientificNameController,
//                 label: 'Scientific Name',
//                 icon: Icons.science,
//                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
//               ),
//               _buildTextField(
//                 controller: _stockQuantityController,
//                 label: 'Stock Quantity',
//                 icon: Icons.storage,
//                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               _buildTextField(
//                 controller: _expirationDateController,
//                 label: 'Expiration Date',
//                 icon: Icons.date_range,
//                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
//               ),
//               _buildTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//                 icon: Icons.description,
//                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
//               ),
//               _buildTextField(
//                 controller: _typeController,
//                 label: 'Type',
//                 icon: Icons.category,
//                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
//               ),
//               _buildTextField(
//                 controller: _priceController,
//                 label: 'Price',
//                 icon: Icons.monetization_on,
//                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//               ),
//               _buildTextField(
//                 controller: _imageController,
//                 label: 'Image URL',
//                 icon: Icons.image,
//                 validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _updateMedication();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Update Medication',
//                   style: TextStyle(color: Colors.black, fontSize: 20),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.black87),
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black87, width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black87, width: 2),
//           ),
//         ),
//         style: TextStyle(color: Colors.black, fontSize: 18),
//         validator: validator,
//       ),
//     );
//   }
// }
