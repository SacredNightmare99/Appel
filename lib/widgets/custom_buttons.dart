import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_project/utils/colors.dart';

class AddButton extends StatelessWidget {
  final void Function()? onPressed;
  const AddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: AppColors.navbar,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(5),
          side: BorderSide(width: 1)
        ),
        child: const Icon(Iconsax.add, color: Colors.white,),
      ),
    );
  }
}