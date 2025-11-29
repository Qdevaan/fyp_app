import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_logo.dart';
import '../theme/design_tokens.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _nameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(); 
  final _dobCtrl = TextEditingController(); 
  
  DateTime? _dob;
  String? _gender;
  
  File? _imageFile;
  String? _avatarUrl;
  bool _loading = false;
  bool _initialLoading = true;

  // Extensive list of countries
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      final profile = await AuthService.instance.getProfile();

      if (profile != null) {
        _nameCtrl.text = profile['full_name'] ?? '';
        _countryCtrl.text = profile['country'] ?? '';
        _gender = profile['gender'];
        _avatarUrl = profile['avatar_url'];
        
        if (profile['dob'] != null) {
          _dob = DateTime.parse(profile['dob']);
          _dobCtrl.text = "${_dob!.day}/${_dob!.month}/${_dob!.year}";
        }
      } 
      
      if (_nameCtrl.text.isEmpty) {
        final metaName = user.userMetadata?['full_name'];
        if (metaName != null) _nameCtrl.text = metaName;
      }
      if (_avatarUrl == null) {
        final metaAvatar = user.userMetadata?['avatar_url'];
        if (metaAvatar != null) _avatarUrl = metaAvatar;
      }

    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

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
              surface: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCountries = _countries.where((country) => 
              country.toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: TextField(
                        onChanged: (val) {
                          setModalState(() => searchQuery = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Country',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const Divider(),
                    // List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];
                          final isSelected = country == _countryCtrl.text;
                          return ListTile(
                            title: Text(
                              country,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                            trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                            onTap: () {
                              setState(() => _countryCtrl.text = country);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.isEmpty || _countryCtrl.text.isEmpty || _dob == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        )
      );
      return;
    }

    setState(() => _loading = true);

    try {
      String? finalAvatarUrl = _avatarUrl;
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
      Navigator.of(context).pushReplacementNamed('/home');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _getDecoration(BuildContext context, String label, {IconData? icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant) : null,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    ImageProvider? bgImage;
    if (_imageFile != null) {
      bgImage = FileImage(_imageFile!);
    } else if (_avatarUrl != null) {
      bgImage = CachedNetworkImageProvider(_avatarUrl!);
    }

    if (_initialLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 80)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Complete Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tell us a bit more about yourself',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // 1. Photo Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          backgroundImage: bgImage,
                          child: bgImage == null 
                            ? Icon(Icons.person_rounded, size: 60, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)) 
                            : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                            ),
                            child: Icon(Icons.camera_alt_rounded, size: 20, color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),

                // 2. Full Name Input
                AppInput(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 3. Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: _getDecoration(context, 'Gender', icon: Icons.wc_rounded),
                  icon: Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.onSurfaceVariant),
                  dropdownColor: theme.colorScheme.surfaceContainer,
                  items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(
                    value: e, 
                    child: Text(e, style: TextStyle(color: theme.colorScheme.onSurface))
                  )).toList(),
                  onChanged: (val) => setState(() => _gender = val),
                ),
                
                const SizedBox(height: AppSpacing.md),

                // 4. Date of Birth
                AppInput(
                  controller: _dobCtrl,
                  label: 'Date of Birth',
                  prefixIcon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _selectDate,
                ),

                const SizedBox(height: AppSpacing.md),
                
                // 5. Country Picker (Modern Modal)
                AppInput(
                  controller: _countryCtrl,
                  label: 'Country',
                  prefixIcon: Icons.public_rounded,
                  readOnly: true,
                  onTap: _showCountryPicker,
                  suffixIcon: Icons.arrow_drop_down_rounded,
                ),

                const SizedBox(height: AppSpacing.xl),
                
                // 6. Complete Button
                AppButton(
                  label: 'Complete Setup', 
                  onTap: _saveProfile, 
                  loading: _loading
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}