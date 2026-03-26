import '../../../core/network/api_client.dart';
import '../models/role_model.dart';
import '../models/permission_model.dart';
import '../models/login_access_model.dart';
import '../models/due_fees_model.dart';

class AccessControlRepository {
  // ---------------------------------------------------------------------------
  // ROLES
  // ---------------------------------------------------------------------------
  Future<List<RoleItem>> getRoles() async {
    final response = await ApiClient.dio.get('/api/v1/access-control/roles/');
    return RoleApiResult.fromJson(response.data).results;
  }

  Future<void> createRole(String name) async {
    await ApiClient.dio.post(
      '/api/v1/access-control/roles/',
      data: {'name': name},
    );
  }

  Future<void> updateRole(int id, String name) async {
    await ApiClient.dio.put(
      '/api/v1/access-control/roles/$id/',
      data: {'name': name},
    );
  }

  Future<void> deleteRole(int id) async {
    await ApiClient.dio.delete('/api/v1/access-control/roles/$id/');
  }

  // ---------------------------------------------------------------------------
  // PERMISSIONS TREE
  // ---------------------------------------------------------------------------
  Future<PermissionTreeResponse> getPermissionTree(int roleId) async {
    final response = await ApiClient.dio.get(
      '/api/v1/access-control/roles/permission-tree/',
      queryParameters: {'role': roleId},
    );
    return PermissionTreeResponse.fromJson(response.data);
  }

  Future<void> assignPermissions(int roleId, List<int> permissionIds) async {
    await ApiClient.dio.post(
      '/api/v1/access-control/roles/$roleId/assign-permissions/',
      data: {'permission_ids': permissionIds},
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIN PERMISSIONS
  // ---------------------------------------------------------------------------
  Future<CriteriaResponse> getLoginCriteria() async {
    final response = await ApiClient.dio.get('/api/v1/access-control/login-access-control/');
    return CriteriaResponse.fromJson(response.data);
  }

  Future<List<LoginUserRow>> getLoginUsers({
    required String roleId,
    String? classId,
    String? sectionId,
    String? name,
    String? admissionNo,
    String? rollNo,
  }) async {
    final queryParams = <String, dynamic>{'role': roleId};
    if (classId != null && classId.isNotEmpty) queryParams['class'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) queryParams['section'] = sectionId;
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (admissionNo != null && admissionNo.isNotEmpty) queryParams['admission_no'] = admissionNo;
    if (rollNo != null && rollNo.isNotEmpty) queryParams['roll_no'] = rollNo;

    final response = await ApiClient.dio.get(
      '/api/v1/access-control/login-access-control/users/',
      queryParameters: queryParams,
    );
    final usersList = response.data['users'] as List? ?? [];
    return usersList.map((e) => LoginUserRow.fromJson(e)).toList();
  }

  Future<void> toggleLoginPermission(int userId, bool status) async {
    await ApiClient.dio.post(
      '/api/v1/access-control/login-access-control/toggle/',
      data: {'user_id': userId, 'status': status},
    );
  }

  Future<void> resetPassword(int userId, String password) async {
    await ApiClient.dio.post(
      '/api/v1/access-control/login-access-control/reset-password/',
      data: {'user_id': userId, 'password': password},
    );
  }

  // ---------------------------------------------------------------------------
  // DUE FEES LOGIN PERMISSIONS
  // ---------------------------------------------------------------------------
  Future<DueCriteriaResponse> getDueFeesCriteria() async {
    final response = await ApiClient.dio.get('/api/v1/access-control/due-fees-login-permission/');
    return DueCriteriaResponse.fromJson(response.data);
  }

  Future<List<DueUserRow>> getDueFeesUsers({
    String? classId,
    String? sectionId,
    String? name,
    String? admissionNo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null && classId.isNotEmpty) queryParams['class'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) queryParams['section'] = sectionId;
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (admissionNo != null && admissionNo.isNotEmpty) queryParams['admission_no'] = admissionNo;

    final response = await ApiClient.dio.get(
      '/api/v1/access-control/due-fees-login-permission/users/',
      queryParameters: queryParams,
    );
    final usersList = response.data['users'] as List? ?? [];
    return usersList.map((e) => DueUserRow.fromJson(e)).toList();
  }

  Future<void> toggleDueFeesPermission(int userId, bool status) async {
    await ApiClient.dio.post(
      '/api/v1/access-control/due-fees-login-permission/toggle/',
      data: {'user_id': userId, 'status': status},
    );
  }
}
