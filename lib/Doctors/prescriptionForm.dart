import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrescriptionForm extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpeclization;
  final String doctorPhone;
  final String doctorHospital;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String appointmentId;
  final String appointmentDate;

  const PrescriptionForm({
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpeclization,
    required this.doctorPhone,
    required this.doctorHospital,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.appointmentId,
    required this.appointmentDate,
    Key? key,
  }) : super(key: key);

  @override
  _PrescriptionFormState createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _medications = [];
  String? _medicationName;
  int? _quantity;
  String? _dosage;
  String? _medicationId;
  bool _isLoading = false;
  bool _isSubmitting = false;  // Track submission state
  bool _isSubmitted = false; // Tracks if the prescription was successfully submitted

  // Define FocusNode for the input fields to change colors on focus
  final FocusNode _medicationFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _dosageFocusNode = FocusNode();

  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();


  // Helper method to format appointment date
  String _formatAppointmentDate(String date) {
    // Add your date formatting logic here
    return date;
  }

  // Helper method to format appointment time
  String _formatAppointmentTime(String date) {
    // Add your time formatting logic here
    return date;
  }


  // Function to fetch medication ID
// Function to fetch medication ID with dialog confirmation if not found
  Future<void> _fetchMedicationId(String medicationName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Make the API request to get medication ID by name
      final response = await http.get(Uri.parse(
          'http://10.0.2.2:5000/api/healup/medication/medication-id/$medicationName'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if medicationId or otcMedicationId is present in the response
        if (data['medicationId'] != null) {
          setState(() {
            _medicationId = data['medicationId']; // Set the fetched ID
            print(data);  // Debugging: Print the fetched data to see if it's correct.

          });
        } else if (data['otcMedicationId'] != null) {
          setState(() {
            _medicationId = data['otcMedicationId']; // Set the OTC ID if present
          });
        } else {
          // Handle case when no medication ID or OTC ID is found
          setState(() {
            _medicationId = null; // Reset the ID to null
          });
        }
      } else {
        // API call failed
        setState(() {
          _medicationId = null; // Reset the ID if the API fails
        });
      }
    } catch (error) {
      // Handle network or other errors
      print("Error fetching medication ID: $error");
      setState(() {
        _medicationId = null; // Reset the ID in case of error
      });
    }

    setState(() {
      _isLoading = false;
    });
  }





  Future<void> _submitForm(String appointmentId, List<Map<String, dynamic>> medications) async {
    if (medications.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      final apiUrl = "http://10.0.2.2:5000/api/healup/prescriptions/add";

      try {
        // Prepare the request body
        final requestBody = {
          "appointment_id": appointmentId,
          "medications": medications, // List of medications with IDs, quantities, and dosages
        };

        // Make the API call
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 201) {
          // Successfully created prescription
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prescription submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true); // Return "true" to the previous page
        } else {
          // Handle errors returned by the backend
          final errorMessage = jsonDecode(response.body)['message'] ?? 'An error occurred';
          throw Exception(errorMessage);
        }
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No medications added. Please add medications before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }






  // Update medication function
  void _updateMedication(int index) {
    // Pre-fill the current values from the selected medication
    _medicationName = _medications[index]['medication_name'];
    _quantity = _medications[index]['quantity'];
    _dosage = _medications[index]['dosage'];
    _medicationId = _medications[index]['medication_id'];

    // Create a new form key for validation within the dialog
    final _updateFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Medication'),
          content: Form(
            key: _updateFormKey, // Form key for dialog validation
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medication Name Field
                TextFormField(
                  initialValue: _medicationName,
                  decoration: InputDecoration(labelText: 'Medication Name'),
                  onChanged: (value) {
                    _medicationName = value;
                    // Call _fetchMedicationId only if medicationName is not null
                    if (_medicationName != null && _medicationName!.isNotEmpty) {
                      _fetchMedicationId(_medicationName!);  // Use `!` to assert it's non-null
                    }
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? "Medication Name is required" : null,
                ),
                // Quantity Field
                TextFormField(
                  initialValue: _quantity?.toString(),
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _quantity = int.tryParse(value),
                  validator: (value) =>
                  value == null || int.tryParse(value) == null ? "Enter a valid quantity" : null,
                ),
                // Dosage Field
                TextFormField(
                  initialValue: _dosage,
                  decoration: InputDecoration(labelText: 'Dosage'),
                  onChanged: (value) => _dosage = value,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Dosage is required" : null,
                ),
              ],
            ),
          ),
          actions: [
            // Update Button
            TextButton(
              onPressed: () async {
                if (_updateFormKey.currentState!.validate()) {
                  // If form is valid, update the medication

                  // Wait for the medication ID to be fetched
                  await _fetchMedicationId(_medicationName!);

                  setState(() {
                    // Update the medication in the list
                    _medications[index]['medication_name'] = _medicationName;
                    _medications[index]['quantity'] = _quantity;
                    _medications[index]['dosage'] = _dosage;
                    // Use the fetched medication ID
                    _medications[index]['medication_id'] = _medicationId;
                  });

                  Navigator.pop(context);
                }
              },
              child: Text(
                'Update',
                style: TextStyle(color: Color(0xff2f9a8f)),
              ),
            ),
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xff2f9a8f)),
              ),
            ),
          ],
        );
      },
    );
  }


// Delete medication function
  void _deleteMedication(int index) {
    setState(() {
      // Remove medication from the list
      _medications.removeAt(index);
    });

    // Optionally, you can make a call to the backend to delete the medication from the database
    final medicationId = _medications[index]['medication_id'];
    _deleteMedicationFromBackend(medicationId);
  }

// Function to delete medication from backend
  Future<void> _deleteMedicationFromBackend(String medicationId) async {
    final response = await http.delete(
      Uri.parse(
          'http://10.0.2.2:5000/api/healup/prescriptions/remove-medication/$medicationId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication deleted successfully!'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete medication. Please try again.'),
            backgroundColor: Colors.red),
      );
    }
  }


  // Add medication

  void _addMedication() async {
    // Validate the form before adding the medication
    if (_formKey.currentState!.validate()) {
      // Fetch the medication ID using the medication name
      await _fetchMedicationId(_medicationController.text);

      // If medicationId is still null after fetching, show the dialog
      if (_medicationId == null || _medicationId!.isEmpty) {
        // Show dialog asking if user wants to continue without ID
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Medication ID not found'),
              content: Text('The medication ID was not found. Please correct it?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without adding the medication
                  },
                  child: Text('OK', style: TextStyle(color: Color(0xff2f9a8f))),
                ),
              ],
            );
          },
        );
      } else {
        // If medication ID is found, add the medication normally
        setState(() {
          _medications.add({
            "medication_name": _medicationController.text,
            "quantity": int.tryParse(_quantityController.text),
            "dosage": _dosageController.text,
            "medication_id": _medicationId, // Use the fetched medicationId
          });

          // Clear the input fields after adding the medication
          _medicationController.clear();
          _quantityController.clear();
          _dosageController.clear();
        });
      }
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prescription Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor's Details (Left Side)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Doctor Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Name: ${widget.doctorName}", style: TextStyle(fontSize: 16)),
                          Text("Specialization: ${widget.doctorSpeclization}", style: TextStyle(fontSize: 16)),
                          Text("Phone: ${widget.doctorPhone}", style: TextStyle(fontSize: 16)),
                          Text("Hospital: ${widget.doctorHospital}", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16), // Space between the columns
                    // Patient Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Name: ${widget.patientName}", style: TextStyle(fontSize: 16)),
                          Text("Age: ${widget.patientAge}", style: TextStyle(fontSize: 16)),
                          Text("Appointment Date: ${widget.appointmentDate}", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Add padding between the doctor and patient details
                const Divider(
                  thickness: 0.7,color: Colors.black,
                ), // Divider between Doctor and Patient Details
                const SizedBox(height: 25), // Padding after the divider

                // Medication Name Field
                TextFormField(
                  controller: _medicationController,
                  focusNode: _medicationFocusNode,
                  decoration: InputDecoration(
                    labelText: "Medication Name",
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xff2f9a8f), width: 2.0),
                    ),
                    labelStyle: TextStyle(
                      color: _medicationFocusNode.hasFocus
                          ? const Color(0xff2f9a8f)
                          : Colors.black,
                    ),
                  ),
                  onChanged: (value) => _medicationName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Medication Name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  focusNode: _quantityFocusNode,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xff2f9a8f), width: 2.0),
                    ),
                    labelStyle: TextStyle(
                      color: _quantityFocusNode.hasFocus
                          ? const Color(0xff2f9a8f)
                          : Colors.black,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _quantity = int.tryParse(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Quantity is required";
                    }
                    if (int.tryParse(value) == null) {
                      return "Enter a valid quantity";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Dosage Field
                TextFormField(
                  controller: _dosageController,
                  focusNode: _dosageFocusNode,
                  decoration: InputDecoration(
                    labelText: "Dosage",
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xff2f9a8f), width: 2.0),
                    ),
                    labelStyle: TextStyle(
                      color: _dosageFocusNode.hasFocus
                          ? const Color(0xff2f9a8f)
                          : Colors.black,
                    ),
                  ),
                  onChanged: (value) => _dosage = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Dosage is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Add Medication Button
                Center(
                  child: ElevatedButton(
                    onPressed: _addMedication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2f9a8f),
                    ),
                    child: const Text(
                      "Add Medication",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Display added medications
                if (_medications.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Added Medications:",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _medications.length,
                        itemBuilder: (context, index) {
                          final medication = _medications[index];
                          return ListTile(
                            title: Text(medication['medication_name']),
                            subtitle: Text(
                              "Quantity: ${medication['quantity']}\nDosage: ${medication['dosage']}\nMedication ID: ${medication['medication_id']}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _updateMedication(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteMedication(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Submit Prescription Button
                Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Submission"),
                            content: const Text(
                                "Are you sure you want to submit the prescription?"),
                            actions: [
                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () {
                                  // Ensure the prescription is submitted with the correct parameters
                                  setState(() {
                                    _isSubmitting = true; // Prevent further clicks
                                  });
                                  Navigator.pop(context); // Close the dialog
                                  _submitForm(widget.appointmentId, _medications); // Pass the required arguments
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: Color(0xff2f9a8f)),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog without submitting
                                },
                                child: const Text(
                                  'No',
                                  style: TextStyle(color: Color(0xff2f9a8f)),
                                ),
                              ),
                            ],
                          );

                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2f9a8f),
                    ),
                    child: _isSubmitting
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Submit Prescription",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
