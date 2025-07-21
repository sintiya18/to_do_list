import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

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
      initialDate: selectedDateTime.isBefore(DateTime.now())
          ? DateTime.now()
          : selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        final chosen = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (chosen.isBefore(DateTime.now())) {
          _showFlushbar(
            'Waktu sudah lewat. Pilih waktu yang valid!',
            Colors.orange,
            Icons.warning,
          );
          return;
        }

        setState(() {
          selectedDateTime = chosen;
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
    if (selectedDateTime.isBefore(DateTime.now())) {
      _showFlushbar(
        'Waktu deadline sudah lewat. Pilih waktu yang valid!',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    try {
      await supabase.from('todos').update({
        'title': judulController.text,
        'deadline': selectedDateTime.toUtc().toIso8601String(),
        'status': status,
      }).eq('id', widget.task['id']);

      if (!mounted) return;

      await _showFlushbar(
        'Tugas berhasil diupdate',
        Colors.green.shade600,
        Icons.check_circle,
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showFlushbar(
        'Gagal update tugas: $e',
        Colors.red.shade600,
        Icons.error,
      );
    }
  }

  Future<void> _showFlushbar(String message, Color color, IconData icon) {
    return Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadows: [
        const BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      padding: const EdgeInsets.all(16),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa0f1f1), Color(0xFFc2fcfc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Edit Tugas',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: judulController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.title),
                        labelText: 'Judul',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      onTap: _selectDateTime,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today),
                        labelText: 'Tanggal & Jam',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
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
                        prefixIcon: Icon(Icons.assignment_turned_in),
                        labelText: 'Status',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text(
                              'Batal',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size.fromHeight(50),
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
