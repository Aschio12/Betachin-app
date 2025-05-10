// Import required Flutter and Supabase packages
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ProfilePage widget, a stateful widget for displaying user profile and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// State class for ProfilePage, managing user data and UI state
class _ProfilePageState extends State<ProfilePage> {
  // Initialize Supabase client for authentication and database operations
  final _supabase = Supabase.instance.client;
  // State variables for user profile data
  String _email = '';
  String _userId = '';
  String _fullName = 'User';
  String? _phone;
  String? _address;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user profile data on widget initialization
    _loadUserProfile();
  }

  // Fetch user profile data from Supabase auth and profiles table
  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Get current authenticated user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        // If no user is authenticated, navigate to login
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      if (!mounted) return;
      setState(() {
        _email = user.email ?? 'No email found';
        _userId = user.id;
      });

      // Fetch additional profile details from profiles table
      try {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', _userId)
            .maybeSingle(); // Use maybeSingle() instead of single()

        if (!mounted) return;

        if (response != null) {
          setState(() {
            _fullName = response['full_name'] ?? 'User';
            _phone = response['phone'];
            _address = response['address'];
          });
        } else {
          // Create a default profile if none exists
          await _createDefaultProfile();
        }
      } catch (e) {
        debugPrint('Error fetching profile: ${e.toString()}');
        // Profile might not exist yet, create a default one
        if (mounted) {
          await _createDefaultProfile();
        }
      }
    } catch (e) {
      debugPrint('Error in _loadUserProfile: ${e.toString()}');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    } finally {
      // FIXED: Removed return statement from finally block
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Create a default profile if none exists
  Future<void> _createDefaultProfile() async {
    if (!mounted) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': _userId,
        'full_name': _fullName,
        'email': _email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating default profile: ${e.toString()}');
    }
  }

  // Show dialog for changing user password
  void _showChangePasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _updatePassword(passwordController.text);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Update user password via Supabase auth
  Future<void> _updatePassword(String newPassword) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating password: ${e.toString()}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: ${e.toString()}')),
      );
    } finally {
      // FIXED: Removed return statement from finally block
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Show dialog for editing user profile details
  Future<void> _editProfile() async {
    final TextEditingController nameController =
        TextEditingController(text: _fullName);
    final TextEditingController phoneController =
        TextEditingController(text: _phone ?? '');
    final TextEditingController addressController =
        TextEditingController(text: _address ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return;

      setState(() => _isLoading = true);

      try {
        await _supabase.from('profiles').upsert({
          'id': _userId,
          'full_name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (!mounted) return;

        setState(() {
          _fullName = nameController.text;
          _phone = phoneController.text;
          _address = addressController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        debugPrint('Error updating profile: ${e.toString()}');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      } finally {
        // FIXED: Removed return statement from finally block
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Show dialog with admin contact information
  void _contactAdmin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Admin'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('For any issues or inquiries, please contact the admin at:'),
            SizedBox(height: 8),
            Text('admin@property.com',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('or call us at:'),
            SizedBox(height: 8),
            Text('+1 (555) 123-4567',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build the ProfilePage UI with card-like sections
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        // AppBar: Topmost component displaying the page title
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
        ),
        // Body: Conditionally shows loading indicator or profile content
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadUserProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Header Card: Displays user avatar and details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).primaryColor.withAlpha(
                            26), // Using withAlpha instead of withOpacity
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person,
                                  size: 70, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (_phone != null && _phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _phone!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'User ID: $_userId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Spacer between Profile Header and Account section
                      const SizedBox(height: 16),
                      // Account Settings Card: Options for editing profile and password
                      _buildSectionTitle('Account'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _editProfile,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.lock_outline),
                              title: const Text('Change Password'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _showChangePasswordDialog,
                            ),
                          ],
                        ),
                      ),
                      // Spacer between Account and Privacy & Security sections
                      const SizedBox(height: 16),
                      // Privacy & Security Card: Links to privacy policy and terms
                      _buildSectionTitle('Privacy & Security'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.security),
                              title: const Text('Privacy Policy'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Privacy Policy not implemented yet')),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.help_outline),
                              title: const Text('Terms & Conditions'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Terms & Conditions not implemented yet')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Spacer between Privacy & Security and Support sections
                      const SizedBox(height: 16),
                      // Support Card: Options for contacting admin and logging out
                      _buildSectionTitle('Support'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.support_agent),
                              title: const Text('Contact Admin'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _contactAdmin,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading:
                                  const Icon(Icons.logout, color: Colors.red),
                              title: const Text('Log Out',
                                  style: TextStyle(color: Colors.red)),
                              onTap: _handleLogout,
                            ),
                          ],
                        ),
                      ),
                      // Final spacer at the bottom of the scrollable content
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Helper method to build section titles with a divider
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Expanded(child: Divider(indent: 8)),
        ],
      ),
    );
  }

  // Handle logout with confirmation dialog and Supabase auth sign-out
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      // Sign out from Supabase
      await _supabase.auth.signOut();

      // Check if mounted before navigating
      if (!mounted) return;

      // Navigate to login page
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      debugPrint('Error during logout: ${e.toString()}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }
}
