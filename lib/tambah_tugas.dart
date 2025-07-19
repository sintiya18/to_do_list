import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

import 'notification_service.dart';

class TambahTugas extends StatefulWidget {
  const TambahTugas({super.key});

  @override
  State<TambahTugas> createState() => _TambahTugasState();
}

class _TambahTugasState extends State<TambahTugas> {
  final supabase = Supabase.instance.client;

  final TextEditingController judulController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  DateTime selectedDateTime = DateTime.now();

  @override
  void dispose() {
    judulController.dispose();
    tanggalController.dispose();
    super.dispose();
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

  Future<void> _saveTask() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _showFlushbar('❌ User belum login', color: Colors.red);
      return;
    }

    try {
      await supabase.from('todos').insert({
        'user_id': userId,
        'title': judulController.text,
        'deadline': selectedDateTime.toUtc().toIso8601String(),
        'status': 'belum_dikerjakan',
      });

      await NotificationService().scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Pengingat Tugas',
        body: 'Kerjakan: ${judulController.text}',
        scheduledDateTime: selectedDateTime,
      );

      if (!mounted) return;
      _showFlushbar('Tugas berhasil ditambahkan', color: Colors.green, thenPop: true);
    } catch (e) {
      _showFlushbar('Gagal tambah tugas: $e', color: Colors.red);
    }
  }

  void _showFlushbar(String message, {Color color = Colors.green, bool thenPop = false}) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        color == Colors.green ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
    ).show(context).then((_) {
      if (thenPop && mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2FEFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              shadowColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.playlist_add_check,
                            color: Color.fromARGB(255, 0, 0, 0), size: 32),
                        SizedBox(width: 8),
                        Text(
                          'Tambah Tugas',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      child: TextField(
                        controller: judulController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.title),
                          labelText: 'Judul',
                          labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      child: TextField(
                        controller: tanggalController,
                        readOnly: true,
                        onTap: _selectDateTime,
                        decoration: InputDecoration(
                          labelText: 'Tanggal & Jam',
                          prefixIcon: Icon(Icons.calendar_today),
                          labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: const Icon(Icons.calendar_today,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveTask,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 7, 185, 255),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text(
                              'Batal',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
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
        ),
      ),
    );
  }
}
