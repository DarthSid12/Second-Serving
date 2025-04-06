import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateDonationPage extends StatefulWidget {
  final AppUser appUser;

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
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.appUser.addresses.isNotEmpty) {
      _selectedAddress = widget.appUser.addresses[0];
    }
  }

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _selectedImage = await pickedFile.readAsBytes();
      setState(() {
        
      });
      
      await _sendImageToGemini(pickedFile.mimeType!,_selectedImage!);
    }
  }

  Future<void> _sendImageToGemini(String mimeType,Uint8List bytes) async {
    try {
      final apiKey = "AIzaSyAwkGpt3F1V60PL_yB7RGdvZd7S-qAev-w";
      // if (apiKey == null) {
      //   throw Exception('No GEMINI_API_KEY environment variable found.');
      // }
      print(1);
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 64,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
        ),
      );
      print(2);
      final chat = model.startChat(history: [
       
        Content.data(mimeType, bytes)
      ]);
      print(2.5);
      final response = await chat.sendMessage(Content.text(
          'Given this image, please provide the following details in the specified json format:\n\n'
          'Expiration date: <Estimated expiration date given today\'s date is ${DateTime.now().toString()}>\n'
          'Description: <description of the food>\n'
          'Feeds: <estimated number of people it can feed>'));
      print(3);
      print(response.toString());
      final responseText = response.text;
      print(3.5);
      print(responseText);
      // Parse the response to extract description and feed count
      final description =jsonDecode(responseText!)['Description'];
      final expirationDate =jsonDecode(responseText!)['Expiration date'];
      final feedCount = jsonDecode(responseText)['Feeds'].toString().substring(0,1);
      print(4);
      print(description);
      print(feedCount);
      setState(() {
        _descriptionController.text = description ?? _descriptionController.text;
        _expirationDate = DateTime.parse(expirationDate);
        _feedCountController.text = feedCount?.toString() ?? _feedCountController.text;
      });
        } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to analyze image: $e')),
      );
        }
      }

      String? _extractDescription(String responseText) {
        // Extract description from the response (custom parsing logic)
        final match = RegExp(r'Description: \s*<(.+?)>').firstMatch(responseText);
        return match?.group(1);
      }

      int? _extractFeedCount(String responseText) {
        // Extract feed count from the response (custom parsing logic)
        final match = RegExp(r'Feeds: \s*<(\d+)>').firstMatch(responseText);
        return match != null ? int.tryParse(match.group(1)!) : null;
      }

  void _submitDonation() async {
    _description = _descriptionController.text;
    _feedCount = int.tryParse(_feedCountController.text);
    if (_selectedAddress == null ||
        _expirationDate == null ||
        _feedCount == null ||
        _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    Donation newDonation = Donation(
      driverName: (MyColors.driverNames..shuffle()).first,
      address: _selectedAddress!,
      expirationDate: _expirationDate!,
      feedCount: _feedCount!,
      description: _description,
      uid: widget.appUser.uid,
      name: widget.appUser.name,
    );

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
    });

    widget.appUser.donations += 1;
    widget.appUser.mealsFed += _feedCount!;
    setState(() {
      _selectedAddress = widget.appUser.addresses.isNotEmpty
          ? widget.appUser.addresses[0]
          : null;
      _expirationDate = null;
      _feedCountController.clear();
      _descriptionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation created successfully')),
    );
    Navigator.pop(context, widget.appUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1D1F), // Slate black background
      appBar: AppBar(
        title: Text(
          'Create Donation',
          style: GoogleFonts.nunitoSans(color: Color(0xFFF8F9FA)), // Nearly white text
        ),
        backgroundColor: Color(0xFF2E3239), // Olive gray app bar
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF8F9FA)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Select Address:',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8F9FA), // Nearly white text
              ),
            ),
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
                    style: TextStyle(color: Color(0xFFF8F9FA)), // Nearly white text
                  ),
                );
              }).toList(),
              isExpanded: true,
              dropdownColor: Color(0xFF2E3239), // Olive gray dropdown
            ),
            SizedBox(height: 16),
            Text(
              'Expiration Date:',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8F9FA), // Nearly white text
              ),
            ),
            TextButton(
              onPressed: _pickExpirationDate,
              child: Text(
                _expirationDate == null ? 'Select Expiration Date' : DateFormat.yMMMd().format(_expirationDate!),
                style: TextStyle(fontSize: 16, color: Color(0xFFA3C9A8)), // Sage green
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Number of People to Feed:',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8F9FA), // Nearly white text
              ),
            ),
            TextField(
              controller: _feedCountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter number of people',
                filled: true,
                fillColor: Color(0xFF2E3239), // Olive gray input background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Color(0xFFF8F9FA).withOpacity(0.7)), // Muted white
              ),
              style: TextStyle(color: Color(0xFFF8F9FA)), // Nearly white text
            ),
            SizedBox(height: 16),
            Text(
              'Description of the food:',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8F9FA), // Nearly white text
              ),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter a description of the food',
                filled: true,
                fillColor: Color(0xFF2E3239), // Olive gray input background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Color(0xFFF8F9FA).withOpacity(0.7)), // Muted white
              ),
              style: TextStyle(color: Color(0xFFF8F9FA)), // Nearly white text
            ),
            SizedBox(height: 16),
            if (_selectedImage != null)
              Column(
                children: [
                  Text(
                    'Selected Image:',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8F9FA), // Nearly white text
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.memory(_selectedImage!),
                  SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Take Picture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA3C9A8), // Sage green
                foregroundColor: Color(0xFF1C1D1F), // Slate black text
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDonation,
              child: Text('Submit Donation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA3C9A8), // Sage green
                foregroundColor: Color(0xFF1C1D1F), // Slate black text
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
