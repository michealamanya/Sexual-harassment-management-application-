import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String value;
  final bool isReadOnly;
  final bool isLocked;
  final bool isDropdown;
  final String? helperText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.value,
    this.isReadOnly = false,
    this.isLocked = false,
    this.isDropdown = false,
    this.helperText,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.label,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isDropdown || isLocked ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isReadOnly || isLocked || isDropdown
                      ? Text(
                          value,
                          style: AppStyles.bodyMedium,
                        )
                      : TextFormField(
                          controller: controller,
                          initialValue: controller == null ? value : null,
                          onChanged: onChanged,
                          style: AppStyles.bodyMedium,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock_outline,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                if (isDropdown)
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textLight,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: AppStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ],
      ],
    );
  }
}
