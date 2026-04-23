import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Profile setup page for first-time users
/// 3-step onboarding: Basic Info → Career/Interests → Skills/Finalize
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Page 1 - Basic Info fields
  String _selectedBoard = '';
  final _classGradeController = TextEditingController();
  final _schoolCollegeController = TextEditingController();
  String _selectedCountry = 'India';
  String _selectedState = '';
  String _selectedCity = '';
  String _selectedGender = '';

  // Page 2 - Career/Interests fields
  final _streamController = TextEditingController();
  String _careerGoalStatus = '';
  final _careerGoalTextController = TextEditingController();
  final List<String> _interests = [];
  final _interestController = TextEditingController();

  // Page 3 - Skills/Finalize fields
  final List<String> _skills = [];
  final _skillController = TextEditingController();
  String? _photoPath;
  bool _confirmationChecked = false;

  // Available options
  static const List<String> _boards = ['CBSE', 'ICSE', 'State Board'];
  
  static const List<String> _countries = ['India', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Other'];
  
  static const Map<String, List<String>> _statesByCountry = {
    'India': [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
      'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
      'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
      'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
      'Delhi', 'Chandigarh', 'Puducherry',
    ],
  };

  static const Map<String, List<String>> _citiesByState = {
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Tirupati'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi', 'Dharwad'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Aurangabad'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 'Tirunelveli'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam'],
    'Delhi': ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner', 'Ajmer'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Noida', 'Ghaziabad'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kannur'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Karnal'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain'],
  };

  static const List<String> _genders = ['Male', 'Female', 'Prefer not to say'];
  
  static const List<String> _careerGoalOptions = [
    'Sure about my career path',
    'Unsure between options',
    'Need help deciding',
  ];

  int? get _classNumber {
    final text = _classGradeController.text.trim();
    return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  bool get _isClassAbove10 => (_classNumber ?? 0) > 10;

  @override
  void dispose() {
    _pageController.dispose();
    _classGradeController.dispose();
    _schoolCollegeController.dispose();
    _streamController.dispose();
    _careerGoalTextController.dispose();
    _interestController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submitProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && _interests.length < 5 && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() => _interests.remove(interest));
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && _skills.length < 5 && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  Future<void> _submitProfile() async {
    if (!_confirmationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that the information provided is correct'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create profile update data - use getIt directly since context is above BlocProvider
    final profileBloc = getIt<ProfileBloc>();
    
    // Build location string
    final location = [_selectedCity, _selectedState, _selectedCountry]
        .where((s) => s.isNotEmpty)
        .join(', ');

    // Dispatch the onboarding profile update event with ALL collected data
    profileBloc.add(ProfileOnboardingUpdated(
      board: _selectedBoard,
      classGrade: _classGradeController.text.trim(),
      schoolName: _schoolCollegeController.text.trim(),
      stream: _streamController.text.trim(),
      gender: _selectedGender,
      location: location,
      careerGoalStatus: _careerGoalStatus,
      careerGoalText: _careerGoalTextController.text.trim(),
      generalInterests: _interests,
      skills: _skills,
    ));

    // Persist profile setup done flag so we never redirect here again
    await getIt<AuthLocalDataSource>().saveProfileSetupDone();

    // Navigate to assessment (profile done, now take the KIT)
    if (mounted) {
      GoRouter.of(context).go(AppRouter.assessment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate horizontal padding: 20% on each side for wide screens, less for narrow
    final horizontalPadding = screenWidth > 600 ? screenWidth * 0.20 : screenWidth * 0.05;
    
    return BlocProvider.value(
      value: getIt<ProfileBloc>()..add(const ProfileLoadMyProfileRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppDimensions.paddingMD,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProgressIndicator(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildBasicInfoStep(),
                          _buildCareerInterestsStep(),
                          _buildSkillsFinalizeStep(),
                        ],
                      ),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Help us personalize your experience',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLG,
        vertical: AppDimensions.paddingMD,
      ),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              _buildStepIndicator(0, 'Basic Info'),
              _buildStepConnector(0),
              _buildStepIndicator(1, 'Career'),
              _buildStepConnector(1),
              _buildStepIndicator(2, 'Skills'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? AppColors.success : AppColors.divider,
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final states = _statesByCountry[_selectedCountry] ?? [];
    final cities = _citiesByState[_selectedState] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us personalize your experience',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Board dropdown
          _buildDropdownField(
            label: 'Board',
            value: _selectedBoard.isEmpty ? null : _selectedBoard,
            items: _boards,
            onChanged: (value) => setState(() => _selectedBoard = value ?? ''),
            icon: Icons.school_outlined,
            hint: 'Select your board',
          ),
          const SizedBox(height: 16),
          
          // Class/Grade text field
          _buildTextField(
            controller: _classGradeController,
            label: 'Class / Grade',
            hint: 'e.g., 10, 12, Graduate',
            icon: Icons.class_outlined,
          ),
          const SizedBox(height: 16),
          
          // School/College text field
          _buildTextField(
            controller: _schoolCollegeController,
            label: 'School / College',
            hint: 'e.g., Delhi Public School, IIT Delhi',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 16),
          
          // Country dropdown
          _buildDropdownField(
            label: 'Country',
            value: _selectedCountry,
            items: _countries,
            onChanged: (value) => setState(() {
              _selectedCountry = value ?? 'India';
              _selectedState = '';
              _selectedCity = '';
            }),
            icon: Icons.public_outlined,
            hint: 'Select country',
          ),
          const SizedBox(height: 16),
          
          // State dropdown
          _buildDropdownField(
            label: 'State',
            value: _selectedState.isEmpty ? null : _selectedState,
            items: states,
            onChanged: (value) => setState(() {
              _selectedState = value ?? '';
              _selectedCity = '';
            }),
            icon: Icons.location_city_outlined,
            hint: 'Select state',
          ),
          const SizedBox(height: 16),
          
          // City dropdown
          _buildDropdownField(
            label: 'City',
            value: _selectedCity.isEmpty ? null : _selectedCity,
            items: cities,
            onChanged: (value) => setState(() => _selectedCity = value ?? ''),
            icon: Icons.location_on_outlined,
            hint: 'Select city',
          ),
          const SizedBox(height: 16),
          
          // Gender dropdown
          _buildDropdownField(
            label: 'Gender',
            value: _selectedGender.isEmpty ? null : _selectedGender,
            items: _genders,
            onChanged: (value) => setState(() => _selectedGender = value ?? ''),
            icon: Icons.person_outline,
            hint: 'Select gender',
          ),
        ],
      ),
    );
  }

  Widget _buildCareerInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Career & Interests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us understand your goals',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stream field - label changes based on class
          _buildTextField(
            controller: _streamController,
            label: _isClassAbove10 ? 'Stream' : 'Stream you want to select',
            hint: _isClassAbove10 
                ? 'e.g., Science, Commerce, Arts'
                : 'e.g., Science, Commerce, Arts (your preferred stream)',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          
          // Career goal dropdown
          _buildDropdownField(
            label: 'Career Goal',
            value: _careerGoalStatus.isEmpty ? null : _careerGoalStatus,
            items: _careerGoalOptions,
            onChanged: (value) => setState(() => _careerGoalStatus = value ?? ''),
            icon: Icons.flag_outlined,
            hint: 'How sure are you about your career?',
          ),
          const SizedBox(height: 16),
          
          // Career goal text box (for options or need help)
          if (_careerGoalStatus == 'Unsure between options' || 
              _careerGoalStatus == 'Need help deciding' ||
              _careerGoalStatus == 'Sure about my career path')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _careerGoalTextController,
                  label: _careerGoalStatus == 'Sure about my career path'
                      ? 'What is your career goal?'
                      : 'Tell us more about your options or what help you need',
                  hint: _careerGoalStatus == 'Sure about my career path'
                      ? 'e.g., Software Engineer, Doctor, CA'
                      : 'e.g., Confused between Engineering and Medicine',
                  icon: Icons.edit_note_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          // Interests section
          const Text(
            'Interests (up to 5)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _interestController,
                  decoration: InputDecoration(
                    hintText: 'Enter an interest',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _addInterest(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _interests.length < 5 ? _addInterest : null,
                icon: const Icon(Icons.add_circle),
                color: _interests.length < 5 ? AppColors.primary : AppColors.textTertiary,
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((interest) => Chip(
              label: Text(interest),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeInterest(interest),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.primary),
            )).toList(),
          ),
          if (_interests.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add up to 5 interests',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsFinalizeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Almost done!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your skills and finalize your profile',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Skills section
          const Text(
            'Skill Sets (4-5 skills)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillController,
                  decoration: InputDecoration(
                    hintText: 'Enter a skill',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _skills.length < 5 ? _addSkill : null,
                icon: const Icon(Icons.add_circle),
                color: _skills.length < 5 ? AppColors.primary : AppColors.textTertiary,
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) => Chip(
              label: Text(skill),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeSkill(skill),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.primary),
            )).toList(),
          ),
          if (_skills.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add 4-5 skills',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Photo upload section
          const Text(
            'Profile Photo (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // TODO: Implement photo picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo upload coming soon!')),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: AppColors.divider, width: 2),
              ),
              child: _photoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        _photoPath!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Confirmation checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _confirmationChecked,
                onChanged: (value) => setState(() => _confirmationChecked = value ?? false),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _confirmationChecked = !_confirmationChecked),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I confirm that all the information provided is correct and accurate.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textTertiary),
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    String hint = 'Select an option',
  }) {
    final uniqueItems = items.toSet().toList();
    final normalizedValue = value?.trim();
    final selectedValue = uniqueItems.contains(normalizedValue) ? normalizedValue : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text(hint),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: uniqueItems.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: uniqueItems.isNotEmpty ? onChanged : null,
        ),
      ],
    );
  }

  Widget _buildChipSelector({
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (selected) {
            final newItems = List<String>.from(selectedItems);
            if (selected) {
              newItems.add(item);
            } else {
              newItems.remove(item);
            }
            onChanged(newItems);
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isLoading = state.status == ProfileStatus.updating;
          
          return Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: _currentStep == 0 ? 1 : 1,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _currentStep == 2 ? 'Complete Setup' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
