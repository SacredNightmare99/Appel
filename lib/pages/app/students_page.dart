import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/backend/app/attendance.dart';
import 'package:the_project/backend/app/student.dart';
import 'package:the_project/controllers/attendance_controller.dart';
import 'package:the_project/controllers/batch_controller.dart';
import 'package:the_project/controllers/student_controller.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/helpers.dart';
import 'package:the_project/widgets/cards.dart';
import 'package:the_project/widgets/custom_buttons.dart';
import 'package:the_project/widgets/custom_snackbar.dart';
import 'package:the_project/widgets/custom_text.dart';
import 'package:the_project/widgets/headers.dart';
import 'package:the_project/widgets/responsive_layout.dart';
import 'package:the_project/widgets/search_overlay.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {

  final studentController = Get.find<StudentController>();
  final attendanceController = Get.find<AttendanceController>();
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocus = FocusNode();
  final searchButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentController.selectedStudent.value = null;
    });
    _searchController.addListener(() {
      studentController.filterStudentsByName(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.clear();
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchOverlay(GlobalKey key) {
    final overlay = Overlay.of(key.currentContext!);
    late OverlayEntry searchOverlay;

    searchOverlay = OverlayEntry(
      builder: (context) => CustomSearchOverlay(
        overlayEntry: searchOverlay,
        searchController: _searchController,
        layerLink: _layerLink,
        searchFocus: _searchFocus,
        onChanged: (value) => studentController.filterStudentsByName(value),
        hintText: "Search Students...",
        offset: Offset(-200, 0),
      )
    );

    overlay.insert(searchOverlay);
  }

  void _addStudent() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Student", style: TextStyle(color: AppColors.frenchBlue),),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Enter Student name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('Cancel', style: TextStyle(color: AppColors.frenchRed),)
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await insertStudent(name);
                await studentController.refreshAllStudents();
                Get.back();
              }
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frenchBlue
            ),
            child: const Text("Add", style: TextStyle(color: AppColors.cardLight),),
          )
        ],
      )
    );
  }

  void _removeStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete", style: TextStyle(color: AppColors.frenchRed),),
        content: Text("Are you sure you want to delete ${student.name}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: AppColors.frenchBlue)),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteStudent(student.uid);
              await studentController.refreshAllStudents();
              studentController.selectedStudent.value = null;
              Get.back();
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frenchRed
            ),
            child: const Text("Delete", style: TextStyle(color: AppColors.cardLight),),
          )
        ],
      ),
    );
  }

  void _editStudent(Student student) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return _EditStudentDialog(student: student);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      )
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Container(
        height: 880,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            // View Students List
            Expanded(
              flex: 2,
              child: _buildStudentList()
            ),
            // Student Details
            Expanded(
              flex: 5,
              child: _buildDesktopDetailPanel()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // Student List
        _buildStudentList(),
        const SizedBox(height: 12,),
        Obx(() {
          final selectedStudent = studentController.selectedStudent.value;
          if (selectedStudent != null) {
            return _buildMobileDetailPanel();
          } else {
            return const SizedBox.shrink();
          }
        })
      ],
    );
  }

  Widget _buildStudentList() {
    return OuterCard(
      child: InnerCard(
        child: Column(
          children: [
            Stack(
              children: [
                CustomHeader(text: "Students"),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: IconButton(
                      key: searchButtonKey,
                      icon: const Icon(Icons.search, color: AppColors.cardLight),
                      tooltip: "Search Students",
                      onPressed: () => _showSearchOverlay(searchButtonKey),
                    ),
                  ),
                ),
              ]
            ),
            SizedBox(
              height: 750,
              child: Obx(() {
                final isLoading = studentController.isLoading.value;
                final students = studentController.filteredStudents;

                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ),
                  );
                }
            
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HintText(
                          text: "No student found",              
                        ),
                        const SizedBox(height: 20),
                        AddButton(onPressed: _addStudent, tooltip: "Add Student",)
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: students.length + 1,
                  itemBuilder: (context, index) {
                    if (index < students.length) {
                      return _StudentTile(student: students[index]);
                    } else {
                      return AddButton(onPressed: _addStudent, tooltip: "Add Student",);
                    }
                  } 
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails(Student? selectedStudent) {
    return InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.frenchBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                TitleText(
                  text: "Student Details",
                ),
                if (selectedStudent != null)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () => _removeStudent(selectedStudent),
                      icon: const Icon(Icons.delete_forever),
                      color: AppColors.frenchRed,
                      iconSize: 24,
                      tooltip: "Remove Student",
                    ),
                  ),
                if (selectedStudent != null)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () => _editStudent(selectedStudent), 
                      icon: const Icon(Icons.edit),
                      color: AppColors.frenchRed,
                      iconSize: 24,
                      tooltip: "Edit Student",
                    )
                  )
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (selectedStudent == null || studentController.isLoading.value)
            const Expanded(
              child: Center(
                child: HintText(
                  text:"Select a Student",
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.frenchBlue,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    selectedStudent.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Batch:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.frenchBlue,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    selectedStudent.batchUid != null ? selectedStudent.batchName ?? "Error fetching batch name" : "No Batch assigned",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Classes Attended:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.frenchBlue,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${selectedStudent.classesPresent}/${selectedStudent.classes}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(Student? selectedStudent) {
    return InnerCard(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.frenchBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)
              )
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                TitleText(
                  text: "Attendance",
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    tooltip: "Info",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("How to Edit Attendance"),
                          content: const SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.touch_app_outlined, color: AppColors.frenchBlue),
                                  title: Text("Toggle Status"),
                                  subtitle: Text("Double-tap an entry to switch between 'Present' and 'Absent'."),
                                ),
                                ListTile(
                                  leading: Icon(Icons.back_hand_outlined, color: AppColors.frenchRed),
                                  title: Text("Delete Record"),
                                  subtitle: Text("Long-press an entry to permanently remove it."),
                                ),
                              ],
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text("GOT IT"),
                            ),
                          ],
                        ),
                      );
                    }, 
                    icon: const Icon(Icons.info),
                    color: AppColors.cardLight,
                    iconSize: 24,
                  ), 
                )
              ],
            ),
          ),
          selectedStudent == null ? 
          const Expanded(
            child: Center(
              child: HintText(
                text: "Attendance",
              )
            )
          ) 
        : SizedBox(
            height: 750,
            child: Obx( () {
              final isLoading = attendanceController.isLoading.value;
              final records = attendanceController.attendance;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator(
                    color: Colors.redAccent,
                  ),
                );
              }
    
              if (records.isEmpty) {
                return const Center(child: HintText(text: "No attendance found."));
              }

              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) => _AttendanceTile(attendance: records[index],)
              );
            }),
          ),
        ],
      )
    );
  }

  Widget _buildDesktopDetailPanel() {
    return OuterCard(
      child: Obx(() {
        final selectedStudent = studentController.selectedStudent.value;
        return Row(
          spacing: 5,
          children: [
            // Details
            Expanded(
              flex: 2,
              child: _buildStudentDetails(selectedStudent)
            ),
            // Attendance
            Expanded(
              flex: 1,
              child: _buildAttendanceList(selectedStudent)
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMobileDetailPanel() {
    return OuterCard(
      child: Obx(() {
        final selectedStudent = studentController.selectedStudent.value;
        return Column(
          children: [
            // Details
            _buildStudentDetails(selectedStudent),
            const SizedBox(height: 8,),
            // Attendance
            _buildAttendanceList(selectedStudent),
          ],
        );
      }),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final Attendance attendance;

  const _AttendanceTile({required this.attendance});

  void _showToggleConfirmation(BuildContext context, AttendanceController controller, Student student) {
    // Determine the current and new status for the dialog message
    final currentStatus = attendance.present ? "Present" : "Absent";
    final newStatus = attendance.present ? "Absent" : "Present";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Status Change"),
        content: Text("Change attendance status from '$currentStatus' to '$newStatus'?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close the dialog first
              await controller.toggleAttendanceStatus(attendance, student);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AttendanceController controller, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete", style: TextStyle(color: AppColors.frenchRed)),
        content: Text("Are you sure you want to delete the attendance record for ${AppHelper.formatDate(attendance.date)}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: AppColors.frenchBlue)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog first
              await controller.deleteAttendanceRecord(attendance, student);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.frenchRed),
            child: const Text("Delete", style: TextStyle(color: AppColors.cardLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final attendanceController = Get.find<AttendanceController>();
    final studentController = Get.find<StudentController>();
    final selectedStudent = studentController.selectedStudent.value;
    if (selectedStudent == null) return const SizedBox.shrink();

  return Container(
      margin: const EdgeInsets.all(6),
      child: Material(
        elevation: 1,
        color: AppColors.tileBackground,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onDoubleTap: () => _showToggleConfirmation(context, attendanceController, selectedStudent),
          onLongPress: () => _showDeleteConfirmation(context, attendanceController, selectedStudent),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppHelper.formatDate(attendance.date)),
                Text.rich(
                  TextSpan(
                    children: attendance.present
                        ? [
                            const TextSpan(text: 'P', style: TextStyle(color: AppColors.frenchBlue, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'resent', style: TextStyle(color: Colors.black)),
                          ]
                        : [
                            const TextSpan(text: 'A', style: TextStyle(color: AppColors.frenchRed, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'bsent', style: TextStyle(color: Colors.black)),
                          ],
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

class _StudentTile extends StatelessWidget {
  final Student student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentController>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: InkWell(
        onTap: () { 
          controller.selectStudent(student);
          final attendanceController = Get.find<AttendanceController>();
          attendanceController.fetchAttendanceForStudent(student);
        },
        child: Material(
          color: AppColors.tileBackground,
          borderRadius: BorderRadius.circular(6),
          elevation: 1,
          child: Obx(() { 
            final selectedStudent = controller.selectedStudent.value;
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                student.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: (selectedStudent == null) ? AppColors.frenchBlue : (selectedStudent.name == student.name) ? AppColors.frenchRed : AppColors.frenchBlue,
                ),
              ),
            );
          })
        ),
      ),
    );
  }
}

class _EditStudentDialog extends StatefulWidget {
  final Student student;

  const _EditStudentDialog({required this.student});

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();

  final studentController = Get.find<StudentController>();
  final batchController = Get.find<BatchController>(); 
  
  late final TextEditingController _nameController;
  late final TextEditingController _classesPresentController;
  late final TextEditingController _totalClassesController;
  String? _selectedBatchUid;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with the student's existing data
    _nameController = TextEditingController(text: widget.student.name);
    _classesPresentController = TextEditingController(text: widget.student.classesPresent.toString());
    _totalClassesController = TextEditingController(text: widget.student.classes.toString());
    _selectedBatchUid = widget.student.batchUid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classesPresentController.dispose();
    _totalClassesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedBatch = _selectedBatchUid != null
      ? batchController.allBatches.firstWhere((b) => b.uid == _selectedBatchUid)
      : null;

    final updatedStudent = widget.student.copyWith(
      name: _nameController.text.trim(),
      batchUid: _selectedBatchUid,
      batchName: selectedBatch?.name,
      classesPresent: int.tryParse(_classesPresentController.text),
      classes: int.tryParse(_totalClassesController.text),
    );

    try {
      await updateStudent(updatedStudent);
      await studentController.refreshAllStudents();
      studentController.selectStudent(updatedStudent);
      
      Get.back();
    } catch (e) {
      CustomSnackbar.showError(
        "Update Failed",
        "Could not save student details. Please try again."
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Student", style: TextStyle(color: AppColors.frenchBlue)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Student Name",
                  hintText: "Enter Student name",
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                value: _selectedBatchUid,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: "Batch",
                  suffixIcon: batchController.isAllLoading.value 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2,)) 
                    : null,  
                ),
                items: batchController.allBatches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch.uid,
                    child: Text(batch.name, overflow: TextOverflow.ellipsis,),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBatchUid = value;
                  });
                },
              )),
              const SizedBox(height: 16),

              Text("Classes Attended", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _classesPresentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Present"),
                      validator: (value) => (int.tryParse(value ?? '') == null) ? "Invalid" : null,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("/", style: TextStyle(fontSize: 24)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _totalClassesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Total"),
                      validator: (value) => (int.tryParse(value ?? '') == null) ? "Invalid" : null,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.frenchRed)),
        ),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.frenchBlue),
          child: const Text("Save", style: TextStyle(color: AppColors.cardLight)),
        )
      ],
    );
  }
}
