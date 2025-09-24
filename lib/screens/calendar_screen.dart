import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'package:open_file/open_file.dart';
import '../home_screen.dart';
import 'package:camera/camera.dart';

class CalendarScreen extends StatefulWidget {
  final CameraDescription camera;
  final int? projectId;

  const CalendarScreen({Key? key, required this.camera, this.projectId}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseService _dbService = DatabaseService();
  final PdfService _pdfService = PdfService();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  late final ValueNotifier<List<Report>> _selectedReports;
  Map<DateTime, List<Report>> _reportsByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedReports = ValueNotifier(_getReportsForDay(_selectedDay!));
    _loadAllReports();
  }

  void _loadAllReports() async {
    final allReports = await _dbService.getReports(projectId: widget.projectId);
    final Map<DateTime, List<Report>> reportsByDate = {};
    for (var report in allReports) {
      final date = DateTime.utc(report.date.year, report.date.month, report.date.day);
      if (reportsByDate[date] == null) {
        reportsByDate[date] = [];
      }
      reportsByDate[date]!.add(report);
    }
    setState(() {
      _reportsByDate = reportsByDate;
    });
    _selectedReports.value = _getReportsForDay(_selectedDay!);
  }

  List<Report> _getReportsForDay(DateTime day) {
    return _reportsByDate[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedReports.value = _getReportsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar View'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              if (_selectedDay != null) {
                _generatePdfForSelectedDay();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Report>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getReportsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(date, events),
                  );
                }
                return null;
              },
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Report>>(
              valueListenable: _selectedReports,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text(value[index].issue),
                        subtitle: Text(value[index].location),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedDay != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  camera: widget.camera,
                  selectedDate: _selectedDay,
                ),
              ),
            );
          }
        },
        label: Text('View Day'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Report> reports) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${reports.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdfForSelectedDay() async {
    final reports = _getReportsForDay(_selectedDay!);
    if (reports.isNotEmpty) {
      final pdfFile = await _pdfService.generatePdf(reports, "Daily Report");
      await OpenFile.open(pdfFile.path);
    }
  }
}
