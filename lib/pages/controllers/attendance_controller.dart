import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxBool isDayWise = true.obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void toggleDayWise() {
    isDayWise.value = !isDayWise.value;
  }

  void setDayWise(bool value) {
    isDayWise.value = value;
  }

}