import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/schedule_service.dart';

// Professional Robotics Color Palette
const Color _cardBg = Color(0xFF131820);
const Color _accentPrimary = Color(0xFF00D9FF);
const Color _successColor = Color(0xFF00FF88);
const Color _errorColor = Color(0xFFFF3333);
const Color _textPrimary = Color(0xFFE8E8E8);
const Color _textSecondary = Color(0xFF8A8A8A);
const Color _backgroundDark = Color(0xFF0A0E1A);

class AdminScheduleCreationDialog extends StatefulWidget {
  const AdminScheduleCreationDialog({super.key});

  @override
  State<AdminScheduleCreationDialog> createState() =>
      _AdminScheduleCreationDialogState();
}

class _AdminScheduleCreationDialogState
    extends State<AdminScheduleCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int? _estimatedDuration;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _accentPrimary.withOpacity(0.2), width: 1),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Cleaning Schedule',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: _textSecondary),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Schedule Title
                _buildFormField(
                  label: 'Schedule Title *',
                  controller: _titleController,
                  hint: 'e.g., Living Room Daily Clean',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a schedule title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                _buildFormField(
                  label: 'Description *',
                  controller: _descriptionController,
                  hint: 'Describe what cleaning tasks should be performed',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date and Time Row
                Row(
                  children: [
                    Expanded(child: _buildDateField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField()),
                  ],
                ),
                const SizedBox(height: 16),

                // Duration
                _buildDurationField(),
                const SizedBox(height: 16),

                // Notes
                _buildFormField(
                  label: 'Notes',
                  controller: _notesController,
                  hint: 'Additional notes or special instructions',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: _textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isCreating ? null : _createSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isCreating
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              'Create Schedule',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
            filled: true,
            fillColor: _backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _accentPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errorColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Date *',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _textSecondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: GoogleFonts.poppins(fontSize: 14, color: _textPrimary),
                ),
                Icon(Icons.calendar_today, color: _accentPrimary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Time *',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _textSecondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: GoogleFonts.poppins(fontSize: 14, color: _textPrimary),
                ),
                Icon(Icons.access_time, color: _accentPrimary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (minutes)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g., 30',
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
            filled: true,
            fillColor: _backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _accentPrimary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _estimatedDuration = int.tryParse(value);
            } else {
              _estimatedDuration = null;
            }
          },
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentPrimary,
              onPrimary: Colors.black,
              surface: _cardBg,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentPrimary,
              onPrimary: Colors.black,
              surface: _cardBg,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Combine date and time
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final scheduleId = await ScheduleService.createSchedule(
        adminId: user.uid,
        adminEmail: user.email ?? 'unknown@email.com',
        adminName: user.displayName ?? 'Admin User',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledDate: _selectedDate,
        scheduledTime: scheduledDateTime,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        estimatedDuration: _estimatedDuration,
      );

      if (scheduleId != null) {
        _showSuccessSnackBar('Schedule created successfully!');
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('Failed to create schedule. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating schedule: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
