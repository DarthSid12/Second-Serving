import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart';

class DonationsScreen extends StatefulWidget {
  final AppUser user;

  const DonationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late Future<List<Donation>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _donationsFuture = fetchDonations();
  }

  Future<List<Donation>> fetchDonations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Donations')
        .where('uid', isEqualTo: widget.user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      print(data);
      return Donation.fromJson(data);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      
      body: FutureBuilder<List<Donation>>(
        future: _donationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          print(snapshot.data);
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No donations found.'));
          }

          final allDonations = snapshot.data!;
          final active = allDonations.where((d) =>
              d.donationDate.year == today.year &&
              d.donationDate.month == today.month &&
              d.donationDate.day == today.day).toList();

          final past = allDonations.where((d) =>
              !(d.donationDate.year == today.year &&
                d.donationDate.month == today.month &&
                d.donationDate.day == today.day)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                const Text("Active Donations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...active.map((d) => DonationCard(donation: d, isActive: true)),
              ],
              const SizedBox(height: 30),
              const Text("Past Donations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...past.map((d) => DonationCard(donation: d, isActive: false)),
            ],
          );
        },
      ),
    );
  }
}

class DonationCard extends StatelessWidget {
  final Donation donation;
  final bool isActive;

  const DonationCard({Key? key, required this.donation, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMd().add_jm();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isActive ? MyColors.primary: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Food: ${donation.description}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Feeds: ${donation.feedCount} people"),
            Text("Expires: ${formatter.format(donation.expirationDate)}"),
            if (isActive) Text("Driver: ${donation.driverName}"),
            Text("Pickup Time: ${formatter.format(donation.donationDate)}"),
            Text("Address: ${donation.address.address1}, ${donation.address.city}, ${donation.address.state}"),
          ],
        ),
      ),
    );
  }
}