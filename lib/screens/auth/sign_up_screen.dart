import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:image_picker/image_picker.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:uniso_social_media_app/screens/auth/sign_in_screen.dart";

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _SignUpScreenState extends State<SignUpScreen> {
  // Form
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _usernameInputController =
      TextEditingController();
  final TextEditingController _emailInputController = TextEditingController();
  final TextEditingController _birthdateInputController =
      TextEditingController();
  final TextEditingController _passwordInputController =
      TextEditingController();

  // UI state
  bool _passwordObscured = true;
  bool _termsAndConditionsAccepted = false;
  bool _signUpRequestInProgress = false;

  // Avatar / profile picture state
  static const String _placeholderAvatarUrl = "https://via.placeholder.com/150";
  String? _selectedAvatarUrl = _placeholderAvatarUrl;
  Uint8List? _uploadedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _usernameInputController.dispose();
    _emailInputController.dispose();
    _birthdateInputController.dispose();
    _passwordInputController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Business logic
  // ---------------------------------------------------------------------------

  Future<void> _submitSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    if (!_termsAndConditionsAccepted) return;

    setState(() => _signUpRequestInProgress = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailInputController.text.trim(),
        password: _passwordInputController.text.trim(),
        data: {
          "username": _usernameInputController.text.trim(),
          "birthdate": _birthdateInputController.text,
          "avatar_url": _selectedAvatarUrl,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Registration successful! Check your email for verification.",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (authError) {
      _showErrorSnackBar(authError.message);
    } catch (_) {
      _showErrorSnackBar("Unexpected error occurred");
    } finally {
      if (mounted) setState(() => _signUpRequestInProgress = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToSignIn() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _passwordObscured = !_passwordObscured);
  }

  void _toggleTermsAcceptance(bool? accepted) {
    setState(() => _termsAndConditionsAccepted = accepted ?? false);
  }

  // ---------------------------------------------------------------------------
  // Date picker
  // ---------------------------------------------------------------------------

  Future<void> _openBirthdatePicker() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _birthdateInputController.text = DateFormat(
          "yyyy-MM-dd",
        ).format(selectedDate);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Avatar / image selection
  // ---------------------------------------------------------------------------

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _uploadedImageBytes = imageBytes;
          _selectedAvatarUrl = null;
        });
      }
    } catch (imagePickError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $imagePickError")),
        );
      }
    }
  }

  void _showAvatarSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.casino),
              title: const Text("Pick a random avatar"),
              onTap: () {
                Navigator.pop(context);
                _showRandomAvatarGridDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text("Upload from file manager"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRandomAvatarGridDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose an Avatar"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 9,
            itemBuilder: (_, int avatarIndex) {
              final String avatarUrl =
                  "https://picsum.photos/id/${avatarIndex + 10}/150/150";
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAvatarUrl = avatarUrl;
                    _uploadedImageBytes = null;
                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTransparentAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _signUpFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileAvatarPicker(
                      uploadedImageBytes: _uploadedImageBytes,
                      selectedAvatarUrl: _selectedAvatarUrl,
                      onEditPressed: _showAvatarSelectionBottomSheet,
                    ),
                    const SizedBox(height: 16),
                    _FormSectionHeader(),
                    const SizedBox(height: 32),
                    _UsernameField(controller: _usernameInputController),
                    const SizedBox(height: 16),
                    _EmailField(controller: _emailInputController),
                    const SizedBox(height: 16),
                    _BirthdateField(
                      controller: _birthdateInputController,
                      onTap: () => _openBirthdatePicker(),
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _passwordInputController,
                      isObscured: _passwordObscured,
                      onToggleVisibility: _togglePasswordVisibility,
                    ),
                    const SizedBox(height: 16),
                    _TermsAcceptanceRow(
                      isAccepted: _termsAndConditionsAccepted,
                      onChanged: _toggleTermsAcceptance,
                    ),
                    const SizedBox(height: 24),
                    _SignUpButton(
                      isLoading: _signUpRequestInProgress,
                      isEnabled: _termsAndConditionsAccepted,
                      onPressed: _submitSignUp,
                    ),
                    const SizedBox(height: 16),
                    _NavigateToSignInButton(onPressed: _navigateToSignIn),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildTransparentAppBar() {
    return AppBar(
      title: const Text("Sign Up"),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: "Exit to Home",
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

/// Circular avatar preview with an edit button overlay. Renders either an
/// in-memory uploaded image, a remote avatar URL, or a fallback person icon.
class _ProfileAvatarPicker extends StatelessWidget {
  const _ProfileAvatarPicker({
    required this.uploadedImageBytes,
    required this.selectedAvatarUrl,
    required this.onEditPressed,
  });

  final Uint8List? uploadedImageBytes;
  final String? selectedAvatarUrl;
  final VoidCallback onEditPressed;

  ImageProvider? get _resolvedAvatarImage {
    if (uploadedImageBytes != null) return MemoryImage(uploadedImageBytes!);
    if (selectedAvatarUrl != null) return NetworkImage(selectedAvatarUrl!);
    return null;
  }

  bool get _hasNoAvatarSelected =>
      uploadedImageBytes == null && selectedAvatarUrl == null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[800],
                backgroundImage: _resolvedAvatarImage,
                child: _hasNoAvatarSelected
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: onEditPressed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "avatars",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Heading and subtitle displayed above the form fields.
class _FormSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Create your profile",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "Fill in the details below to join the community",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

/// Username input field with presence validation.
class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Username",
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: (enteredUsername) {
        if (enteredUsername == null || enteredUsername.isEmpty) {
          return "Please enter your username";
        }
        return null;
      },
    );
  }
}

/// Email address input field with format validation.
class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email Address",
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (enteredEmail) {
        if (enteredEmail == null ||
            enteredEmail.isEmpty ||
            !enteredEmail.contains("@")) {
          return "Please enter a valid email address";
        }
        return null;
      },
    );
  }
}

/// Read-only birthdate field that opens a date picker dialog on tap.
class _BirthdateField extends StatelessWidget {
  const _BirthdateField({required this.controller, required this.onTap});

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: const InputDecoration(
        labelText: "Birthdate",
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
        hintText: "YYYY-MM-DD",
      ),
      validator: (selectedBirthdate) {
        if (selectedBirthdate == null || selectedBirthdate.isEmpty) {
          return "Please select your birthdate";
        }
        return null;
      },
    );
  }
}

/// Password input field with a visibility toggle and minimum-length validation.
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.isObscured,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool isObscured;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (enteredPassword) {
        if (enteredPassword == null || enteredPassword.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }
}

/// Checkbox row for accepting the User Agreement and Privacy Policy.
class _TermsAcceptanceRow extends StatelessWidget {
  const _TermsAcceptanceRow({
    required this.isAccepted,
    required this.onChanged,
  });

  final bool isAccepted;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: isAccepted, onChanged: onChanged),
        const Expanded(
          child: Text(
            "I agree to the User Agreement and Privacy Policy",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Primary call-to-action button that triggers registration. Disabled unless
/// the user has accepted the terms. Shows a spinner while the request runs.
class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text("Sign Up"),
    );
  }
}

/// Text button that navigates existing users back to the sign-in screen.
class _NavigateToSignInButton extends StatelessWidget {
  const _NavigateToSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text("Already have an account? Sign In"),
    );
  }
}
