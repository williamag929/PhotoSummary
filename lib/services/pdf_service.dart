
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../models/report.dart';
import 'dart:convert';

class PdfService {
  Future<File> generatePdf(List<Report> reports, String projectName) async {
    final pdf = pw.Document();
    final String date = DateFormat.yMMMMd().format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          return pw.Header(
            level: 0,
            child: pw.Text('BuildRight Construction - Daily Site Report - $projectName - $date'),
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
              List<String> imagePaths = [];
              if (report.photoPath != null) {
                if (report.photoPath!.startsWith('[')) {
                  final List<dynamic> decoded = jsonDecode(report.photoPath!);
                  imagePaths = decoded.map((e) => e.toString()).toList();
                } else {
                  imagePaths.add(report.photoPath!);
                }
              }
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...imagePaths.map((path) {
                    try {
                      final file = File(path);
                      if (file.existsSync()) {
                        return pw.Image(pw.MemoryImage(file.readAsBytesSync()));
                      }
                    } catch (e) {
                      // Log error or handle missing image
                    }
                    return pw.Container(); // Return an empty container if image fails to load
                  }),
                  pw.Text('Timestamp: ${DateFormat.yMd().add_jm().format(report.date)}'),
                  pw.Text('Location: ${report.location}'),
                  pw.Text('Details: ${report.details}'),
                  pw.Text('Section: ${report.section}'),
                  pw.Text('Issue: ${report.issue}'),
                  pw.Divider(),
                ],
              );
            }),
          ];
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final safeProjectName = projectName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final baseFileName = "${output.path}/report_${safeProjectName}_$formattedDate";
    
    String finalPath = "$baseFileName.pdf";
    int version = 1;
    while (await File(finalPath).exists()) {
      finalPath = "${baseFileName}_v${version++}.pdf";
    }

    final file = File(finalPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
