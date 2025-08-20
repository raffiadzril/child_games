import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/user_provider.dart';
import 'colorful_card.dart';

/// Dialog popup untuk mengisi biodata user
class BiodataDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const BiodataDialog({super.key, this.onSuccess});

  @override
  State<BiodataDialog> createState() => _BiodataDialogState();
}

class _BiodataDialogState extends State<BiodataDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController();

  String _selectedGender = '';
  bool _isSubmitting = false;

  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

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

    // Start animations
    _slideController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _classController.dispose();
    _schoolController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _bounceAnimation,
          child: ColorfulCard(
            gradient: const [Color(0xFF6B73FF), Color(0xFF9BA3FF)],
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      _buildHeader(),

                      const SizedBox(height: AppDimensions.marginL),

                      // Form Fields
                      _buildNameField(),
                      const SizedBox(height: AppDimensions.marginM),

                      _buildGenderSelection(),
                      const SizedBox(height: AppDimensions.marginM),

                      _buildAgeField(),
                      const SizedBox(height: AppDimensions.marginM),

                      _buildClassField(),
                      const SizedBox(height: AppDimensions.marginM),

                      _buildSchoolField(),
                      const SizedBox(height: AppDimensions.marginL),

                      // Buttons
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon dengan animasi pulse
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 1.0, end: 1.1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppDimensions.marginM),

        // Title
        ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.white70],
              ).createShader(bounds),
          child: Text(
            'Halo, Kenalan Dulu Yuk!',
            style: AppFonts.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppDimensions.marginS),

        Text(
          'Ceritakan tentang dirimu agar kita bisa bermain bersama',
          style: AppFonts.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.red, width: 2),
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
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Pilih jenis kelamin',
              style: AppFonts.bodySmall.copyWith(
                color: Colors.red.withOpacity(0.8),
              ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.red, width: 2),
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
        if (age < 3 || age > 18) {
          return 'Umur harus antara 3-18 tahun';
        }
        return null;
      },
    );
  }

  Widget _buildClassField() {
    return TextFormField(
      controller: _classController,
      decoration: InputDecoration(
        labelText: 'Kelas',
        hintText: 'Contoh: 1A, 2B, TK A',
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kelas tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildSchoolField() {
    return TextFormField(
      controller: _schoolController,
      decoration: InputDecoration(
        labelText: 'Sekolah',
        hintText: 'Contoh: SD Negeri 1, TK Harapan',
        prefixIcon: const Icon(Icons.location_city, color: Colors.white70),
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama sekolah tidak boleh kosong';
        }
        if (value.trim().length < 3) {
          return 'Nama sekolah minimal 3 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: TextButton(
            onPressed:
                _isSubmitting
                    ? null
                    : () async {
                      await SoundService.instance.playClickSound();
                      Navigator.of(context).pop();
                    },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusM),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: Text(
              'Batal',
              style: AppFonts.labelMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppDimensions.marginM),

        // Submit Button
        Expanded(
          flex: 2,
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return ElevatedButton(
                onPressed:
                    (_isSubmitting || userProvider.isLoading)
                        ? null
                        : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6B73FF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                  ),
                  elevation: 2,
                ),
                child:
                    _isSubmitting || userProvider.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6B73FF),
                            ),
                          ),
                        )
                        : Text(
                          'Mulai Bermain!',
                          style: AppFonts.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedGender.isEmpty) {
      if (_selectedGender.isEmpty) {
        setState(() {}); // Refresh to show gender error
      }
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
      className: _classController.text.trim(),
      school: _schoolController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // Success - close dialog and call callback
      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userProvider.errorMessage ?? 'Terjadi kesalahan',
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
