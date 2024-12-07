class Medicine {
  final String medication_name;
  final String image;
  final String description;
  final double price;
  final String type;

  Medicine({
    required this.medication_name,
    required this.image,
    required this.description,
    required this.price,
    required this.type,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medication_name: json['medication_name'] ?? 'Unknown',
      image: json['image'] ?? '',
      description: json['description'] ?? 'No description available',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? 'Unknown',
    );
  }
}
