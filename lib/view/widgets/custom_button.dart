import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/radius.dart';
import '../../core/constants/fonts.dart';

/// Custom button widget yang konsisten dengan tema aplikasi
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return _buildOutlinedButton(theme);
    } else {
      return _buildElevatedButton(theme);
    }
  }

  Widget _buildElevatedButton(ThemeData theme) {
    return SizedBox(
      width: width,
      height: height ?? AppDimensions.buttonHeightM,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.textOnDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusGameButton),
          ),
          elevation: AppDimensions.elevationS,
        ),
        child: _buildButtonContent(theme),
      ),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return SizedBox(
      width: width,
      height: height ?? AppDimensions.buttonHeightM,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          side: BorderSide(
            color: backgroundColor ?? AppColors.primary,
            width: AppDimensions.borderWidthMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusGameButton),
          ),
        ),
        child: _buildButtonContent(theme),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return const SizedBox(
        width: AppDimensions.iconM,
        height: AppDimensions.iconM,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconS),
          const SizedBox(width: AppDimensions.marginS),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? AppFonts.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? AppFonts.fontSizeL,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
