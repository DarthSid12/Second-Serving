import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final Function(AppUser) changeUser;

  ProfileScreen({required this.user,required this.changeUser});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // List of addresses from the user
  late List<Address> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = widget.user.addresses;
  }

  // Function to handle adding a new address (for now just a dummy dialog)
  void _addNewAddress() async {
    String address1 = '';
    String address2 = '';
    String city = '';
    String? state = 'California';

    // Show a dialog to input the address details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Address Line 1'),
                onChanged: (value) {
                  address1 = value;
                },
              ),
              SizedBox(height: 10,),
              TextField(
                decoration: InputDecoration(labelText: 'Address Line 2'),
                onChanged: (value) {
                  address2 = value;
                },
              ),
              SizedBox(height: 10,),

              TextField(
                decoration: InputDecoration(labelText: 'City'),
                onChanged: (value) {
                  city = value;
                },
              ),
              SizedBox(height: 10,),

              Container(
                    padding: EdgeInsets.all(10), // Adjust padding if needed
                    decoration: BoxDecoration(
                      // color: Colors.grey.withOpacity(0.2), // Light grey background color (adjust if needed)
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                      // border: Border.all(
                      //     color: Colors.grey, width: 1), // Optional border
                    ),
                    child: DropdownButton<String>(
                      value: state,
                      hint: Text("Choose a state"),
                      isExpanded:
                          true, // Ensures the dropdown stretches across the screen
                      iconSize: 30,
                      onChanged: (newState) {
                        setState(() {
                          state = newState;
                        });
                      },
                      items:
                          MyColors.states.map<DropdownMenuItem<String>>((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                    ),
                  ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                if (address1.isNotEmpty &&
                    city.isNotEmpty) {
                  // Add the new address to the list
                  print("Doing new address");
                   await FirebaseFirestore.instance
                      .collection('givers')
                      .doc(widget.user.uid)
                      .update({'addresses': FieldValue.arrayUnion([
                        {
                          'address1': address1,
                          'address2': address2,
                          'city': city,
                          'state': state,
                        }
                      ])});
                  setState(() {
                    _addresses.add(Address(
                      address1: address1,
                      address2: address2,
                      city: city,
                      state: state!,
                    ));
                    // Optionally update the user's address list in your AppUser
                    widget.user.addresses = _addresses;
                    // Update the user in Firebase
                   
                    widget.changeUser(widget.user);
                  });
                  Navigator.pop(context); // Close the dialog
                } else {
                  // Show a warning if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: Text('Add Address'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // User Information Section
            Row(
            children: [
              Text(
              'Name: ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              widget.user.name.isNotEmpty
                ? Text(widget.user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                : Text('Not provided', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              SizedBox(width: 8),
              InkWell(
              onTap: () {
                String newName = widget.user.name;
                showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                  title: Text('Edit Name'),
                  content: TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                    newName = value;
                    },
                    controller: TextEditingController(text: widget.user.name),
                  ),
                  actions: [
                    TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                    ),
                    TextButton(
                    onPressed: () async {
                      if (newName.isNotEmpty) {
                      // Update the name in Firebase
                      await FirebaseFirestore.instance
                        .collection('givers')
                        .doc(widget.user.uid)
                        .update({'name': newName});
                      setState(() {
                        widget.user.name = newName;
                        widget.changeUser(widget.user);
                      });
                      Navigator.pop(context); // Close the dialog
                      } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name cannot be empty')),
                      );
                      }
                    },
                    child: Text('Save'),
                    ),
                  ],
                  );
                },
                );
              },
              child: Icon(Icons.edit, size: 16),
              ),
            ],
            ),
          SizedBox(height: 8),
          Text('Email: ${widget.user.email}', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
            Row(
            children: [
              Text('Phone: ', style: TextStyle(fontSize: 16)),
              widget.user.phone.isNotEmpty
                ? Text(widget.user.phone, style: TextStyle(fontSize: 16))
                : Text('Not provided', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              SizedBox(width: 8),
              InkWell(
              onTap: () {
                String newPhone = widget.user.phone;
                showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                  title: Text('Edit Phone Number'),
                  content: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    onChanged: (value) {
                    newPhone = value;
                    },
                    controller: TextEditingController(text: widget.user.phone),
                  ),
                  actions: [
                    TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                    ),
                    TextButton(
                    onPressed: () async {
                      if (newPhone.isNotEmpty) {
                      // Update the phone number in Firebase
                      await FirebaseFirestore.instance
                        .collection('givers')
                        .doc(widget.user.uid)
                        .update({'phone': newPhone});
                      setState(() {
                        widget.user.phone = newPhone;
                        widget.changeUser(widget.user);
                      });
                      Navigator.pop(context); // Close the dialog
                      } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone number cannot be empty')),
                      );
                      }
                    },
                    child: Text('Save'),
                    ),
                  ],
                  );
                },
                );
              },
              child: Icon(Icons.edit, size: 16),
              ),
            ],
            ),
          SizedBox(height: 8),
          Text('Donations: ${widget.user.donations}', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('Meals Fed: ${widget.user.mealsFed}', style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),

          // Addresses Section
          Row(
            children: [
              Text(
                'Addresses: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              InkWell(onTap: (){
                _addNewAddress();
              },child: Icon(Icons.add,size: 20,)),
            ],
          ),
          SizedBox(height: 8),
          _addresses.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Address Line 1: ${address.address1}',
                                style: TextStyle(fontSize: 16)),
                            Text('Address Line 2: ${address.address2}',
                                style: TextStyle(fontSize: 16)),
                            Text('City: ${address.city}', style: TextStyle(fontSize: 16)),
                            Text('State: ${address.state}', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Text('No addresses available.'),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}