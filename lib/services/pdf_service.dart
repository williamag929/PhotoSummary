import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/report.dart';

class PDFService {
  Future<File?> generatePDF(List<Report> reports) async {
    final pdf = pw.Document();
    for (var report in reports) {
      final image = pw.MemoryImage(File(report.photoPath).readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build:
              (pw.Context context) => pw.Column(
                children: [
                  pw.Image(image, width: 512, height: 512),
                  pw.Text(
                    'Note: ${report.note}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  if (report.aiAnalysis != null)
                    pw.Text(
                      'AI Analysis: ${report.aiAnalysis}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.blue),
                    ),
                ],
              ),
        ),
      );
    }
    final output = File(
      '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await output.writeAsBytes(await pdf.save());
    return output;
  }
}
