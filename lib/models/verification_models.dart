class HuidResult {
  final bool isValid;
  final String status;
  final String message;
  final String? huid;
  final String? jewellerName;
  final String? registrationNo;
  final String? ahcCenter;
  final String? purity;
  final String? articleType;
  final String? grossWeight;
  final String? hallmarkingDate;

  const HuidResult({
    required this.isValid,
    required this.status,
    required this.message,
    this.huid,
    this.jewellerName,
    this.registrationNo,
    this.ahcCenter,
    this.purity,
    this.articleType,
    this.grossWeight,
    this.hallmarkingDate,
  });

  factory HuidResult.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString();
    final isValidFlag = json['is_valid'] == true || json['isValid'] == true;
    final isValid = isValidFlag || (statusStr.isNotEmpty && statusStr != 'NOT_FOUND');
    final message = (json['message'] ?? (isValid ? 'HUID verified successfully' : 'HUID could not be verified.')).toString();

    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : <String, dynamic>{};

    final isNotFound = statusStr == 'NOT_FOUND' || data['status'] == 'NOT_FOUND' || !isValid;

    return HuidResult(
      isValid: !isNotFound,
      status: isNotFound ? 'NOT_FOUND' : (statusStr.isNotEmpty ? statusStr : (data['status'] ?? 'ACTIVE').toString()),
      message: message,
      huid: (data['huid'] ?? json['huid'] ?? '').toString(),
      jewellerName: (data['jeweller_name'] ?? data['jewellerName'] ?? '').toString(),
      registrationNo: (data['registration_no'] ?? data['registrationNo'] ?? '').toString(),
      ahcCenter: (data['ahc_center'] ?? data['ahcCenter'] ?? '').toString(),
      purity: (data['purity'] ?? '').toString(),
      articleType: (data['article_type'] ?? data['articleType'] ?? '').toString(),
      grossWeight: (data['gross_weight'] ?? data['grossWeight'] ?? '').toString(),
      hallmarkingDate: (data['hallmarking_date'] ?? data['hallmarkingDate'] ?? '').toString(),
    );
  }
}

class LicenseResult {
  final bool isValid;
  final String status;
  final String message;
  final String? licenseNumber;
  final String? manufacturerName;
  final String? factoryAddress;
  final String? isStandard;
  final String? productName;
  final String? brand;
  final String? validTill;

  const LicenseResult({
    required this.isValid,
    required this.status,
    required this.message,
    this.licenseNumber,
    this.manufacturerName,
    this.factoryAddress,
    this.isStandard,
    this.productName,
    this.brand,
    this.validTill,
  });

  factory LicenseResult.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString();
    final isValidFlag = json['is_valid'] == true || json['isValid'] == true;
    final isValid = isValidFlag || (statusStr.isNotEmpty && statusStr != 'NOT_FOUND');
    final message = (json['message'] ?? (isValid ? 'BIS License verified successfully' : 'License is not active or registered.')).toString();

    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : <String, dynamic>{};

    final isNotFound = statusStr == 'NOT_FOUND' || data['status'] == 'NOT_FOUND' || !isValid;

    return LicenseResult(
      isValid: !isNotFound,
      status: isNotFound ? 'NOT_FOUND' : (statusStr.isNotEmpty ? statusStr : (data['status'] ?? 'ACTIVE').toString()),
      message: message,
      licenseNumber: (data['license_number'] ?? data['licenseNumber'] ?? json['license_number'] ?? '').toString(),
      manufacturerName: (data['manufacturer_name'] ?? data['manufacturerName'] ?? '').toString(),
      factoryAddress: (data['factory_address'] ?? data['factoryAddress'] ?? '').toString(),
      isStandard: (data['is_standard'] ?? data['isStandard'] ?? '').toString(),
      productName: (data['product_name'] ?? data['productName'] ?? '').toString(),
      brand: (data['brand'] ?? '').toString(),
      validTill: (data['valid_till'] ?? data['validTill'] ?? '').toString(),
    );
  }
}
