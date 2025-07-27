
import 'package:get/get.dart';
import 'package:the_project/backend/auth/user.dart';

class UserController extends GetxController {
  Rxn<CurrentUser> currentUser = Rxn<CurrentUser>();

  void setUser(CurrentUser user) {
    currentUser.value = user;
  }

  CurrentUser? get user => currentUser.value;

}