import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ehr_detail_screen.dart'; // Screen for detailed EHR view

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedFilter = 'patient_name'; // Default filter
  bool _isLoading = false; // To show loading indicator
  String _errorMessage = ''; // To show error message

  // List of search filters
  final List<String> _filters = [
    'patient_name',
    'doctor_name',
    'appointment_date',
  ];

  // Function to handle search
  void _searchEHR() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a search term';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous error messages
    });

    ApiService apiService = ApiService();
    Map<String, String> searchCriteria = {
      _selectedFilter: _searchController.text,
    };

    try {
      List<Map<String, dynamic>> results = await apiService.searchEHR(searchCriteria);

      // Check if no results are found
      if (results.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No records found matching your search criteria';
        });
      } else {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No records found matching your search criteriasd';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search EHR Records'),
        backgroundColor: Color(0xff6be4d7),
        elevation: 6,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.jpg'), // Your image path here
            fit: BoxFit.cover, // This ensures the image covers the entire screen
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2), // Adjust opacity here (0.0 to 1.0)
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter dropdown
              Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Color(0xff2f9a8f), // Set background color to the desired color
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                    });
                  },
                  isExpanded: true,
                  items: _filters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Color(0xff2f9a8f),
                  iconEnabledColor: Colors.white,
                  style: TextStyle(color: Color(0xff2f9a8f)),
                  borderRadius: BorderRadius.circular(30),
                  underline: SizedBox.shrink(),
                ),
              ),

              // Search input field
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Enter search term',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: Icon(Icons.search, color: Color(0xff2f9a8f)),
                    // Customize focused border color here
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff2f9a8f), // This is the color for the focused border
                        width: 2.0, // Optionally adjust the border width
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // Customize the border color when the TextField is not focused
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // Default color when not focused
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),

              ),

              // Search Button
              _isLoading
                  ? Center(
                child: CircularProgressIndicator(color: Color(0xff2f9a8f)),
              )
                  : SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: _searchEHR,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xff2f9a8f),
                    shadowColor: Color(0xff2f9a8f).withOpacity(0.6),
                    elevation: 6,
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),

              // Error message display if there is an error or no results
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Search results
              if (_searchResults.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var ehr = _searchResults[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EHRDetailScreen(ehr: ehr),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 6,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xff2f9a8f),
                              child: Text(
                                ehr['patient_name'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              ehr['patient_name'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              '${ehr['doctor_name']} - ${ehr['appointment_date']}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api/healup/ehr/search';

  Future<List<Map<String, dynamic>>> searchEHR(Map<String, String> searchCriteria) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(searchCriteria),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['ehrRecords'];
        return jsonResponse.map((ehr) => Map<String, dynamic>.from(ehr)).toList();
      } else {
        throw Exception('Failed to load EHR records');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
