import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '_student_nav_tabs.dart';

class StudentAttendanceImportView extends StatelessWidget {
  const StudentAttendanceImportView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Student Attendance Import',
      body: Column(
        children: [
          const StudentNavTabs(
              activeRoute: AppRoutes.studentAttendanceImport),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Upload a CSV or Excel file to bulk-import student attendance records. '
                            'Download the sample template below to ensure correct formatting.',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF1E40AF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Upload card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(13)),
                          ),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.upload_file,
                                  size: 16, color: Color(0xFF4F46E5)),
                            ),
                            const SizedBox(width: 10),
                            Text('Import Attendance File',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ]),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Drop zone
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                      style: BorderStyle.solid,
                                      width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_upload_outlined,
                                        size: 40, color: Color(0xFF9CA3AF)),
                                    const SizedBox(height: 8),
                                    Text('Tap to select file',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF374151))),
                                    const SizedBox(height: 4),
                                    Text('CSV or Excel (.xlsx) supported',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF9CA3AF))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: Text('Choose File',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download_outlined,
                                    size: 18),
                                label: Text('Download Sample Template',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: const Color(0xFF4F46E5))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  side: const BorderSide(
                                      color: Color(0xFF4F46E5)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
