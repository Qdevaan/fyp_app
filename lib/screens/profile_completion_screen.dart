import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Needed for UserMetadata
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _nameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  DateTime? _dob;
  String? _gender;
  
  File? _imageFile;
  String? _googleAvatarUrl; // To store URL if coming from Google
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _prefillGoogleData();
  }

  // --- Auto-Fetch Google Info ---
  void _prefillGoogleData() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      // 1. Try to get Full Name
      final metaName = user.userMetadata?['full_name']; // Standard OAuth key
      if (metaName != null) {
        _nameCtrl.text = metaName;
      }
      
      // 2. Try to get Avatar URL
      final metaAvatar = user.userMetadata?['avatar_url']; // Standard OAuth key
      if (metaAvatar != null) {
        setState(() => _googleAvatarUrl = metaAvatar);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _googleAvatarUrl = null; // Override Google avatar if user picks manual one
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.isEmpty || _countryCtrl.text.isEmpty || _dob == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _loading = true);

    try {
      String? finalAvatarUrl = _googleAvatarUrl;

      // If user picked a new file, upload it. Otherwise use the Google one.
      if (_imageFile != null) {
        finalAvatarUrl = await AuthService.instance.uploadAvatar(_imageFile!);
      }

      await AuthService.instance.upsertProfile(
        fullName: _nameCtrl.text.trim(),
        avatarUrl: finalAvatarUrl,
        dob: _dob,
        gender: _gender,
        country: _countryCtrl.text.trim(),
      );

      if (!mounted) return;
      // Success -> Go Home
      Navigator.of(context).pushReplacementNamed('/home');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper to decide which image to show
    ImageProvider? bgImage;
    if (_imageFile != null) {
      bgImage = FileImage(_imageFile!);
    } else if (_googleAvatarUrl != null) {
      bgImage = NetworkImage(_googleAvatarUrl!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setup your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: bgImage,
                child: bgImage == null 
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) 
                  : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tap to change photo', style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),
            AppInput(controller: _nameCtrl, label: 'Full Name'),
            const SizedBox(height: 16),
            
            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _gender = val),
            ),
            const SizedBox(height: 16),

            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dob == null ? 'Select Date of Birth' : 'DOB: ${_dob!.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context, 
                  initialDate: DateTime(2000), 
                  firstDate: DateTime(1900), 
                  lastDate: DateTime.now()
                );
                if (d != null) setState(() => _dob = d);
              },
            ),
            const SizedBox(height: 16),
            
            AppInput(controller: _countryCtrl, label: 'Country'),
            const SizedBox(height: 30),
            
            AppButton(label: 'Complete Setup', onTap: _saveProfile, loading: _loading),
          ],
        ),
      ),
    );
  }
}