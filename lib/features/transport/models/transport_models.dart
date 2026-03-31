// ── Transport Route ───────────────────────────────────────────────────────────

class TransportRoute {
  final int id;
  final String title;
  final String fare;
  final bool activeStatus;

  const TransportRoute({
    required this.id,
    required this.title,
    required this.fare,
    required this.activeStatus,
  });

  factory TransportRoute.fromJson(Map<String, dynamic> j) => TransportRoute(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        fare: (j['fare'] ?? '0.00').toString(),
        activeStatus: j['active_status'] == true,
      );
}

// ── Transport Driver (Staff reference) ────────────────────────────────────────

class TransportDriver {
  final int id;
  final String staffNo;
  final String firstName;
  final String lastName;

  const TransportDriver({
    required this.id,
    required this.staffNo,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayLabel =>
      '${fullName.isNotEmpty ? fullName : "Staff"} (${staffNo.isNotEmpty ? staffNo : "-"})';

  factory TransportDriver.fromJson(Map<String, dynamic> j) => TransportDriver(
        id: j['id'] as int,
        staffNo: j['staff_no'] as String? ?? '',
        firstName: j['first_name'] as String? ?? '',
        lastName: j['last_name'] as String? ?? '',
      );
}

// ── Vehicle ───────────────────────────────────────────────────────────────────

class Vehicle {
  final int id;
  final String vehicleNo;
  final String vehicleModel;
  final int? madeYear;
  final String note;
  final int? driverId;
  final String driverName;
  final bool activeStatus;

  const Vehicle({
    required this.id,
    required this.vehicleNo,
    required this.vehicleModel,
    this.madeYear,
    required this.note,
    this.driverId,
    required this.driverName,
    required this.activeStatus,
  });

  factory Vehicle.fromJson(Map<String, dynamic> j) {
    int? driverId;
    String driverName = '';
    final driverData = j['driver'];
    if (driverData is int) {
      driverId = driverData;
    } else if (driverData is Map<String, dynamic>) {
      driverId = driverData['id'] as int?;
      final fn = driverData['first_name'] as String? ?? '';
      final ln = driverData['last_name'] as String? ?? '';
      driverName = '$fn $ln'.trim();
    }
    if (driverName.isEmpty && j['driver_name'] is String) {
      driverName = j['driver_name'] as String;
    }
    return Vehicle(
      id: j['id'] as int,
      vehicleNo: j['vehicle_no'] as String? ?? '',
      vehicleModel: j['vehicle_model'] as String? ?? '',
      madeYear: j['made_year'] as int?,
      note: j['note'] as String? ?? '',
      driverId: driverId,
      driverName: driverName,
      activeStatus: j['active_status'] == true,
    );
  }
}

// ── Assign Vehicle ────────────────────────────────────────────────────────────

class AssignVehicle {
  final int id;
  final int vehicleId;
  final String vehicleNo;
  final int routeId;
  final String routeTitle;
  final bool activeStatus;

  const AssignVehicle({
    required this.id,
    required this.vehicleId,
    required this.vehicleNo,
    required this.routeId,
    required this.routeTitle,
    required this.activeStatus,
  });

  factory AssignVehicle.fromJson(Map<String, dynamic> j) {
    int vehicleId = 0;
    String vehicleNo = '';
    final vd = j['vehicle'];
    if (vd is int) {
      vehicleId = vd;
    } else if (vd is Map<String, dynamic>) {
      vehicleId = vd['id'] as int? ?? 0;
      vehicleNo = vd['vehicle_no'] as String? ?? '';
    }
    if (vehicleNo.isEmpty && j['vehicle_no'] is String) {
      vehicleNo = j['vehicle_no'] as String;
    }

    int routeId = 0;
    String routeTitle = '';
    final rd = j['route'];
    if (rd is int) {
      routeId = rd;
    } else if (rd is Map<String, dynamic>) {
      routeId = rd['id'] as int? ?? 0;
      routeTitle = rd['title'] as String? ?? '';
    }
    if (routeTitle.isEmpty && j['route_title'] is String) {
      routeTitle = j['route_title'] as String;
    }

    return AssignVehicle(
      id: j['id'] as int,
      vehicleId: vehicleId,
      vehicleNo: vehicleNo,
      routeId: routeId,
      routeTitle: routeTitle,
      activeStatus: j['active_status'] == true,
    );
  }
}

// ── Student Transport ─────────────────────────────────────────────────────────

class StudentTransport {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String transportRouteTitle;
  final String vehicleNo;
  final bool isActive;

  const StudentTransport({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.transportRouteTitle,
    required this.vehicleNo,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory StudentTransport.fromJson(Map<String, dynamic> j) => StudentTransport(
        id: j['id'] as int,
        admissionNo: j['admission_no'] as String? ?? '',
        firstName: j['first_name'] as String? ?? '',
        lastName: j['last_name'] as String? ?? '',
        transportRouteTitle: j['transport_route_title'] as String? ?? '',
        vehicleNo: j['vehicle_no'] as String? ?? '',
        isActive: j['is_active'] == true,
      );
}
