import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:time_manager/assets.dart';
import 'package:time_manager/model/userprofile.dart';
import 'package:time_manager/utils.dart';

import '../Routes/routes.dart';
import '../db/sqlitedb.dart';

class UserDetailsEntry extends StatefulWidget {
  const UserDetailsEntry({super.key});

  @override
  State<UserDetailsEntry> createState() => _UserDetailsEntryState();
}

class _UserDetailsEntryState extends State<UserDetailsEntry> {
  DateTime? _selectedDate;
  bool txtName_valiadate = false;
  bool txtDate_valiadate = false;
  final dbHelper = DatabaseHelper();
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtDate = TextEditingController();

  @override
  void dispose() {
    txtName.dispose();
    txtDate.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final name = txtName.text;
    final dob = txtDate.text;

    setState(() {
      txtName_valiadate = name.isEmpty;
      txtDate_valiadate = dob.isEmpty;
    });

    if (txtName_valiadate || txtDate_valiadate) {
      if (txtName_valiadate) {
        showCommonSnackbar(context, 'Name cannot be empty');
      }
      if (txtDate_valiadate) {
        showCommonSnackbar(context, 'Date of Birth cannot be empty');
      }
      return; // Exit the function if validation fails
    }

    try {
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dob);
      int id = await dbHelper.insertUserProfile(
        UserProfile(name: name, dateOfBirth: parsedDate),
      );
      if (id > 0) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        print('Successfully added user profile with id $id');
        // Show a success message or navigate to another screen
      } else {
        showCommonSnackbar(context, 'Failed to add user profile');
        print('Failed to add user profile');
        // Show an error message
      }
    } catch (e) {
      showCommonSnackbar(context, 'Error adding user profile: $e');
      print('Error adding user profile: $e');
      // Handle the error, show an alert or a snackbar
    }

    // Do something with the text values
    print('Text 1: $name');
    print('Text 2: $dob');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          timeManger,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Image.asset(
            Assets.logo, // Replace with your image path
            fit: BoxFit.contain, // Adjust image fit
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Lottie.asset(Assets.main_bg)),
              const SizedBox(height: 20),
              TextField(
                controller: txtName,
                decoration: InputDecoration(
                    hintText: enter_name,
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.amber, width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText:
                        txtName_valiadate ? 'Name cannot be empty' : null),
              ),
              const SizedBox(height: 16.0),
              TextField(
                readOnly: true,
                controller: txtDate,
                decoration: InputDecoration(
                  hintText: enter_dob,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.amber, width: 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: txtDate_valiadate
                      ? 'Date of Birth cannot be empty'
                      : null,
                ),
                onTap: () {
                  _showDatePickerDialog();
                },
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity, // <-- Your width
                height: 50, // <-- Your height
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shadowColor: Colors.cyanAccent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: const Size(100, 40), //////// HERE
                  ),

                  /*elevation: WidgetStateProperty.resolveWith<double?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return 16;
                            }
                            return null;
                          }),
                    ),*/
                  onPressed: _handleSubmit,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePickerDialog() async {
    DateTime initialDate = _selectedDate ?? DateTime.now();

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Container(
          height: size.height * 0.4,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () {
                        setState(() {
                          if (_selectedDate != null) {
                            txtDate.text =
                                DateFormat('dd-MM-yyyy').format(_selectedDate!);
                          }
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.27,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  onDateTimeChanged: (value) {
                    setState(() {
                      _selectedDate = value;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
