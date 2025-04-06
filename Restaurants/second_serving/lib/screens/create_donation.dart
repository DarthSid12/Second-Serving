import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart'; // Make sure this imports the AppUser and Address classes

class CreateDonationPage extends StatefulWidget {
  final AppUser appUser; // Receive the AppUser as a parameter

  CreateDonationPage({required this.appUser});

  @override
  _CreateDonationPageState createState() => _CreateDonationPageState();
}

class _CreateDonationPageState extends State<CreateDonationPage> {
  Address? _selectedAddress;
  DateTime? _expirationDate;
  int? _feedCount;
  String _description = '';
  final TextEditingController _feedCountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially set the selected address to the first address in the user's list
    if (widget.appUser.addresses.isNotEmpty) {
      _selectedAddress = widget.appUser.addresses[0];
    }
  }

  // Function to handle selecting the expiration date
  Future<void> _pickExpirationDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _expirationDate) {
      setState(() {
        _expirationDate = pickedDate;
      });
    }
  }

  // Function to handle the donation submission
  void _submitDonation() async {
    if (_selectedAddress == null ||
        _expirationDate == null ||
        _feedCount == null ||
        _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Create a Donation object
    Donation newDonation = Donation(
      driverName: (MyColors.driverNames..shuffle()).first,
      address: _selectedAddress!,
      expirationDate: _expirationDate!,
      feedCount: _feedCount!,
      description: _description,
      uid: widget.appUser.uid,
      name: widget.appUser.name,
    );

    // You can now save this donation to Firestore or handle it accordingly
    // For now, just print it out
    print(
        'Donation Created: ${newDonation.address}, ${newDonation.expirationDate}, ${newDonation.feedCount} people, ${newDonation.description}, Date of Donation: ${newDonation.donationDate}');
    // Add the donation to the Firestore "Donations" collection
    await FirebaseFirestore.instance
        .collection('Donations')
        .add(newDonation.toJson())
        .then((value) {
      print('Donation added to Firestore with ID: ${value.id}');
    }).catchError((error) {
      print('Failed to add donation: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create donation')),
      );
    });

    await FirebaseFirestore.instance
        .collection('givers')
        .doc(widget.appUser.uid)
        .update({
      'donations': FieldValue.increment(1),
      'mealsFed': FieldValue.increment(_feedCount!),
    }).then((value) {
      print('User updated successfully');
    }).catchError((error) {
      print('Failed to update user: $error');
    });
    widget.appUser.donations += 1;
    widget .appUser.mealsFed += _feedCount!;
    // Clear fields after submission
    setState(() {
      _selectedAddress = widget.appUser.addresses.isNotEmpty
          ? widget.appUser.addresses[0]
          : null;
      _expirationDate = null;
      _feedCountController.clear();
      _descriptionController.clear();
    });

    // Optional: Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation created successfully')),
    );
    // await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context,widget.appUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Donation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Dropdown
            Text('Select Address:'),
            DropdownButton<Address>(
              value: _selectedAddress,
              onChanged: (Address? newAddress) {
                setState(() {
                  _selectedAddress = newAddress;
                });
              },
              items: widget.appUser.addresses.map((Address address) {
                return DropdownMenuItem<Address>(
                  value: address,
                  child: Text(
                    '${address.address1}, ${address.city}, ${address.state}',
                  ),
                );
              }).toList(),
              isExpanded: true,
            ),

            // Expiration Date Picker
            Text('Expiration Date:'),
            TextButton(
              onPressed: _pickExpirationDate,
              child: Text(
                _expirationDate == null
                    ? 'Select Expiration Date'
                    : DateFormat.yMMMd().format(_expirationDate!),
              ),
            ),

            // Number of People to Feed
            Text('Number of People to Feed:'),
            TextField(
              controller: _feedCountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Enter number of people',
              ),
              onChanged: (value) {
                setState(() {
                  _feedCount = int.tryParse(value);
                });
              },
            ),

            // Description
            Text('Description of the food:'),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter a description of the food',
              ),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),

            // Submit Button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDonation,
              child: Text('Submit Donation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF32827A), // Your primary button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
