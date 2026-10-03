import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/passenger_model.dart';

class EditPassengerProfilePage extends StatefulWidget {
  final PassengerModel passenger;

  const EditPassengerProfilePage({Key? key, required this.passenger}) : super(key: key);

  @override
  State<EditPassengerProfilePage> createState() => _EditPassengerProfilePageState();
}

class _EditPassengerProfilePageState extends State<EditPassengerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.passenger.name);
    phoneCtrl = TextEditingController(text: widget.passenger.phoneNumber);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedPassenger = widget.passenger.copyWith(
        name: nameCtrl.text,
        phoneNumber: phoneCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.passenger.uid)
          .update(updatedPassenger.toMap());

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context, updatedPassenger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Passenger Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Name')),
              TextFormField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProfile, child: const Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }
}
