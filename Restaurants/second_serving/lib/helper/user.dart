import 'dart:math';

class AppUser {
  String name;
  String dob;
  String phone;
  List<Address> addresses;
  String email;
  String uid;
  int donations;
  int mealsFed;

  AppUser({
    required this.name,
    required this.dob,
    required this.phone,
    required this.addresses,
    required this.email,
    required this.uid,
    this.donations = 0,
    this.mealsFed = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['name'],
      dob: json['dob'],
      phone: json['phone'],
      addresses: (json['addresses'] as List)
          .map((address) => Address.fromJson(address))
          .toList(),
      email: json['email'],
      donations: json['donations'] ?? 0,
      mealsFed: json['mealsFed'] ?? 0,
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dob': dob,
      'phone': phone,
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'email': email,
      'donations': donations,
      'mealsFed': mealsFed,
      'uid': uid,
    };
  }
}

class Address {
  String address1;
  String address2;
  String city;
  String state;

  Address({
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
    };
  }
}
class Donation {
  final Address address;
  final DateTime expirationDate;
  final int feedCount;
  final String description;
  final DateTime donationDate;  // New field for the day of donation
  final String uid;
  final String name;
  final String driverName;
  Donation({
    required this.address,
    required this.expirationDate,
    required this.name,
    required this.uid,
    required this.feedCount,
    required this.description,
    required this.driverName,
    DateTime? donationDate,
  }) : donationDate = donationDate ??
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            21 + Random().nextInt(2), // Randomly pick 9pm (21) or 10pm (22)
            Random().nextInt(60),    // Randomly pick minutes within the hour
          );

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      address: Address.fromJson(json['address']),
      expirationDate: DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
      feedCount: json['feedCount'],
      description: json['description'],
      uid: json['uid'],
      name: json['name'],
      driverName: json['driverName'],
      donationDate: json['donationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['donationDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address.toJson(),
      'expirationDate': expirationDate.millisecondsSinceEpoch,
      'feedCount': feedCount,
      'description': description,
      'donationDate': donationDate.millisecondsSinceEpoch,
      'uid': uid,
      'name': name,
      'driverName': driverName,
    };
  }
}