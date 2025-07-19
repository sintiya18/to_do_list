import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

import 'notification_service.dart';

class EditTugasScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTugasScreen({super.key, required this.task});

  @override
  State<EditTugasScreen> createState() => _EditTugasScreenState();
}

class _EditTugasScreenState extends State<EditTugasScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController judulController;
  late TextEditingController tanggalController;

  String status = 'belum_dikerjakan';
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();

    judulController =
        TextEditingController(text: widget.task['title']?.toString() ?? '');

    final dbDeadline = widget.task['deadline']?.toString();
    final parsedDeadline = (dbDeadline != null && dbDeadline.isNotEmpty)
        ? DateTime.tryParse(dbDeadline)?.toLocal()
        : null;

    selectedDateTime = parsedDeadline ?? DateTime.now();
    tanggalController =
        TextEditingController(text: _formatDateTime(selectedDateTime));

    final dbStatus = widget.task['status']?.toString();
    status = (dbStatus == 'sudah_dikerjakan' || dbStatus == 'belum_dikerjakan')
        ? dbStatus!
        : 'belum_dikerjakan';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          tanggalController.text = _formatDateTime(selectedDateTime);
        });
      }
    }
  }

  @override
  void dispose() {
    judulController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    try {
      await supabase.from('todos').update({
        'title': judulController.text,
        'deadline': selectedDateTime.toUtc().toIso8601String(),
        'status': status,
      }).eq('id', widget.task['id']);

      DateTime waktuNotif = selectedDateTime;
      if (waktuNotif.isBefore(DateTime.now().add(const Duration(seconds: 5)))) {
        waktuNotif = DateTime.now().add(const Duration(seconds: 10));
      }

      await NotificationService().scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Pengingat Tugas',
        body: 'Kerjakan: ${judulController.text}',
        scheduledDateTime: waktuNotif,
      );

      if (!mounted) return;

      await _showFlushbar(
        'Tugas berhasil diupdate',
        Colors.green.shade400,
        Icons.check_circle,
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showFlushbar(
        '❌ Gagal update tugas: $e',
        Colors.red.shade400,
        Icons.error,
      );
    }
  }

  Future<void> _showFlushbar(String message, Color color, IconData icon) {
    return Flushbar(
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(icon, color: Colors.white),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tugas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tanggalController,
                readOnly: true,
                onTap: _selectDateTime,
                decoration: const InputDecoration(
                  labelText: 'Tanggal & Jam',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(
                    value: 'belum_dikerjakan',
                    child: Text('Belum Dikerjakan'),
                  ),
                  DropdownMenuItem(
                    value: 'sudah_dikerjakan',
                    child: Text('Sudah Dikerjakan'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
