import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxBool isDayWise = true.obs;
  final Rxn<DateTime> refreshTrigger = Rxn<DateTime>();

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void toggleDayWise() {
    isDayWise.value = !isDayWise.value;
  }

  void setDayWise(bool value) {
    isDayWise.value = value;
  }

  void triggerRefresh() {
    refreshTrigger.value = DateTime.now();
  }

}