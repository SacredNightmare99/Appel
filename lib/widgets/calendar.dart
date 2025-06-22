import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_project/pages/controllers/attendance_controller.dart';
import 'package:the_project/pages/controllers/batch_controller.dart';
import 'package:the_project/utils/helpers.dart';

class CustomCalendar extends StatelessWidget {
  const CustomCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final batchController = Get.find<BatchController>();
    final attendanceController = Get.find<AttendanceController>();
    final date = attendanceController.selectedDate.value ?? DateTime.now();

    return TableCalendar(
      key: ValueKey(date),
      focusedDay: date,
      firstDay: DateTime(2025),
      lastDay: DateTime(3000),
      shouldFillViewport: true,
      selectedDayPredicate: (day) => isSameDay(day, date),
      onDaySelected: (selectedDay, focusedDay) async {
        attendanceController.selectDate(focusedDay);
        await batchController.refreshDayBatches(AppHelper.getWeekdayName(focusedDay));
      },
      enabledDayPredicate: (day) => !day.isAfter(DateTime.now()),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12)),
        weekendTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12), color: Colors.red),
        selectedTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12), fontWeight: FontWeight.bold),
        todayTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12), fontWeight: FontWeight.bold),
        disabledTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12), color: Colors.blueGrey),
        outsideDaysVisible: false
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12)),
        weekendStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12)),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 14), fontWeight: FontWeight.w600),
        formatButtonTextStyle: TextStyle(fontSize: AppHelper.responsiveSize(context, 12)),
      ),
    );
  }
}