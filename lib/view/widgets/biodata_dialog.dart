import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/user_provider.dart';
import 'colorful_card.dart';

/// Dialog popup 2-halaman (Identitas & Tentang Anda) untuk mengisi biodata user
class BiodataDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const BiodataDialog({super.key, this.onSuccess});

  @override
  State<BiodataDialog> createState() => _BiodataDialogState();
}

class _BiodataDialogState extends State<BiodataDialog>
    with TickerProviderStateMixin {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  int _currentStep = 0; // 0: Identitas, 1: Tentang Anda

  // Step 1: Identitas
  String _selectedGender = '';
  String? _selectedEducationLevel;

  // Step 2: Tentang Anda (Sports Profile Questions)
  String? _isActiveSportsMember;
  String? _sportsDuration;
  String? _sportsFrequency;
  String? _sportsLiking;
  String? _hasSportsCompetition;
  String? _likesSportsCompetition;

  bool _isSubmitting = false;

  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  /// Opsi pendidikan berdasarkan mode usia yang dipilih user
  List<String> _getEducationOptions(String? ageCategory) {
    if (ageCategory == '<13') {
      // Mode anak: hanya SD dan SMP
      return ['SD', 'SMP'];
    } else if (ageCategory == '>=13') {
      // Mode dewasa: SMP ke atas
      return ['SMP', 'SMA', 'Perguruan Tinggi', 'Umum'];
    } else {
      // Semua usia
      return ['SD', 'SMP', 'SMA', 'Perguruan Tinggi', 'Umum'];
    }
  }

  final List<String> _yesNoOptions = ['Ya', 'Tidak'];

  final List<String> _durationOptions = [
    'Tidak pernah aktif',
    'Kurang dari 1 tahun',
    '1-2 tahun',
    '3-4 tahun',
    'Lebih dari 4 tahun',
  ];

  final List<String> _frequencyOptions = [
    'Tidak pernah',
    '1 kali',
    '2 kali',
    '3-4 kali',
    '5 kali atau lebih',
  ];

  final List<String> _likingOptions = [
    'Sangat tidak menyukai',
    'Tidak menyukai',
    'Biasa saja',
    'Menyukai',
    'Sangat menyukai',
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdultMode = context.watch<UserProvider>().isAdultMode;
    final dialogGradient = isAdultMode
        ? const [Color(0xFF1E1B4B), Color(0xFF311B92)]
        : const [Color(0xFF6B73FF), Color(0xFF9BA3FF)];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _bounceAnimation,
          child: ColorfulCard(
            gradient: dialogGradient,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step Indicator Header
                    _buildStepHeader(isAdultMode),
                    const SizedBox(height: AppDimensions.marginM),

                    // Main Scrollable Content — Flexible shrinks to content, no big gap
                    Flexible(
                      child: SingleChildScrollView(
                        child: _currentStep == 0
                            ? _buildStep1Identitas()
                            : _buildStep2TentangAnda(),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginL),
                    // Buttons Footer
                    _buildFooterButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(bool isAdultMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: _buildStepBadge(step: 0, title: 'Identitas')),
            Container(
              width: 24,
              height: 2,
              color: Colors.white.withOpacity(0.4),
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Flexible(child: _buildStepBadge(step: 1, title: 'Tentang Anda')),
          ],
        ),        const SizedBox(height: AppDimensions.marginM),
        Text(
          _currentStep == 0
              ? (isAdultMode ? 'Formulir Data Diri' : 'Halo, Kenalan Dulu Yuk!')
              : 'Tentang Aktivitas Anda',
          style: AppFonts.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _currentStep == 0
              ? 'Isi identitas diri untuk memulai assesmen'
              : 'Jawab pertanyaan seputar kebiasaan & minat olahraga',
          style: AppFonts.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.85),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepBadge({required int step, required String title}) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : (isDone ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone)
            const Icon(Icons.check_circle, size: 13, color: Colors.white)
          else
            Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? const Color(0xFF311B92) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF311B92) : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STEP 1: IDENTITAS =================
  Widget _buildStep1Identitas() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Field
          _buildNameField(),
          const SizedBox(height: AppDimensions.marginM),

          // Jenis Kelamin Selection
          _buildGenderSelection(),
          const SizedBox(height: AppDimensions.marginM),

          // Umur Field
          _buildAgeField(),
          const SizedBox(height: AppDimensions.marginM),

          // Jenjang Sekolah Dropdown
          _buildEducationLevelDropdown(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nama Lengkap',
        hintText: 'Masukkan nama lengkapmu',
        prefixIcon: const Icon(Icons.person, color: Colors.white70),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama tidak boleh kosong';
        }
        if (value.trim().length < 2) {
          return 'Nama minimal 2 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: AppFonts.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDimensions.marginS),
        Row(
          children: [
            Expanded(
              child: _buildGenderRadio('laki-laki', 'Laki-laki', Icons.boy),
            ),
            const SizedBox(width: AppDimensions.marginM),
            Expanded(
              child: _buildGenderRadio('perempuan', 'Perempuan', Icons.girl),
            ),
          ],
        ),
        if (_selectedGender.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Pilih jenis kelamin',
              style: AppFonts.bodySmall.copyWith(color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderRadio(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () async {
        await SoundService.instance.playClickSound();
        HapticFeedback.lightImpact();
        setState(() {
          _selectedGender = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      decoration: InputDecoration(
        labelText: 'Umur',
        hintText: 'Berapa umurmu?',
        prefixIcon: const Icon(Icons.cake, color: Colors.white70),
        suffixText: 'tahun',
        suffixStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Umur tidak boleh kosong';
        }
        final age = int.tryParse(value);
        if (age == null) {
          return 'Umur harus berupa angka';
        }
        final selectedCat = context.read<UserProvider>().selectedAgeCategory;
        if (selectedCat == '<13' && age >= 13) {
          return 'Untuk kategori ini, umur harus di bawah 13 tahun';
        } else if (selectedCat == '>=13' && age < 13) {
          return 'Untuk kategori ini, umur harus 13 tahun ke atas';
        }
        if (age < 3 || age > 99) {
          return 'Umur tidak valid';
        }
        return null;
      },
    );
  }

  Widget _buildEducationLevelDropdown() {
    final userProvider = context.read<UserProvider>();
    final ageCategory = userProvider.selectedAgeCategory;
    final isAdultMode = userProvider.isAdultMode;
    final options = _getEducationOptions(ageCategory);

    // Reset pilihan jika tidak ada di list opsi yang aktif
    if (_selectedEducationLevel != null &&
        !options.contains(_selectedEducationLevel)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedEducationLevel = null);
      });
    }

    // Label hint sesuai mode — dibuat singkat agar tidak overflow
    final hintLabel = ageCategory == '<13' ? 'Pilih Jenjang' : 'Pilih Jenjang';

    // Warna dropdown sesuai tema mode
    final dropdownBgColor = isAdultMode
        ? const Color(0xFF1E1B4B)   // mode dewasa: dark navy
        : const Color(0xFF5A63E8);  // mode anak: ungu terang

    return DropdownButtonFormField<String>(
      value: _selectedEducationLevel,
      dropdownColor: dropdownBgColor,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Jenjang Sekolah',
        hintText: hintLabel,
        prefixIcon: const Icon(Icons.school, color: Colors.white70),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedEducationLevel = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih jenjang sekolah Anda';
        }
        return null;
      },
    );
  }

  // ================= STEP 2: TENTANG ANDA =================
  Widget _buildStep2TentangAnda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question 1
        _buildQuestionCard(
          number: 1,
          question:
              'Apakah Anda saat ini aktif mengikuti latihan olahraga sebagai anggota tim sekolah atau klub olahraga?',
          child: _buildChoiceChips(
            options: _yesNoOptions,
            selectedValue: _isActiveSportsMember,
            onSelected: (val) => setState(() => _isActiveSportsMember = val),
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        // Question 2
        _buildQuestionCard(
          number: 2,
          question:
              'Berapa lama Anda telah aktif mengikuti latihan olahraga di sekolah atau klub?',
          child: _buildDropdownQuestion(
            hint: 'Pilihan Lama Latihan',
            options: _durationOptions,
            selectedValue: _sportsDuration,
            onChanged: (val) => setState(() => _sportsDuration = val),
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        // Question 3
        _buildQuestionCard(
          number: 3,
          question:
              'Dalam satu minggu, seberapa sering Anda mengikuti latihan atau kegiatan olahraga di luar pelajaran PJOK?',
          child: _buildDropdownQuestion(
            hint: 'Pilihan Frekuensi Seminggu',
            options: _frequencyOptions,
            selectedValue: _sportsFrequency,
            onChanged: (val) => setState(() => _sportsFrequency = val),
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        // Question 4
        _buildQuestionCard(
          number: 4,
          question:
              'Seberapa besar Anda menyukai kegiatan olahraga atau aktivitas fisik?',
          child: _buildDropdownQuestion(
            hint: 'Pilihan Tingkat Menyukai',
            options: _likingOptions,
            selectedValue: _sportsLiking,
            onChanged: (val) => setState(() => _sportsLiking = val),
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        // Question 5
        _buildQuestionCard(
          number: 5,
          question:
              'Apakah Anda pernah mengikuti kompetisi/lomba olahraga sebelumnya?',
          child: _buildChoiceChips(
            options: _yesNoOptions,
            selectedValue: _hasSportsCompetition,
            onSelected: (val) => setState(() => _hasSportsCompetition = val),
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        // Question 6
        _buildQuestionCard(
          number: 6,
          question: 'Apakah Anda menyukai kompetisi/lomba olahraga?',
          child: _buildChoiceChips(
            options: _yesNoOptions,
            selectedValue: _likesSportsCompetition,
            onSelected: (val) => setState(() => _likesSportsCompetition = val),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard({
    required int number,
    required String question,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.radiusM),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: AppFonts.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceChips({
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Row(
      children: options.map((opt) {
        final isSelected = selectedValue == opt;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () async {
                await SoundService.instance.playClickSound();
                HapticFeedback.lightImpact();
                onSelected(opt);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.radiusS),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF311B92) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownQuestion({
    required String hint,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: const Color(0xFF1E1B4B),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusS),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusS),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: options.map((String opt) {
        return DropdownMenuItem<String>(
          value: opt,
          child: Text(
            opt,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (val) async {
        await SoundService.instance.playClickSound();
        onChanged(val);
      },
    );
  }

  // ================= FOOTER BUTTONS =================
  Widget _buildFooterButtons() {
    return Row(
      children: [
        // Back / Cancel Button
        Expanded(
          child: TextButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    await SoundService.instance.playClickSound();
                    if (_currentStep == 1) {
                      setState(() => _currentStep = 0);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusM),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: Text(
              _currentStep == 1 ? 'Kembali' : 'Batal',
              style: AppFonts.labelMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppDimensions.marginM),

        // Next / Submit Button
        Expanded(
          flex: 2,
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return ElevatedButton(
                onPressed: (_isSubmitting || userProvider.isLoading)
                    ? null
                    : () {
                        if (_currentStep == 0) {
                          _goToStep2();
                        } else {
                          _submitForm();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF311B92),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting || userProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF311B92),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 0 ? 'Lanjut' : 'Mulai!',
                            style: AppFonts.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF311B92),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _currentStep == 0
                                ? Icons.arrow_forward_rounded
                                : Icons.check_circle_rounded,
                            size: 18,
                            color: const Color(0xFF311B92),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _goToStep2() async {
    if (!_formKeyStep1.currentState!.validate() || _selectedGender.isEmpty) {
      if (_selectedGender.isEmpty) {
        setState(() {}); // Show gender error
      }
      return;
    }

    await SoundService.instance.playClickSound();
    HapticFeedback.lightImpact();

    setState(() {
      _currentStep = 1;
    });
  }

  Future<void> _submitForm() async {
    // Validate Step 2 inputs
    if (_isActiveSportsMember == null ||
        _sportsDuration == null ||
        _sportsFrequency == null ||
        _sportsLiking == null ||
        _hasSportsCompetition == null ||
        _likesSportsCompetition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Mohon jawab semua pertanyaan pada halaman Tentang Anda.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusS),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await SoundService.instance.playClickSound();
    HapticFeedback.mediumImpact();

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.registerUser(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      age: int.parse(_ageController.text),
      educationLevel: _selectedEducationLevel,
      isActiveSportsMember: _isActiveSportsMember,
      sportsDuration: _sportsDuration,
      sportsFrequency: _sportsFrequency,
      sportsLiking: _sportsLiking,
      hasSportsCompetition: _hasSportsCompetition,
      likesSportsCompetition: _likesSportsCompetition,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userProvider.errorMessage ?? 'Terjadi kesalahan saat mendaftar',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusS),
            ),
          ),
        );
      }
    }
  }
}
