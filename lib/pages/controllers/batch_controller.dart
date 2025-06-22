import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/batch.dart';

class BatchController extends GetxController {
  final Rxn<Batch> selectedBatch = Rxn<Batch>();
  var allBatches = <Batch>[].obs;
  var dayBatches = <Batch>[].obs;
  var isAllLoading = false.obs;
  var isDayLoading = false.obs;

  void selectBatch(Batch batch) {
    selectedBatch.value = batch;
  }

  Future<void> refreshAllBatches() async {
    isAllLoading.value = true;

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('batches').select();

      allBatches.value = (data as List)
          .map((item) => Batch.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all Batches: $e');
      allBatches.clear();
    } finally {
      isAllLoading.value = false;
    }
  }

  Future<void> refreshDayBatches(String day) async {
    isDayLoading.value = true;
    
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('batches')
          .select()
          .eq('day', day);

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

  @override
  void onInit() {
    super.onInit();
    refreshAllBatches();
  }

}