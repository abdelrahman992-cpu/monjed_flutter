import 'package:flutter/material.dart';

import 'otp_verification_screen.dart';
import '../../models/Auth_and_User_Models.dart';
import '../../models/zone.dart';

import '../../controllers/zone_controller.dart';
import '../../controllers/auth_controller.dart';

class SignUpScreenVolunteer extends StatefulWidget {
  const SignUpScreenVolunteer({super.key});

  @override
  State<SignUpScreenVolunteer> createState() =>
      _SignUpScreenVolunteerState();
}

class _SignUpScreenVolunteerState
    extends State<SignUpScreenVolunteer> {
  // ==========================================================
  // SETTINGS
  // ==========================================================

  static const bool _showVehicleSection = true;

  // ==========================================================
  // FORM
  // ==========================================================

  final _formKey = GlobalKey<FormState>();

  final ZonesController zonesController =
      ZonesController();

  final AuthController authController =
      AuthController();

  // ==========================================================
  // COUNTRIES / ZONES
  // ==========================================================

  List<Map<String, dynamic>> countries = [];

  List<Zone> zones = [];

  String? selectedCountryCode;

  String? selectedCountry;

  Zone? selectedZone;

  bool loadingCountries = true;

  bool loadingZones = false;

  // ==========================================================
  // ACCOUNT
  // ==========================================================

  bool creatingAccount = false;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController capacityController =
      TextEditingController(
    text: '3',
  );

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  // ==========================================================
  // VOLUNTEER
  // ==========================================================

  String selectedVehicle = 'Car';

  // ==========================================================
  // VOLUNTEER SKILLS
  // ==========================================================

  final List<String> selectedSkills = [
    'transportation',
  ];

  final List<String> availableSkills = [
    'evacuation',
    'transportation',
    'mobility_assistance',
    'medical_support',
    'rescue_support',
    'general_support',
  ];

  // ==========================================================
  // SKILL LABEL
  // القيمة دي للعرض فقط
  // الـ API بياخد القيمة الأصلية
  // ==========================================================

  String skillLabel(String skill) {
    switch (skill) {
      case 'evacuation':
        return 'Evacuation';

      case 'transportation':
        return 'Transportation';

      case 'mobility_assistance':
        return 'Mobility assistance';

      case 'medical_support':
        return 'Medical support';

      case 'rescue_support':
        return 'Rescue support';

      case 'general_support':
        return 'General support';

      default:
        return skill;
    }
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadCountries();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    capacityController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // REGISTER VOLUNTEER ACCOUNT
  // ==========================================================

  Future<void> _registerVolunteer() async {
    // ========================================================
    // FORM VALIDATION
    // ========================================================

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ========================================================
    // COUNTRY VALIDATION
    // ========================================================

    if (selectedCountry == null ||
        selectedCountry!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a country',
          ),
        ),
      );

      return;
    }

    // ========================================================
    // ZONE VALIDATION
    // ========================================================

    if (selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a zone',
          ),
        ),
      );

      return;
    }

    // ========================================================
    // VEHICLE VALIDATION
    // ========================================================

    int? parsedCapacity;

    if (selectedVehicle != 'None') {
      parsedCapacity = int.tryParse(
        capacityController.text.trim(),
      );

      if (parsedCapacity == null || parsedCapacity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a valid vehicle capacity',
            ),
          ),
        );

        return;
      }
    }

    // ========================================================
    // START LOADING
    // ========================================================

    setState(() {
      creatingAccount = true;
    });

    try {
      // ======================================================
      // REGISTER USER
      // ======================================================

      final result =
          await authController.register(
        displayName:
            nameController.text.trim(),

        email:
            emailController.text.trim(),

        password:
            passwordController.text,

        phone:
            phoneController.text.trim(),

        role:
            'volunteer',

        zoneId:
            selectedZone!.zoneId,

        country:
            selectedCountry,

        skills:
            selectedSkills,

        accessibilityNeeds:
            const [],

        // ====================================================
        // VEHICLE TYPE
        //
        // None => null
        // Car/Motorcycle/Boat => selected value
        // ====================================================

        vehicleType:
            selectedVehicle == 'None'
                ? null
                : selectedVehicle,

        // ====================================================
        // CAPACITY
        //
        // None => null
        // Vehicle => integer value
        // ====================================================

        capacity:
            selectedVehicle == 'None'
                ? null
                : int.tryParse(
                    capacityController.text.trim(),
                  ),
      );

      // ======================================================
      // DEBUG
      // ======================================================

      print(
        '================================',
      );

      print(
        'REGISTER SUCCESS',
      );

      print(
        'USER ID: ${result.userId}',
      );

      print(
        'EMAIL: ${result.email}',
      );

      print(
        'OTP REQUIRED: ${result.requiresOtp}',
      );

      print(
        'VEHICLE TYPE: '
        '${selectedVehicle == 'None' ? null : selectedVehicle}',
      );

      print(
        'CAPACITY: '
        '${selectedVehicle == 'None' ? null : int.tryParse(
            capacityController.text.trim(),
          )}',
      );

      print(
        'SKILLS: $selectedSkills',
      );

      print(
        '================================',
      );

      if (!mounted) {
        return;
      }

      // ======================================================
      // GO TO OTP
      // ======================================================

      if (result.requiresOtp) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationScreen(
              userId:
                  result.userId,

              email:
                  result.email,

              successRoute:
                  '/volunteer',
            ),
          ),
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/volunteer',
        );
      }
    } catch (e) {
      // ======================================================
      // REGISTER ERROR
      // ======================================================

      print(
        'REGISTER ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: $e',
          ),
        ),
      );
    } finally {
      // ======================================================
      // STOP LOADING
      // ======================================================

      if (mounted) {
        setState(() {
          creatingAccount = false;
        });
      }
    }
  }

  // ==========================================================
  // LOAD COUNTRIES
  // ==========================================================

  Future<void> _loadCountries() async {
    try {
      final loadedCountries =
          await zonesController.loadCountries();

      print(
        'LOADED COUNTRIES: '
        '${loadedCountries.length}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        countries =
            loadedCountries;

        loadingCountries =
            false;
      });
    } catch (e) {
      print(
        'LOAD COUNTRIES ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loadingCountries =
            false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load countries: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // LOAD ZONES FOR COUNTRY
  // ==========================================================

  Future<void> _loadZonesForCountry(
    String countryCode,
  ) async {
    setState(() {
      loadingZones = true;

      zones = [];

      selectedZone = null;
    });

    try {
      final loadedZones =
          await zonesController.loadZones(
        countryCode,
      );

      print(
        'LOADED ZONES [$countryCode]: '
        '${loadedZones.length}',
      );

      for (final zone in loadedZones) {
        print(
          'ZONE: '
          '${zone.zoneId} | '
          '${zone.name} | '
          '${zone.country}',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        zones =
            loadedZones;

        loadingZones =
            false;
      });
    } catch (e) {
      print(
        'LOAD ZONES ERROR [$countryCode]: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loadingZones = false;

        zones = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load zones: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FC),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Container(
              height: 52,

              width: double.infinity,

              decoration:
                  const BoxDecoration(
                color: Colors.white,

                border: Border(
                  bottom: BorderSide(
                    color:
                        Color(0xFFD9E0EA),
                  ),
                ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    // ------------------------------------------
                    // LOGO
                    // ------------------------------------------

                    Row(
                      children: [

                        Container(
                          width: 23,
                          height: 23,

                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,

                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFD9E5F5,
                              ),

                              width: 2,
                            ),
                          ),

                          child:
                              const Center(
                            child: Icon(
                              Icons
                                  .radio_button_checked,

                              size: 14,

                              color:
                                  Color(
                                0xFF2455D6,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 9,
                        ),

                        const Text(
                          'MONJED',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF273348,
                            ),

                            fontSize: 18,

                            fontWeight:
                                FontWeight.w800,

                            letterSpacing:
                                -0.5,
                          ),
                        ),
                      ],
                    ),

                    // ------------------------------------------
                    // BACK
                    // ------------------------------------------

                    GestureDetector(
                      onTap: () =>
                          Navigator.pop(
                        context,
                      ),

                      child: const Row(
                        children: [

                          Icon(
                            Icons.arrow_back,

                            size: 16,

                            color:
                                Color(
                              0xFF718096,
                            ),
                          ),

                          SizedBox(
                            width: 4,
                          ),

                          Text(
                            'Back',

                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF718096,
                              ),

                              fontSize: 13,

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child:
                  SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 420,
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),

                      child: Form(
                        key: _formKey,

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            // ==================================
                            // TITLE
                            // ==================================

                            const Text(
                              'VOLUNTEER ACCESS',

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF5F83D7,
                                ),

                                fontSize: 10,

                                fontWeight:
                                    FontWeight.bold,

                                letterSpacing:
                                    2.0,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            const Text(
                              'Become a volunteer',

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF101827,
                                ),

                                fontSize: 27,

                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            const Text(
                              'Create a volunteer account on the MONJED API. Matching happens on your private dashboard.',

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF718096,
                                ),

                                fontSize: 13,

                                height: 1.5,
                              ),
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            // ==================================
                            // FULL NAME
                            // ==================================

                            _fieldLabel(
                              'Full name',
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            TextFormField(
                              controller:
                                  nameController,

                              decoration:
                                  inputDecoration(
                                hint: '',
                                icon: null,
                              ),

                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'Please enter your name';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // EMAIL
                            // ==================================

                            _fieldLabel(
                              'Email',
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            TextFormField(
                              controller:
                                  emailController,

                              keyboardType:
                                  TextInputType
                                      .emailAddress,

                              decoration:
                                  inputDecoration(
                                hint:
                                    'you@example.com',

                                icon:
                                    Icons
                                        .email_outlined,
                              ),

                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'Please enter your email';
                                }

                                if (!value
                                    .contains('@')) {
                                  return 'Enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // PHONE
                            // ==================================

                            _fieldLabel(
                              'Phone',
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            TextFormField(
                              controller:
                                  phoneController,

                              keyboardType:
                                  TextInputType.phone,

                              decoration:
                                  inputDecoration(
                                hint:
                                    '+2547XXXXXXXX',

                                icon: null,
                              ),

                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'Please enter your phone number';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // COUNTRY
                            // ==================================

                            _fieldLabel(
                              'Country',
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            DropdownButtonFormField<String>(
                              value:
                                  selectedCountryCode,

                              decoration:
                                  inputDecoration(
                                hint:
                                    loadingCountries
                                        ? 'Loading countries...'
                                        : 'Select country',

                                icon:
                                    Icons.public,
                              ),

                              isExpanded:
                                  true,

                              items:
                                  countries.map(
                                (
                                  country,
                                ) {
                                  final code =
                                      country[
                                                'country_code']
                                            ?.toString() ??
                                          '';

                                  final name =
                                      country[
                                                'country']
                                            ?.toString() ??
                                          '';

                                  return DropdownMenuItem<
                                      String>(
                                    value:
                                        code,

                                    child:
                                        Text(
                                      name,
                                    ),
                                  );
                                },
                              ).toList(),

                              onChanged:
                                  loadingCountries
                                      ? null
                                      : (
                                          code,
                                        ) {
                                          if (code ==
                                              null) {
                                            return;
                                          }

                                          final selected =
                                              countries
                                                  .firstWhere(
                                            (
                                              country,
                                            ) =>
                                                country[
                                                      'country_code']
                                                    ?.toString() ==
                                                code,
                                          );

                                          setState(
                                            () {
                                              selectedCountryCode =
                                                  code;

                                              selectedCountry =
                                                  selected[
                                                          'country']
                                                      ?.toString();

                                              selectedZone =
                                                  null;

                                              zones = [];
                                            },
                                          );

                                          _loadZonesForCountry(
                                            code,
                                          );
                                        },

                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value.isEmpty) {
                                  return 'Please select your country';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // ZONE
                            // ==================================

                            _fieldLabel(
                              'Zone / Area',
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            DropdownButtonFormField<Zone>(
                              value:
                                  selectedZone,

                              decoration:
                                  inputDecoration(
                                hint:
                                    loadingZones
                                        ? 'Loading zones...'
                                        : selectedCountryCode ==
                                                null
                                            ? 'Select country first'
                                            : zones.isEmpty
                                                ? 'No zones available'
                                                : 'Select zone / area',

                                icon:
                                    Icons
                                        .location_on_outlined,
                              ),

                              isExpanded:
                                  true,

                              items:
                                  zones.map(
                                (
                                  zone,
                                ) {
                                  return DropdownMenuItem<
                                      Zone>(
                                    value:
                                        zone,

                                    child:
                                        Text(
                                      zone.name,
                                    ),
                                  );
                                },
                              ).toList(),

                              onChanged:
                                  (
                                    !loadingZones &&
                                    selectedCountryCode !=
                                        null &&
                                    zones.isNotEmpty
                                  )
                                      ? (
                                          zone,
                                        ) {
                                          setState(
                                            () {
                                              selectedZone =
                                                  zone;
                                            },
                                          );
                                        }
                                      : null,

                              validator:
                                  (value) {
                                if (value ==
                                    null) {
                                  return 'Please select your zone';
                                }

                                return null;
                              },
                            ),

                            // ==================================================
                            // VEHICLE SECTION
                            // ==================================================

                            if (_showVehicleSection) ...[
                              const SizedBox(
                                height: 16,
                              ),

                              // ==============================================
                              // VEHICLE
                              // ==============================================

                              _fieldLabel(
                                'Vehicle',
                              ),

                              const SizedBox(
                                height: 7,
                              ),

                              DropdownButtonFormField<String>(
                                value:
                                    selectedVehicle,

                                decoration:
                                    inputDecoration(
                                  hint: '',
                                  icon: null,
                                ),

                                isExpanded:
                                    true,

                                items: const [
                                  DropdownMenuItem(
                                    value: 'Car',
                                    child:
                                        Text(
                                      'Car',
                                    ),
                                  ),

                                  DropdownMenuItem(
                                    value:
                                        'Motorcycle',
                                    child:
                                        Text(
                                      'Motorcycle',
                                    ),
                                  ),

                                  DropdownMenuItem(
                                    value: 'Boat',
                                    child:
                                        Text(
                                      'Boat',
                                    ),
                                  ),

                                  DropdownMenuItem(
                                    value: 'None',
                                    child:
                                        Text(
                                      'None',
                                    ),
                                  ),
                                ],

                                onChanged:
                                    (value) {
                                  if (value ==
                                      null) {
                                    return;
                                  }

                                  setState(
                                    () {
                                      selectedVehicle =
                                          value;

                                      // ----------------------------------
                                      // NONE
                                      // ----------------------------------
                                      //
                                      // لو مفيش Vehicle:
                                      // - transportation تتشال
                                      // - Capacity مش هتظهر
                                      // - Skills مش هتظهر
                                      //

                                      if (selectedVehicle ==
                                          'None') {
                                        selectedSkills
                                            .remove(
                                          'transportation',
                                        );
                                      }

                                      // ----------------------------------
                                      // VEHICLE SELECTED
                                      // ----------------------------------
                                      //
                                      // لو رجع اختار Vehicle:
                                      // transportation ترجع افتراضيًا
                                      //

                                      else {
                                        if (!selectedSkills
                                            .contains(
                                          'transportation',
                                        )) {
                                          selectedSkills
                                              .add(
                                            'transportation',
                                          );
                                        }
                                      }
                                    },
                                  );
                                },

                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value.isEmpty) {
                                    return 'Please select your vehicle';
                                  }

                                  return null;
                                },
                              ),

                              // ==================================================
                              // CAPACITY + SKILLS
                              // ==================================================

                              if (selectedVehicle !=
                                  'None') ...[
                                const SizedBox(
                                  height: 16,
                                ),

                                // ==============================================
                                // CAPACITY
                                // ==============================================

                                _fieldLabel(
                                  'Capacity',
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                TextFormField(
                                  controller:
                                      capacityController,

                                  keyboardType:
                                      TextInputType.number,

                                  decoration:
                                      inputDecoration(
                                    hint:
                                        'Number of people',
                                    icon:
                                        null,
                                  ),

                                  validator:
                                      (value) {
                                    if (value ==
                                            null ||
                                        value
                                            .trim()
                                            .isEmpty) {
                                      return 'Please enter capacity';
                                    }

                                    final capacity =
                                        int.tryParse(
                                      value
                                          .trim(),
                                    );

                                    if (capacity ==
                                            null ||
                                        capacity <=
                                            0) {
                                      return 'Enter a valid capacity';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(
                                  height: 16,
                                ),

                                // ==============================================
                                // SKILLS
                                // ==============================================

                                _fieldLabel(
                                  'Skills',
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,

                                  children:
                                      availableSkills
                                          .map(
                                    (
                                      skill,
                                    ) {
                                      final isSelected =
                                          selectedSkills
                                              .contains(
                                        skill,
                                      );

                                      return ChoiceChip(
                                        label:
                                            Text(
                                          skillLabel(
                                            skill,
                                          ),

                                          style:
                                              TextStyle(
                                            fontSize:
                                                11,

                                            color: isSelected
                                                ? const Color(
                                                    0xFF2455D6,
                                                  )
                                                : const Color(
                                                    0xFF718096,
                                                  ),

                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),

                                        selected:
                                            isSelected,

                                        selectedColor:
                                            const Color(
                                          0xFFE2EBF8,
                                        ),

                                        backgroundColor:
                                            Colors.white,

                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            6,
                                          ),

                                          side:
                                              BorderSide(
                                            color: isSelected
                                                ? const Color(
                                                    0xFF2455D6,
                                                  )
                                                : const Color(
                                                    0xFFD6DEE9,
                                                  ),
                                          ),
                                        ),

                                        showCheckmark:
                                            false,

                                        onSelected:
                                            (selected) {
                                          setState(
                                            () {
                                              if (selected) {
                                                if (!selectedSkills
                                                    .contains(
                                                  skill,
                                                )) {
                                                  selectedSkills
                                                      .add(
                                                    skill,
                                                  );
                                                }
                                              } else {
                                                selectedSkills
                                                    .remove(
                                                  skill,
                                                );
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ],

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // PASSWORD
                            // ==================================

                            _fieldLabel(
                              'Password',
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            TextFormField(
                              controller:
                                  passwordController,

                              obscureText:
                                  obscurePassword,

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'At least 8 characters',

                                hintStyle:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFFB1BDCC,
                                  ),

                                  fontSize: 13,
                                ),

                                prefixIcon:
                                    const Icon(
                                  Icons.lock_outline,

                                  size: 17,

                                  color:
                                      Color(
                                    0xFF8291A5,
                                  ),
                                ),

                                suffixIcon:
                                    IconButton(
                                  icon:
                                      Icon(
                                    obscurePassword
                                        ? Icons
                                            .visibility_outlined
                                        : Icons
                                            .visibility_off_outlined,

                                    size: 18,

                                    color:
                                        const Color(
                                      0xFF8291A5,
                                    ),
                                  ),

                                  onPressed:
                                      () {
                                    setState(
                                      () {
                                        obscurePassword =
                                            !obscurePassword;
                                      },
                                    );
                                  },
                                ),

                                filled:
                                    true,

                                fillColor:
                                    Colors.white,

                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 14,
                                ),

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    6,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFD6DEE9,
                                    ),
                                  ),
                                ),

                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    6,
                                  ),

                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFF2455D6,
                                    ),
                                  ),
                                ),
                              ),

                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value.isEmpty) {
                                  return 'Please enter a password';
                                }

                                if (value.length <
                                    8) {
                                  return 'Password must be at least 8 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            // ==================================
                            // CREATE ACCOUNT
                            // ==================================

                            SizedBox(
                              width:
                                  double.infinity,

                              height: 42,

                              child:
                                  ElevatedButton(
                                onPressed:
                                    creatingAccount
                                        ? null
                                        : _registerVolunteer,

                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF2455D6,
                                  ),

                                  foregroundColor:
                                      Colors.white,

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      6,
                                    ),
                                  ),
                                ),

                                child:
                                    creatingAccount
                                        ? const SizedBox(
                                            width:
                                                18,

                                            height:
                                                18,

                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth:
                                                  2,

                                              color:
                                                  Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Create volunteer account',

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  13,

                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // ==================================
                            // LOGIN
                            // ==================================

                            Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [

                                  const Text(
                                    'Already registered? ',

                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFF718096,
                                      ),

                                      fontSize:
                                          13,
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator
                                          .pushReplacementNamed(
                                        context,
                                        '/volunteer-login',
                                      );
                                    },

                                    child:
                                        const Text(
                                      'Log in',

                                      style:
                                          TextStyle(
                                        color:
                                            Color(
                                          0xFF2455D6,
                                        ),

                                        fontSize:
                                            13,

                                        fontWeight:
                                            FontWeight
                                                .w600,
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

            // ==================================================
            // FOOTER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              width:
                  double.infinity,

              decoration:
                  const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        Color(0xFFD9E0EA),
                  ),
                ),
              ),

              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  Expanded(
                    child: Text(
                      'FLOOD AND EARTHQUAKE SCORES ARE NEVER BLENDED',

                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF8B9AAF,
                        ),

                        fontSize: 7.5,

                        fontWeight:
                            FontWeight.w600,

                        letterSpacing:
                            0.5,
                      ),

                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(
                    width: 4,
                  ),

                  Text(
                    'LIVE API · COMMUNITY REPORT · ANALYZE',

                    style:
                        TextStyle(
                      color:
                          Color(
                        0xFF8B9AAF,
                      ),

                      fontSize: 7.5,

                      fontWeight:
                          FontWeight.w600,

                      letterSpacing:
                          0.5,
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

  // ==========================================================
  // FIELD LABEL
  // ==========================================================

  Widget _fieldLabel(
    String text,
  ) {
    return Text(
      text,

      style:
          const TextStyle(
        color:
            Color(0xFF718096),

        fontSize: 10,

        fontWeight:
            FontWeight.w600,

        letterSpacing: 1.4,
      ),
    );
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration inputDecoration({
    required String hint,
    required IconData? icon,
  }) {
    return InputDecoration(
      hintText:
          hint,

      hintStyle:
          const TextStyle(
        color:
            Color(0xFFB1BDCC),

        fontSize: 13,
      ),

      prefixIcon:
          icon != null
              ? Icon(
                  icon,

                  size: 17,

                  color:
                      const Color(
                    0xFF8291A5,
                  ),
                )
              : null,

      filled:
          true,

      fillColor:
          Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          6,
        ),

        borderSide:
            const BorderSide(
          color:
              Color(0xFFD6DEE9),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          6,
        ),

        borderSide:
            const BorderSide(
          color:
              Color(0xFF2455D6),
        ),
      ),
    );
  }
}
