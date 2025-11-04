import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class TeacherTakeAttendanceScreen extends StatefulWidget {
  const TeacherTakeAttendanceScreen({super.key});

  @override
  State<TeacherTakeAttendanceScreen> createState() =>
      _TeacherTakeAttendanceScreenState();
}

class _TeacherTakeAttendanceScreenState
    extends State<TeacherTakeAttendanceScreen> {
  // Sample dates - in real app, this would come from API/state management
  DateTime selectedDate = DateTime(2024, 7, 27); // Tue 27 (default selected)
  DateTime currentMonth = DateTime(2024, 7);

  // Sample students data
  final List<StudentAttendance> students = List.generate(
    30,
    (index) => StudentAttendance(
      id: '${index + 1}',
      name: index == 5 ? 'Angelina Jolie Shrestha' : 'John Doe',
      rollNumber: index + 1,
      isPresent: index != 2 && index != 8 && index != 15 && index != 20 && index != 25,
      avatar: index == 5 ? 'female' : 'male',
    ),
  );

  // Date status map - determines if date has green/red mark or is missed
  final Map<int, DateStatus> dateStatusMap = {
    25: DateStatus.present, // Sun 25 - green
    26: DateStatus.missed, // Mon 26 - red (missed)
    27: DateStatus.present, // Tue 27 - green
    28: DateStatus.present, // Wed 28 - green
    29: DateStatus.none, // Thu 29 - no mark
    30: DateStatus.none, // Fri 30 - no mark
    31: DateStatus.none, // Sat 31 - no mark (red text)
  };

  String _attendanceView = 'calendar'; // 'calendar', 'attendanceList', 'missedMessage', 'requestSent'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_attendanceView == 'calendar') {
              Navigator.of(context).pop();
            } else {
              setState(() {
                _attendanceView = 'calendar';
              });
            }
          },
        ),
        title: Text(
          'Take Attendance',
          style: TextStyles.h6,
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDateNavigation(),
            _buildCalendarRow(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              setState(() {
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month - 1,
                );
              });
            },
          ),
          Row(
            children: [
              Text(
                'Ashar 25 - Sharwan 31',
                style: TextStyles.bodyMedium,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () {
              setState(() {
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarRow() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dates = [25, 26, 27, 28, 29, 30, 31];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = days[index];
          final date = dates[index];
          final isSelected = selectedDate.day == date;
          final status = dateStatusMap[date] ?? DateStatus.none;
          final isSaturday = index == 6;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedDate = DateTime(selectedDate.year, selectedDate.month, date);
                  
                  if (status == DateStatus.present) {
                    // Green mark clicked - show attendance list
                    _attendanceView = 'attendanceList';
                  } else if (status == DateStatus.missed) {
                    // Red mark clicked - show missed message
                    _attendanceView = 'missedMessage';
                  } else {
                    // No mark - reset to calendar view
                    _attendanceView = 'calendar';
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.attendanceHighlight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.attendanceHighlight,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day,
                      style: TextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.toString(),
                      style: TextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : isSaturday
                                ? AppColors.error
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (status == DateStatus.present)
                      Container(
                        width: 30,
                        height: 2,
                        color: AppColors.attendancePresent,
                      )
                    else if (status == DateStatus.missed)
                      Container(
                        width: 30,
                        height: 2,
                        color: AppColors.attendanceAbsent,
                      )
                    else
                      const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_attendanceView) {
      case 'attendanceList':
        return _buildAttendanceListView();
      case 'missedMessage':
        return _buildMissedMessageView();
      case 'requestSent':
        return _buildRequestSentView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAttendanceListView() {
    final presentCount = students.where((s) => s.isPresent).length;
    final absentCount = students.length - presentCount;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students',
                style: TextStyles.h6,
              ),
              Text(
                'Status',
                style: TextStyles.h6,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Student List
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentListItem(student);
            },
          ),
        ),
        // Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: AppColors.attendancePresent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'P Present - $presentCount',
                    style: TextStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: AppColors.attendanceAbsent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'A Absent - $absentCount',
                    style: TextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Request for Edit Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showRequestAdminModal();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.attendanceHighlight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Request for Edit',
                style: TextStyles.buttonMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentListItem(StudentAttendance student) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surface,
            child: Icon(
              student.avatar == 'female' ? Icons.person : Icons.person_outline,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          // Name and Roll Number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Roll No: ${student.rollNumber}',
                  style: TextStyles.bodySmall,
                ),
              ],
            ),
          ),
          // P/A Buttons
          Row(
            children: [
              _buildAttendanceButton(
                label: 'P',
                isSelected: student.isPresent,
                isPresent: true,
                onTap: () {
                  setState(() {
                    student.isPresent = true;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                label: 'A',
                isSelected: !student.isPresent,
                isPresent: false,
                onTap: () {
                  setState(() {
                    student.isPresent = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton({
    required String label,
    required bool isSelected,
    required bool isPresent,
    required VoidCallback onTap,
  }) {
    final color = isPresent
        ? AppColors.attendancePresent
        : AppColors.attendanceAbsent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: color,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissedMessageView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You missed marking attendance for 2082/03/26.',
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please send a request to the admin to open it for you.',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showRequestAdminModal(isMissed: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.attendanceHighlight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Request Admin',
                  style: TextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Request sent to admin. You\'ll be notified once approved.',
          style: TextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showRequestAdminModal({bool isMissed = false}) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        final reasonController = TextEditingController();
        return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Admin',
                style: TextStyles.h5,
              ),
              const SizedBox(height: 16),
              Text(
                isMissed ? 'Tell us why you missed it' : 'Tell us why you want to edit',
                style: TextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter Your Reason',
                  hintStyle: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.attendanceHighlight,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _attendanceView = 'requestSent';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.attendanceHighlight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit Request',
                    style: TextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.attendanceCancelButton,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyles.buttonMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}

class StudentAttendance {
  final String id;
  final String name;
  final int rollNumber;
  bool isPresent;
  final String avatar;

  StudentAttendance({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.isPresent,
    required this.avatar,
  });
}

enum DateStatus {
  none,
  present, // Green mark
  missed, // Red mark
}

