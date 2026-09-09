class GeocodeResult {
  final double lat;
  final double lon;
  final String formattedAddress;
  final String city;
  final String state;

  const GeocodeResult({
    required this.lat,
    required this.lon,
    required this.formattedAddress,
    required this.city,
    required this.state,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;
    return GeocodeResult(
      lat: (data['lat'] ?? data['latitude'] ?? data['lat_deg'] ?? 28.6139).toDouble(),
      lon: (data['lon'] ?? data['longitude'] ?? data['lng'] ?? data['lon_deg'] ?? 77.2090).toDouble(),
      formattedAddress: (data['formattedAddress'] ?? data['address'] ?? data['display_name'] ?? 'Delhi, India').toString(),
      city: (data['city'] ?? data['town'] ?? 'New Delhi').toString(),
      state: (data['state'] ?? 'Delhi').toString(),
    );
  }
}

class BisCentre {
  final String id;
  final String name;
  final String type; // e.g. "Branch Office", "Laboratory", "Regional Office", "AHC"
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String email;
  final List<String> services;
  final double lat;
  final double lon;
  final double? distanceKm;

  const BisCentre({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    required this.email,
    required this.services,
    required this.lat,
    required this.lon,
    this.distanceKm,
  });

  factory BisCentre.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final rawServices = map['services'];
    final List<String> servicesList = rawServices is List
        ? rawServices.map((e) => e.toString()).toList()
        : <String>[];

    return BisCentre(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? map['centre_name'] ?? 'BIS Centre').toString(),
      type: (map['type'] ?? map['centre_type'] ?? 'Branch Office').toString(),
      address: (map['address'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      state: (map['state'] ?? '').toString(),
      pincode: (map['pincode'] ?? map['zip'] ?? '').toString(),
      phone: (map['phone'] ?? map['contact'] ?? map['telephone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      services: servicesList,
      lat: (map['lat'] ?? map['latitude'] ?? 28.6139).toDouble(),
      lon: (map['lon'] ?? map['longitude'] ?? map['lng'] ?? 77.2090).toDouble(),
      distanceKm: map['distanceKm'] != null ? (map['distanceKm'] as num).toDouble() : null,
    );
  }
}
