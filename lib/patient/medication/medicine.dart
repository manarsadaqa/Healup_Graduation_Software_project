class Medicine {
  final String id;  // Medication ID
  final String medication_name;
  final String image;
  final String description;
  final double price;
  final String type;
  int quantity; // Add quantity to track the number of units

  Medicine({
    required this.id,
    required this.medication_name,
    required this.image,
    required this.description,
    required this.price,
    required this.type,
    this.quantity = 1,  // Default quantity is 1
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'],  // Assuming the backend returns _id as the medication's unique ID
      medication_name: json['medication_name'] ?? 'Unknown',
      image: json['image'] ?? '',
      description: json['description'] ?? 'No description available',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? 'Unknown',
      quantity: json['quantity'] ?? 1,  // You may receive quantity from the server if it's saved
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,  // Include id in the toJson method
      'medication_name': medication_name,
      'image': image,
      'price': price,
      'quantity': quantity, // Include quantity in the request when sending it to the backend
    };
  }
}

// class Medicine {
//   final String id;  // Add id property
//   final String medication_name;
//   final String image;
//   final String description;
//   final double price;
//   final String type;
//
//   Medicine({
//     required this.id,
//     required this.medication_name,
//     required this.image,
//     required this.description,
//     required this.price,
//     required this.type,
//   });
//
//   factory Medicine.fromJson(Map<String, dynamic> json) {
//     return Medicine(
//       id: json['_id'],  // Assuming the backend returns _id as the medication's unique ID
//
//       medication_name: json['medication_name'] ?? 'Unknown',
//       image: json['image'] ?? '',
//       description: json['description'] ?? 'No description available',
//       price: (json['price'] ?? 0).toDouble(),
//       type: json['type'] ?? 'Unknown',
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,  // Include id in the toJson method
//       'medication_name': medication_name,
//       'image': image,
//       'price': price,
//     };
//   }
// }
