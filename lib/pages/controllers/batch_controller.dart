import 'package:get/get.dart';
import 'package:the_project/backend/batch.dart';

class BatchController extends GetxController {
  final Rxn<Batch> selectedBatch = Rxn<Batch>();

  void selectBatch(Batch batch) {
    selectedBatch.value = batch;
  }
}