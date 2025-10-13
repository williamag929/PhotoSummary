class Project {
  int? id;
  String name;
  String company;
  String address;
  String zipcode;
  double? latitude;
  double? longitude;

  Project({
    this.id,
    required this.name,
    required this.company,
    required this.address,
    required this.zipcode,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'address': address,
      'zipcode': zipcode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      company: map['company'],
      address: map['address'],
      zipcode: map['zipcode'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
