enum ApprovalActionType {
  changePin,
  addStaff,
  deleteStaff,
  updateSalary,
  updatePrice,
  updateSeniorityShare;

  String get displayName {
    switch (this) {
      case ApprovalActionType.changePin:
        return 'PIN Code Change';
      case ApprovalActionType.addStaff:
        return 'Add Staff Member';
      case ApprovalActionType.deleteStaff:
        return 'Delete Staff Member';
      case ApprovalActionType.updateSalary:
        return 'Salary / Commission Change';
      case ApprovalActionType.updatePrice:
        return 'Service Price Update';
      case ApprovalActionType.updateSeniorityShare:
        return 'Seniority Pool Distribution';
    }
  }
}

class PendingApprovalRequest {
  final String id;
  final ApprovalActionType actionType;
  final String title;
  final String description;
  final Map<String, dynamic> payload;
  final DateTime requestedAt;
  final String requestedBy;

  const PendingApprovalRequest({
    required this.id,
    required this.actionType,
    required this.title,
    required this.description,
    required this.payload,
    required this.requestedAt,
    this.requestedBy = 'Secondary Admin',
  });
}
