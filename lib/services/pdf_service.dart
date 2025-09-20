import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/report.dart';

class PdfService {
  Future<File> generateReport(List<Report> reports) async {
    final pdf = pw.Document();
    final String date = DateFormat.yMMMMd().format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          return pw.Header(
            level: 0,
            child: pw.Text('BuildRight Construction - Daily Site Report - Project 1042 - $date'),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Header(level: 1, text: 'Summary'),
            // In a real app, you'd generate this summary dynamically
            pw.Bullet(text: 'Electrical: 1 Non-Conformance Issue (Conduit Spacing) assigned to Sparks Electrical.'),
            pw.Bullet(text: 'Plumbing: 2 Progress Photos (Riser installation complete).'),
            pw.Bullet(text: 'Safety: 1 Observation (Water on floor near stairwell) - Marked as resolved.'),
            pw.Header(level: 1, text: 'Detailed Entries'),
            ...reports.map((report) {
              final image = report.photoPath != null ? pw.MemoryImage(File(report.photoPath!).readAsBytesSync()) : null;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (image != null) pw.Image(image),
                  pw.Text('Timestamp: ${DateFormat.yMd().add_jm().format(report.date)}'),
                  pw.Text('Location: ${report.location}'),
                  pw.Text('Details: ${report.details}'),
                  pw.Text('Action Required: ${report.actionRequired}'),
                  pw.Text('Assigned To: ${report.assignedTo}'),
                  pw.Divider(),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/daily_report_$date.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
