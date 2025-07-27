import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/app/batch.dart';

class BatchController extends GetxController {
  final Rxn<Batch> selectedBatch = Rxn<Batch>();
  var allBatches = <Batch>[].obs;
  var dayBatches = <Batch>[].obs;
  var isAllLoading = false.obs;
  var isDayLoading = false.obs;
  var filteredBatches = <Batch>[].obs;

  void selectBatch(Batch batch) {
    selectedBatch.value = batch;
  }

 Future<void> refreshAllBatches() async {
    isAllLoading.value = true;

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('batches')
          .select();

      final batches = (data as List)
          .map((item) => Batch.fromMap(item))
          .toList();

      // Custom weekday ordering
      const dayOrder = {
        "Monday": 1,
        "Tuesday": 2,
        "Wednesday": 3,
        "Thursday": 4,
        "Friday": 5,
        "Saturday": 6,
        "Sunday": 7,
      };

      batches.sort((a, b) {
        final aDay = dayOrder[a.day] ?? 999;
        final bDay = dayOrder[b.day] ?? 999;
        if (aDay != bDay) return aDay.compareTo(bDay);
        return _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime));
      });

      allBatches.value = batches;
    } catch (e) {
      debugPrint('Error fetching all Batches: $e');
      allBatches.clear();
    } finally {
      isAllLoading.value = false;
    }
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> refreshDayBatches(String day) async {
    isDayLoading.value = true;
    
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('batches')
          .select()
          .eq('day', day)
          .order('start_time', ascending: true);

      dayBatches.value = (data as List)
          .map((item) => Batch.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint("Error Loading day batches: $e");
      dayBatches.clear();
    } finally {
      isDayLoading.value = false;
    }
  }

  void filterBatchesByName(String query) {
    if (query.isEmpty) {
      filteredBatches.assignAll(allBatches);
    } else {
      filteredBatches.assignAll(
        allBatches.where((batch) => batch.name.toLowerCase().contains(query.toLowerCase()))
      );
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    refreshAllBatches();
    ever(allBatches, (_) => filteredBatches.assignAll(allBatches));
  }

}