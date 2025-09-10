import 'package:equatable/equatable.dart';

class Business extends Equatable {
  final String id;
  final String name;
  final String location;
  final String contactNumber;

  const Business({
    required this.id,
    required this.name,
    required this.location,
    required this.contactNumber,
  });

  // Factory constructor to normalize messy JSON keys
  factory Business.fromJson(Map<String, dynamic> json, {int? index}) {
    return Business(
      id: (index?.toString() ?? json['id']?.toString()) ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _validateAndNormalize(json['biz_name'] ?? json['name'] ?? ''),
      location: _validateAndNormalize(json['bss_location'] ?? json['location'] ?? ''),
      contactNumber: _validateAndNormalize(json['contct_no'] ?? json['contact'] ?? ''),
    );
  }

  // Data validation and normalization
  static String _validateAndNormalize(String value) {
    if (value.isEmpty) return 'Not Available';
    return value.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'contactNumber': contactNumber,
    };
  }

  // Validation methods
  bool get isValid => name != 'Not Available' && location != 'Not Available';
  
  bool get hasValidContact => contactNumber != 'Not Available' && 
      contactNumber.isNotEmpty;

  @override
  List<Object?> get props => [id, name, location, contactNumber];

  @override
  String toString() => 'Business(id: $id, name: $name, location: $location)';
}
