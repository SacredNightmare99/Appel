import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_project/controllers/login_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/image_paths.dart';
import 'package:the_project/utils/validators.dart';
import 'package:the_project/widgets/cards.dart';
import 'package:the_project/widgets/custom_buttons.dart';
import 'package:the_project/widgets/text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40,),
                Text(
                  "Welcome To Appel!",
                  style: TextStyle(
                      fontSize: 32,
                      color: AppColors.frenchBlue,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: OuterCard(
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            AppImagePaths.logo,
                            width: 180,
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            hintText: "Email",
                            obscureText: false,
                            validator: Validators.validateEmail,
                            prefixIcon: const Icon(Iconsax.user),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Obx(
                            () => CustomTextFormField(
                              controller: controller.passwordController,
                              hintText: "Password",
                              obscureText: controller.obscurePass.value,
                              keyboardType: TextInputType.text,
                              validator: Validators.validatePassword,
                              prefixIcon:
                                  const Icon(Iconsax.password_check),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePass.value
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                ),
                                onPressed: () {
                                  controller.toggleObscurePass();
                                },
                                style: ButtonStyle(
                                  // Change hover color
                                  overlayColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (states.contains(WidgetState.hovered)) {
                                        return Colors.blue.withValues(
                                            alpha: 0.1); 
                                      }
                                      if (states.contains(WidgetState.pressed)) {
                                        return Colors.blue.withValues(
                                            alpha: 0.2); 
                                      }
                                      return null; 
                                    },
                                  ),
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (states.contains(WidgetState.hovered)) {
                                        return AppColors.frenchBlueAccent; 
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Obx(() {
                            if (controller.errorMsg.value != null) {
                              return Text(
                                controller.errorMsg.value!,
                                style: TextStyle(color: AppColors.error),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                              width: 170,
                              height: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Obx(
                                () => controller.isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : LoginButton(
                                        onPressed: () => controller.login(),
                                      ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
