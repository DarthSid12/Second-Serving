import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final Function(AppUser) changeUser;

  ProfileScreen({required this.user, required this.changeUser});

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

  void _addNewAddress() {
    showDialog(
      context: context,
      builder: (context) {
        return AddNewAddressDialog(
          onAddAddress: (newAddress) async {
            await FirebaseFirestore.instance
                .collection('givers')
                .doc(widget.user.uid)
                .update({
              'addresses': FieldValue.arrayUnion([
                {
                  'address1': newAddress.address1,
                  'address2': newAddress.address2,
                  'city': newAddress.city,
                  'state': newAddress.state,
                }
              ])
            });
            setState(() {
              _addresses.add(newAddress);
              widget.user.addresses = _addresses;
              widget.changeUser(widget.user);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1D1F), // Slate black background
      // appBar: AppBar(
      //   title: Text(
      //     'Profile',
      //     style: GoogleFonts.nunitoSans(color: Color(0xFFF8F9FA)), // Nearly white text
      //   ),
      //   backgroundColor: Color(0xFF2E3239), // Olive gray app bar
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: Color(0xFFF8F9FA)),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // User Information Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Color(
                      0xFFA3C9A8), // Sage green for active, olive gray for past
                  width: 2,
                ),
              ),
              color: Color(0xFF2E3239), // Olive gray card background
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name
                            : 'Name not provided',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8F9FA), // Nearly white text
                        ),
                      ),
                      subtitle: Text(
                        widget.user.email,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          color:
                              Color(0xFFF8F9FA).withOpacity(0.7), // Muted white
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit,
                            color: Color(0xFFA3C9A8)), // Sage green
                        onPressed: () {
                          String newName = widget.user.name;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Name'),
                                content: TextField(
                                  decoration:
                                      InputDecoration(labelText: 'Name'),
                                  onChanged: (value) {
                                    newName = value;
                                  },
                                  controller: TextEditingController(
                                      text: widget.user.name),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (newName.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('givers')
                                            .doc(widget.user.uid)
                                            .update({'name': newName});
                                        setState(() {
                                          widget.user.name = newName;
                                          widget.changeUser(widget.user);
                                        });
                                        Navigator.pop(
                                            context); // Close the dialog
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Name cannot be empty')),
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
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFA3C9A8), // Sage green
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Color(0xFF1C1D1F), // Slate black text
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Divider(color: Color(0xFFA3C9A8)), // Muted divider
                    ListTile(
                      leading: Icon(Icons.phone,
                          color: Color(0xFFA3C9A8)), // Sage green
                      title: Text(
                        widget.user.phone.isNotEmpty
                            ? '(${widget.user.phone.substring(0, 3)}) ${widget.user.phone.substring(3, 6)} ${widget.user.phone.substring(6)}'
                            : 'Phone not provided',
                        style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            color: Color(0xFFF8F9FA)), // Nearly white text
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit,
                            color: Color(0xFFA3C9A8)), // Sage green
                        onPressed: () {
                          String newPhone = widget.user.phone;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Phone Number'),
                                content: TextField(
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      labelText: 'Phone Number'),
                                  onChanged: (value) {
                                    newPhone = value;
                                  },
                                  controller: TextEditingController(
                                      text: widget.user.phone),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (newPhone.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('givers')
                                            .doc(widget.user.uid)
                                            .update({'phone': newPhone});
                                        setState(() {
                                          widget.user.phone = newPhone;
                                          widget.changeUser(widget.user);
                                        });
                                        Navigator.pop(
                                            context); // Close the dialog
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Phone number cannot be empty')),
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
                      ),
                    ),
                    Divider(color: Color(0xFFA3C9A8)), // Muted divider
                    ListTile(
                      leading: Icon(Icons.favorite,
                          color: Color(0xFFA3C9A8)), // Sage green
                      title: Text(
                        'Donations: ${widget.user.donations}',
                        style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            color: Color(0xFFF8F9FA)), // Nearly white text
                      ),
                    ),
                    Divider(color: Color(0xFFA3C9A8)), // Muted divider
                    ListTile(
                      leading: Icon(Icons.fastfood,
                          color: Color(0xFFA3C9A8)), // Sage green
                      title: Text(
                        'Meals Fed: ${widget.user.mealsFed}',
                        style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            color: Color(0xFFF8F9FA)), // Nearly white text
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            SizedBox(height: 20),
            Text(
              'YOUR IMPACT:',
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8F9FA),
              ),
            ),
            SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 3,
              child: BarChart(
                BarChartData(
                  backgroundColor: Color(0xFF2E3239),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: widget.user.donations.toDouble(),
                          width: 16,
                          color: Color(0xFFA3C9A8))
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: widget.user.mealsFed.toDouble(),
                          width: 16,
                          color: Color(0xFFF8F9FA))
                    ], showingTooltipIndicators: [
                      0
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 0:
                              return Text('Donations',
                                  style: TextStyle(color: Colors.white));
                            case 1:
                              return Text('Meals Fed',
                                  style: TextStyle(color: Colors.white));
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                if (widget.user.donations >= 10)
                  badges.Badge(
                    badgeContent:
                        Icon(Icons.emoji_events, color: Colors.white, size: 16),
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.square,
                      badgeColor: Color(0xFFDAA520),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: Text(
                      'Top Donor',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (widget.user.mealsFed >= 100)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: badges.Badge(
                      badgeContent:
                          Icon(Icons.star, color: Colors.white, size: 16),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.square,
                        badgeColor: Color(0xFF28A745),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: Text(
                        '100+ Meals Club',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                if (widget.user.donations >= 3) // Bronze donor for 3+ donations

                  Text(
                    'Bronze Donor ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                if (widget.user.donations >= 3) // Bronze donor for 3+ donations
                  badges.Badge(
                    badgeContent:
                        Icon(Icons.emoji_events, color: Colors.white, size: 16),
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.square,
                      badgeColor: Color(0xFFCD7F32), // Bronze color
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                if (widget.user.donations >= 50)
                  Text(
                    'Silver Donor ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                if (widget.user.donations >= 50)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: badges.Badge(
                      badgeContent: Icon(Icons.emoji_events,
                          color: Colors.white, size: 16),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.square,
                        badgeColor: Color(0xFFC0C0C0), // Silver color
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                if (widget.user.donations >= 100)
                  Text(
                    'Gold Donor ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                if (widget.user.donations >= 100)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: badges.Badge(
                      badgeContent: Icon(Icons.emoji_events,
                          color: Colors.white, size: 16),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.square,
                        badgeColor: Color(0xFFFFD700), // Gold color
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                if (widget.user.mealsFed >= 30) // Badge for 30+ meals fed
                  Text(
                    '30+ Meals Club ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                if (widget.user.mealsFed >= 30) // Badge for 30+ meals fed
                  badges.Badge(
                    badgeContent:
                        Icon(Icons.star, color: Colors.white, size: 16),
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.square,
                      badgeColor: Color(0xFF28A745), // Green color
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                if (widget.user.mealsFed >= 500)
                  Text(
                    '500+ Meals Club ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                if (widget.user.mealsFed >= 500)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: badges.Badge(
                      badgeContent:
                          Icon(Icons.star, color: Colors.white, size: 16),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.square,
                        badgeColor: Color(0xFF1E90FF), // Blue color
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                if (widget.user.mealsFed >= 1000)
                  Text(
                    '1000+ Meals Club ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                if (widget.user.mealsFed >= 1000)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: badges.Badge(
                      badgeContent:
                          Icon(Icons.star, color: Colors.white, size: 16),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.square,
                        badgeColor: Color(0xFF8B0000), // Dark red color
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            // Addresses Section
            Card(
              elevation: 4,
              color: Color(0xFF2E3239), // Olive gray card background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Color(
                      0xFFA3C9A8), // Sage green for active, olive gray for past
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ADDRESSES:',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8F9FA), // Nearly white text
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.add,
                              color: Color(0xFFA3C9A8)), // Sage green
                          onPressed: _addNewAddress,
                        ),
                      ],
                    ),
                    // Divider(
                    //     color: Color(0xFFA3C9A8)
                    //       ), // Muted divider
                    _addresses.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _addresses.length,
                            itemBuilder: (context, index) {
                              final address = _addresses[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${(index + 1).toString()}. ${address.address1}',
                                      style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          color: Color(
                                              0xFFF8F9FA)), // Nearly white text
                                    ),
                                    if (address.address2.isNotEmpty)
                                      Text(
                                        '    ${address.address2}',
                                        style: GoogleFonts.nunitoSans(
                                            fontSize: 16,
                                            color: Color(
                                                0xFFF8F9FA)), // Nearly white text
                                      ),
                                    Text(
                                      '    ${address.city}',
                                      style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          color: Color(
                                              0xFFF8F9FA)), // Nearly white text
                                    ),
                                    Text(
                                      '    ${address.state}',
                                      style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          color: Color(
                                              0xFFF8F9FA)), // Nearly white text
                                    ),
                                    if (index != _addresses.length - 1)
                                      Divider(
                                          color: Color(
                                              0xFFA3C9A8)), // Muted divider
                                  ],
                                ),
                              );
                            },
                          )
                        : Text(
                            'No addresses available.',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFF8F9FA)
                                  .withOpacity(0.7), // Muted white
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNewAddressDialog extends StatefulWidget {
  final Function(Address) onAddAddress;

  AddNewAddressDialog({required this.onAddAddress});

  @override
  _AddNewAddressDialogState createState() => _AddNewAddressDialogState();
}

class _AddNewAddressDialogState extends State<AddNewAddressDialog> {
  String address1 = '';
  String address2 = '';
  String city = '';
  String? state = 'California';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Address'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Address Line 1'),
              onChanged: (value) {
                setState(() {
                  address1 = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Address Line 2'),
              onChanged: (value) {
                setState(() {
                  address2 = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'City'),
              onChanged: (value) {
                setState(() {
                  city = value;
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: state,
              hint: Text("Choose a state"),
              isExpanded: true,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (address1.isNotEmpty && city.isNotEmpty) {
              widget.onAddAddress(Address(
                address1: address1,
                address2: address2,
                city: city,
                state: state!,
              ));
              Navigator.pop(context); // Close the dialog
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in all fields')),
              );
            }
          },
          child: Text('Add Address'),
        ),
      ],
    );
  }
}
