import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_project/utils/colors.dart';

class AddButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? tooltip;
  const AddButton({super.key, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Tooltip(
        message: tooltip,
        child: MaterialButton(
          onPressed: onPressed,
          color: AppColors.frenchBlue,
          hoverColor: AppColors.frenchBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          elevation: 1,
          child: const Icon(Iconsax.add, color: Colors.white,),
        ),
      ),
    );
  }
}