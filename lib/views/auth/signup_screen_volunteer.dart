import 'package:flutter/material.dart';

class SignUpScreenVolunteer extends StatefulWidget {
  const SignUpScreenVolunteer({super.key});

  @override
  State<SignUpScreenVolunteer> createState() => _SignUpScreenVolunteerState();
}

class _SignUpScreenVolunteerState extends State<SignUpScreenVolunteer> {
  // ===========================================================================
  // متغير التحكم: اجعله true لإظهار قسم المركبات، أو false لإخفائه في أي وقت لاحقاً
  // ===========================================================================
  static const bool _showVehicleSection = true;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final townController = TextEditingController();
  final capacityController = TextEditingController(text: '3');
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  String selectedCountry = 'Kenya';
  String selectedVehicle = 'Car';
  
  final List<String> selectedSkills = ['Driving'];

  final List<String> availableSkills = [
    'First aid',
    'Driving',
    'Boat / water rescue',
    'Translation',
    'Logistics',
    'Shelter setup',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    townController.dispose();
    capacityController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleSignUp() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Volunteer account information is valid.'),
      ),
    );

    // TODO: Connect this later to FastAPI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================
            Container(
              height: 52,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFD9E0EA),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD9E5F5),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.radio_button_checked,
                              size: 14,
                              color: Color(0xFF2455D6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'MONJED',
                          style: TextStyle(
                            color: Color(0xFF273348),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Color(0xFF718096),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // CONTENT
            // ==========================================================
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VOLUNTEER ACCESS',
                              style: TextStyle(
                                color: Color(0xFF5F83D7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Become a volunteer',
                              style: TextStyle(
                                color: Color(0xFF101827),
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create a volunteer account on the MONJED API. Matching happens on your private dashboard.',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Full Name
                            const Text(
                              'Full name',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: nameController,
                              decoration: inputDecoration(hint: '', icon: null),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            const Text(
                              'Email',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: inputDecoration(
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            const Text(
                              'Phone',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: inputDecoration(hint: '+2547XXXXXXXX', icon: null),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Country / zone
                            const Text(
                              'Country / zone',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            DropdownButtonFormField<String>(
                              value: selectedCountry,
                              decoration: inputDecoration(hint: '', icon: null),
                              items: const [
                                DropdownMenuItem(value: 'Kenya', child: Text('Kenya')),
                                DropdownMenuItem(value: 'Egypt', child: Text('Egypt')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedCountry = value ?? 'Kenya';
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Town / area
                            const Text(
                              'Town / area',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: townController,
                              decoration: inputDecoration(
                                hint: '',
                                icon: Icons.location_on_outlined,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ==========================================================
                            // قسم المركبات والقدرة والمهارات (يظهر/يختفي تلقائياً حسب المتغير)
                            // ==========================================================
                            if (_showVehicleSection) ...[
                              // Vehicle
                              const Text(
                                'Vehicle',
                                style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 7),
                              DropdownButtonFormField<String>(
                                value: selectedVehicle,
                                decoration: inputDecoration(hint: '', icon: null),
                                items: const [
                                  DropdownMenuItem(value: 'Car', child: Text('Car')),
                                  DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle')),
                                  DropdownMenuItem(value: 'Boat', child: Text('Boat')),
                                  DropdownMenuItem(value: 'None', child: Text('None')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedVehicle = value ?? 'Car';
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Capacity
                              const Text(
                                'Capacity',
                                style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 7),
                              TextFormField(
                                controller: capacityController,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration(hint: '', icon: null),
                              ),
                              const SizedBox(height: 16),

                              // Skills Chips
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: availableSkills.map((skill) {
                                  final isSelected = selectedSkills.contains(skill);
                                  return ChoiceChip(
                                    label: Text(
                                      skill,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? const Color(0xFF2455D6)
                                            : const Color(0xFF718096),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFFE2EBF8),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFF2455D6)
                                            : const Color(0xFFD6DEE9),
                                      ),
                                    ),
                                    showCheckmark: false,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedSkills.add(skill);
                                        } else {
                                          selectedSkills.remove(skill);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Password
                            const Text(
                              'Password',
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'At least 8 characters',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB1BDCC),
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  size: 17,
                                  color: Color(0xFF8291A5),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: const Color(0xFF8291A5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD6DEE9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2455D6),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2455D6),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Create volunteer account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Footer link
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already registered? ',
                                    style: TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/volunteer-login',
                                      );
                                    },
                                    child: const Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Color(0xFF2455D6),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFD9E0EA),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'FLOOD AND EARTHQUAKE SCORES ARE NEVER BLENDED',
                      style: TextStyle(
                        color: Color(0xFF8B9AAF),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'LIVE API · COMMUNITY REPORT · ANALYZE',
                    style: TextStyle(
                      color: Color(0xFF8B9AAF),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFB1BDCC),
        fontSize: 13,
      ),
      prefixIcon: icon != null
          ? Icon(
              icon,
              size: 17,
              color: const Color(0xFF8291A5),
            )
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD6DEE9),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF2455D6),
        ),
      ),
    );
  }
}
