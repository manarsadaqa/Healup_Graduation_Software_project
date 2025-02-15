import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'medicationList.dart';

// صفحة إضافة الدواء
class AddMedicationPage extends StatefulWidget {
  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _scientificNameController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageNameController = TextEditingController();

  // إعداد صورة الدواء
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // اختيار الصورة من المعرض
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageNameController.text = pickedFile.name; // تعيين اسم الصورة
      });
    }
  }

  Future<void> _addMedication() async {
    // التحقق من صحة المدخلات
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL API الخاصة بك
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // إضافة البيانات النصية
    request.fields['medication_name'] = _medicationNameController.text;
    request.fields['scientific_name'] = _scientificNameController.text;
    request.fields['stock_quantity'] = _stockQuantityController.text;
    request.fields['expiration_date'] = _expirationDateController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['type'] = _typeController.text;
    request.fields['price'] = _priceController.text;

    // إضافة الصورة إذا كانت موجودة
    if (_image != null) {
      final bytes = await _image!.readAsBytes();
      String base64Image = base64Encode(bytes);
      print('Base64 image: $base64Image'); // أضف هذا السطر للتحقق من الصورة
      request.fields['pic'] = 'data:image/png;base64,' + base64Image;
    }

    // إرسال الطلب
    var response = await request.send();

    // التحقق من حالة الاستجابة
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إضافة الدواء بنجاح')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MedicationListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة الدواء')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة دواء"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _medicationNameController,
                  decoration: InputDecoration(labelText: 'اسم الدواء'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم الدواء';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _scientificNameController,
                  decoration: InputDecoration(labelText: 'الاسم العلمي'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم العلمي';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _stockQuantityController,
                  decoration: InputDecoration(labelText: 'الكمية في المخزن'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الكمية';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _expirationDateController,
                  decoration: InputDecoration(labelText: 'تاريخ انتهاء الصلاحية'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال تاريخ انتهاء الصلاحية';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'الوصف'),
                ),
                TextFormField(
                  controller: _typeController,
                  decoration: InputDecoration(labelText: 'النوع'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال النوع';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'السعر'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال السعر';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: 150,
                    child: _image == null
                        ? Center(child: Text('اضغط لاختيار الصورة'))
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addMedication,
                  child: Text('إضافة الدواء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'medicationList.dart';
// // Add Medication Page
// class AddMedicationPage extends StatefulWidget {
//   @override
//   _AddMedicationPageState createState() => _AddMedicationPageState();
// }
//
// class _AddMedicationPageState extends State<AddMedicationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _medicationNameController = TextEditingController();
//   final TextEditingController _scientificNameController = TextEditingController();
//   final TextEditingController _stockQuantityController = TextEditingController();
//   final TextEditingController _expirationDateController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _imageNameController = TextEditingController();
//
//   // Image picker setup
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _imageNameController.text = pickedFile.name; // Set the image name in the text field
//       });
//     }
//   }
//
//   // Convert image to base64 string
//   Future<String?> _getImageBase64() async {
//     if (_image == null) return null;
//     final bytes = await _image!.readAsBytes();
//     return base64Encode(bytes);
//   }
//
//   Future<void> _addMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL API الخاصة بك
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//
//     // Add text fields
//     request.fields['medication_name'] = _medicationNameController.text;
//     request.fields['scientific_name'] = _scientificNameController.text;
//     request.fields['stock_quantity'] = _stockQuantityController.text;
//     request.fields['expiration_date'] = _expirationDateController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['type'] = _typeController.text;
//     request.fields['price'] = _priceController.text;
//
//     // Add image if available and convert to base64
//     if (_image != null) {
//       // Read image as bytes
//       final bytes = await _image!.readAsBytes();
//       String base64Image = base64Encode(bytes);
//       request.fields['pic'] = 'data:image/png;base64,' + base64Image;
//     }
//
//     // Send the request
//     var response = await request.send();
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication added successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add medication')),
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Medication"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _medicationNameController,
//                 decoration: InputDecoration(labelText: 'Medication Name'),
//               ),
//               TextField(
//                 controller: _scientificNameController,
//                 decoration: InputDecoration(labelText: 'Scientific Name'),
//               ),
//               TextField(
//                 controller: _stockQuantityController,
//                 decoration: InputDecoration(labelText: 'Stock Quantity'),
//                 keyboardType: TextInputType.number,
//               ),
//               TextField(
//                 controller: _expirationDateController,
//                 decoration: InputDecoration(labelText: 'Expiration Date'),
//               ),
//               TextField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//               ),
//               TextField(
//                 controller: _typeController,
//                 decoration: InputDecoration(labelText: 'Type'),
//               ),
//               TextField(
//                 controller: _priceController,
//                 decoration: InputDecoration(labelText: 'Price'),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 16),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   color: Colors.grey[200],
//                   width: double.infinity,
//                   height: 150,
//                   child: _image == null
//                       ? Center(child: Text('Tap to select image'))
//                       : Image.file(_image!, fit: BoxFit.cover),
//                 ),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _addMedication,
//                 child: Text('Add Medication'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'medicationList.dart'; // تأكد من أنك تمتلك صفحة لعرض قائمة الأدوية
//
// class AddMedicationPage extends StatefulWidget {
//   @override
//   _AddMedicationPageState createState() => _AddMedicationPageState();
// }
//
// class _AddMedicationPageState extends State<AddMedicationPage> {
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
//   final TextEditingController _imageNameController = TextEditingController();
//
//   // Image picker setup
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _imageNameController.text = pickedFile.name; // Set the image name in the text field
//       });
//     }
//   }
//
//   // Add Medication function
//   Future<void> _addMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL API الخاصة بك
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//
//     // Add text fields
//     request.fields['medication_name'] = _medicationNameController.text;
//     request.fields['scientific_name'] = _scientificNameController.text;
//     request.fields['stock_quantity'] = _stockQuantityController.text;
//     request.fields['expiration_date'] = _expirationDateController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['type'] = _typeController.text;
//     request.fields['price'] = _priceController.text;
//
//     // Add image if available
//     if (_image != null) {
//       var pic = await http.MultipartFile.fromPath('pic', _image!.path);
//       request.files.add(pic);
//     }
//
//     // Send the request
//     var response = await request.send();
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication added successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add medication')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Add New Medication",
//           style: TextStyle(
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/pat.jpg'),
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
//               // Circle Avatar for image upload
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: CircleAvatar(
//                   radius: 80,
//                   backgroundColor: Colors.blueAccent,
//                   backgroundImage: _image != null ? FileImage(_image!) : null,
//                   child: _image == null
//                       ? Icon(
//                     Icons.camera_alt,
//                     size: 50,
//                     color: Colors.white,
//                   )
//                       : null,
//                 ),
//               ),
//               SizedBox(height: 20),
//
//               // Field for Medication Name
//               _buildTextField(
//                 controller: _medicationNameController,
//                 label: 'Medication Name',
//                 icon: Icons.medication,
//                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
//               ),
//               // Field for Scientific Name
//               _buildTextField(
//                 controller: _scientificNameController,
//                 label: 'Scientific Name',
//                 icon: Icons.science,
//                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
//               ),
//               // Field for Stock Quantity
//               _buildTextField(
//                 controller: _stockQuantityController,
//                 label: 'Stock Quantity',
//                 icon: Icons.storage,
//                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               // Field for Expiration Date
//               _buildTextField(
//                 controller: _expirationDateController,
//                 label: 'Expiration Date',
//                 icon: Icons.date_range,
//                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
//               ),
//               // Field for Description
//               _buildTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//                 icon: Icons.description,
//                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
//               ),
//               // Field for Type
//               _buildTextField(
//                 controller: _typeController,
//                 label: 'Type',
//                 icon: Icons.category,
//                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
//               ),
//               // Field for Price
//               _buildTextField(
//                 controller: _priceController,
//                 label: 'Price',
//                 icon: Icons.monetization_on,
//                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//               ),
//               SizedBox(height: 20),
//
//               // Add Medication Button
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _addMedication();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Add Medication',
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
//   // Helper method to build text fields
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     bool enabled = true, // Added to enable/disable the text field
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         enabled: enabled, // Control the text field's enabled state
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





// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
//
// class AddMedicationPage extends StatefulWidget {
//   @override
//   _AddMedicationPageState createState() => _AddMedicationPageState();
// }
//
// class _AddMedicationPageState extends State<AddMedicationPage> {
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
//   final TextEditingController _imageNameController = TextEditingController(); // New TextEditingController for the image name
//
//   // Image picker setup
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _imageNameController.text = pickedFile.name; // Set the image name in the text field
//       });
//     }
//   }
//
//   // Add Medication function
//   Future<void> _addMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL الـ API
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//
//     // Add text fields
//     request.fields['medication_name'] = _medicationNameController.text;
//     request.fields['scientific_name'] = _scientificNameController.text;
//     request.fields['stock_quantity'] = _stockQuantityController.text;
//     request.fields['expiration_date'] = _expirationDateController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['type'] = _typeController.text;
//     request.fields['price'] = _priceController.text;
//     request.fields['image_name'] = _imageNameController.text; // Send the image name
//
//     // Add image if available
//     if (_image != null) {
//       var pic = await http.MultipartFile.fromPath('image', _image!.path);
//       request.files.add(pic);
//     }
//
//     // Send the request
//     var response = await request.send();
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication added successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add medication')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Add New Medication",
//           style: TextStyle(
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/pat.jpg'),
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
//
//               // New TextField for image name
//               _buildTextField(
//                 controller: _imageNameController,
//                 label: 'Image Name',
//                 icon: Icons.image,
//                 validator: (value) => value!.isEmpty ? 'Please upload an image first' : null,
//                 enabled: false, // Disable the text field to prevent editing
//               ),
//
//               SizedBox(height: 20),
//
//               // Upload image button
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Upload Image',
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//
//               // Add Medication button
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _addMedication();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Add Medication',
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
//     bool enabled = true, // Added to enable/disable the text field
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         enabled: enabled, // Control the text field's enabled state
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
// //
// class AddMedicationPage extends StatefulWidget {
//   @override
//   _AddMedicationPageState createState() => _AddMedicationPageState();
// }
//
// class _AddMedicationPageState extends State<AddMedicationPage> {
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
//
//   // Image picker setup
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//   Future<void> _addMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL الـ API
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//
//     // إضافة الحقول النصية
//     request.fields['medication_name'] = _medicationNameController.text;
//     request.fields['scientific_name'] = _scientificNameController.text;
//     request.fields['stock_quantity'] = _stockQuantityController.text;
//     request.fields['expiration_date'] = _expirationDateController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['type'] = _typeController.text;
//     request.fields['price'] = _priceController.text;
//
//     // إضافة الصورة إذا كانت موجودة
//     if (_image != null) {
//       var pic = await http.MultipartFile.fromPath('image', _image!.path);
//       request.files.add(pic);
//     }
//
//     // إرسال الطلب
//     var response = await request.send();
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication added successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add medication')),
//       );
//     }
//   }
//
//   // Add Medication function
//   // Future<void> _addMedication() async {
//   //   final url = 'http://10.0.2.2:5000/api/healup/medication/add';
//   //   var request = http.MultipartRequest('POST', Uri.parse(url));
//   //
//   //   // Add text fields
//   //   request.fields['medication_name'] = _medicationNameController.text;
//   //   request.fields['scientific_name'] = _scientificNameController.text;
//   //   request.fields['stock_quantity'] = _stockQuantityController.text;
//   //   request.fields['expiration_date'] = _expirationDateController.text;
//   //   request.fields['description'] = _descriptionController.text;
//   //   request.fields['type'] = _typeController.text;
//   //   request.fields['price'] = _priceController.text;
//   //
//   //   // Add image if available
//   //   if (_image != null) {
//   //     var pic = await http.MultipartFile.fromPath('image', _image!.path);
//   //     request.files.add(pic);
//   //   }
//   //
//   //   var response = await request.send();
//   //
//   //   if (response.statusCode == 201) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Medication added successfully')),
//   //     );
//   //     Navigator.pushReplacement(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => MedicationListPage()),
//   //     );
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Failed to add medication')),
//   //     );
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     print("========================================");
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Add New Medication",
//           style: TextStyle(
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/pat.jpg'),
//
//             //image: AssetImage('images/back.jpg'),
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
//               SizedBox(height: 20),
//
//               // Upload image button
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Upload Image',
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//
//               // Add Medication button
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _addMedication();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Add Medication',
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
