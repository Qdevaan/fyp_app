import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../theme/design_tokens.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _nameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(); // Used for Autocomplete
  final _dobCtrl = TextEditingController(); // Controller for the DOB display text
  
  DateTime? _dob;
  String? _gender;
  
  File? _imageFile;
  String? _googleAvatarUrl;
  bool _loading = false;

  // Extensive list of countries for the dropdown
  static const List<String> _countries = [
    'United States', 'United Kingdom', 'Canada', 'Australia', 'Pakistan', 'India', 
    'Germany', 'France', 'Italy', 'Spain', 'Brazil', 'Mexico', 'Japan', 'South Korea',
    'China', 'Russia', 'South Africa', 'Nigeria', 'Egypt', 'Saudi Arabia', 'UAE',
    'Argentina', 'Netherlands', 'Sweden', 'Norway', 'Denmark', 'Finland', 'Poland',
    'Turkey', 'Indonesia', 'Thailand', 'Vietnam', 'Philippines', 'Malaysia', 'Singapore',
    'New Zealand', 'Ireland', 'Portugal', 'Greece', 'Switzerland', 'Austria', 'Belgium'
  ];

  @override
  void initState() {
    super.initState();
    _prefillGoogleData();
  }

  void _prefillGoogleData() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      final metaName = user.userMetadata?['full_name'];
      if (metaName != null) _nameCtrl.text = metaName;
      
      final metaAvatar = user.userMetadata?['avatar_url'];
      if (metaAvatar != null) setState(() => _googleAvatarUrl = metaAvatar);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _googleAvatarUrl = null;
      });
    }
  }

  // --- Date Picker Logic ---
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(2000);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Theme.of(context).colorScheme.surface, // Modern Dialog bg
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
        // Update the text field to show the formatted date
        _dobCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    // Validate fields
    if (_nameCtrl.text.isEmpty || _countryCtrl.text.isEmpty || _dob == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _loading = true);

    try {
      String? finalAvatarUrl = _googleAvatarUrl;
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

  // --- Unified Styling Helper ---
  // This ensures Name, Gender, Country, and Date all look EXACTLY the same
  InputDecoration _getDecoration(BuildContext context, String label, {IconData? icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Background Image Helper
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
            // 1. Photo Section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: bgImage,
                  child: bgImage == null 
                    ? Icon(Icons.add_a_photo_outlined, size: 32, color: theme.colorScheme.primary) 
                    : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Tap to upload photo', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            
            const SizedBox(height: 32),

            // 2. Full Name Input
            TextFormField(
              controller: _nameCtrl,
              decoration: _getDecoration(context, 'Full Name', icon: Icons.person_outline),
            ),
            
            const SizedBox(height: 16),
            
            // 3. Gender Dropdown (Styled to match Input)
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _getDecoration(context, 'Gender', icon: Icons.wc),
              icon: const Icon(Icons.arrow_drop_down_circle_outlined),
              items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _gender = val),
            ),
            
            const SizedBox(height: 16),

            // 4. Date of Birth (Read-only Text Field that opens Date Picker)
            TextFormField(
              controller: _dobCtrl,
              readOnly: true, // Prevents keyboard from opening
              onTap: _selectDate,
              decoration: _getDecoration(context, 'Date of Birth', icon: Icons.calendar_today_outlined),
            ),

            const SizedBox(height: 16),
            
            // 5. Country Autocomplete
            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return _countries.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _countryCtrl.text = selection;
                  },
                  // The input field itself
                  fieldViewBuilder: (context, fieldTextEditingController, focusNode, onFieldSubmitted) {
                    // Sync the internal autocomplete controller with our main _countryCtrl
                    if (_countryCtrl.text.isNotEmpty && fieldTextEditingController.text.isEmpty) {
                       fieldTextEditingController.text = _countryCtrl.text;
                    }
                    // Capture changes
                    fieldTextEditingController.addListener(() {
                      _countryCtrl.text = fieldTextEditingController.text;
                    });
                    
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: focusNode,
                      decoration: _getDecoration(context, 'Country', icon: Icons.public),
                    );
                  },
                  // The dropdown list items
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          width: constraints.maxWidth, // Matches the width of the input
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            ),

            const SizedBox(height: 40),
            
            // 6. Complete Button with Animation
            AppButton(
              label: 'Complete Setup', 
              onTap: _saveProfile, 
              loading: _loading
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}