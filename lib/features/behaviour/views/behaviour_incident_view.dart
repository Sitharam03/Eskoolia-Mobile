import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/behaviour_incident_controller.dart';
import '../models/behaviour_models.dart';
import '_behaviour_nav_tabs.dart';
import '_behaviour_shared.dart';

class BehaviourIncidentView extends StatelessWidget {
  const BehaviourIncidentView({super.key});

  BehaviourIncidentController get _c =>
      Get.find<BehaviourIncidentController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Behaviour Records',
      body: Column(
        children: [
          const BehaviourNavTabs(activeRoute: AppRoutes.behaviourIncidents),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.incidents.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: _c.loadIncidents,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Create/Edit form ─────────────────────────────────
                      Obx(() => _c.showForm.value
                          ? _buildForm(context)
                          : _buildAddButton()),
                      const SizedBox(height: 20),
                      // ── Incidents list ────────────────────────────────────
                      bSectionHeader(
                        'Incident Types',
                        trailing: Obx(() => Text(
                              '${_c.incidents.length} incidents',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: kBehGray),
                            )),
                      ),
                      Obx(() {
                        if (_c.incidents.isEmpty) {
                          return bEmptyState(
                              'No incident types defined yet.\nTap + Add Incident to create one.',
                              icon: Icons.report_problem_outlined);
                        }
                        return Column(
                          children: _c.incidents
                              .map((inc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _IncidentCard(
                                      incident: inc,
                                      onEdit: () => _c.startEdit(inc),
                                      onDelete: () => bDeleteDialog(
                                        context,
                                        'Delete "${inc.title}"? This cannot be undone.',
                                        () => _c.deleteIncident(inc.id),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() => GestureDetector(
        onTap: _c.startCreate,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: kBehPrimary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: kBehPrimary.withOpacity(0.3),
                style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: kBehPrimary, size: 20),
              const SizedBox(width: 8),
              Text('Add Incident Type',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kBehPrimary,
                  )),
            ],
          ),
        ),
      );

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: bCardDecoration(borderColor: kBehPrimary.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kBehPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.report_problem_outlined,
                    color: kBehPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Obx(() => Text(
                    _c.isEditing ? 'Edit Incident' : 'New Incident Type',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  )),
              const Spacer(),
              GestureDetector(
                onTap: _c.cancelForm,
                child: const Icon(Icons.close, size: 20, color: kBehGray),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          bLabel('Incident Title *'),
          bTextField(_c.titleCtrl, 'e.g. Late Arrival, Good Behavior'),
          const SizedBox(height: 12),

          // Point row with negative toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bLabel('Point Value *'),
                    bTextField(
                      _c.pointCtrl,
                      '0',
                      keyboardType: TextInputType.number,
                      prefixText: '± ',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bLabel('Negative?'),
                  Obx(() => GestureDetector(
                        onTap: () =>
                            _c.isNegative.value = !_c.isNegative.value,
                        child: Container(
                          width: 56,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _c.isNegative.value
                                ? kBehRed.withOpacity(0.1)
                                : kBehGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _c.isNegative.value
                                  ? kBehRed
                                  : kBehGreen,
                            ),
                          ),
                          child: Icon(
                            _c.isNegative.value
                                ? Icons.trending_down
                                : Icons.trending_up,
                            color: _c.isNegative.value
                                ? kBehRed
                                : kBehGreen,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          bLabel('Description'),
          bTextField(_c.descCtrl, 'Optional description',
              maxLines: 2),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(() => bPrimaryBtn(
                      label: _c.isEditing ? 'Update' : 'Save Incident',
                      loading: _c.isLoading.value,
                      onPressed: _c.saveIncident,
                      icon: Icons.save_outlined,
                    )),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _c.cancelForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Cancel', style: GoogleFonts.inter()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Incident card ──────────────────────────────────────────────────────────────

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IncidentCard({
    required this.incident,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: bCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: incident.point < 0 ? kBehRed : kBehGreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incident.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          if (incident.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              incident.description,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: kBehGray),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          bPointBadge(incident.point),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        bActionBtn(
                            Icons.edit_outlined, kBehPrimary, onEdit),
                        const SizedBox(height: 6),
                        bActionBtn(
                            Icons.delete_outline, kBehRed, onDelete),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
