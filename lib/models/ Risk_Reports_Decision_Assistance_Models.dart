```text
lib/models/risk/
    risk_models.dart

lib/models/reports/
    community_report_models.dart

lib/models/decision/
    decision_models.dart

lib/models/assistance/
    assistance_models.dart
```

```dart
// ============================================================
// RISK ENUMS
// ============================================================

enum Hazard {
  flood,
  earthquake,
}

enum RiskLevel {
  low,
  moderate,
  high,
  critical,
  unknown,
}

// ============================================================
// FLOOD RISK INPUT
// POST /risk/flood
// ============================================================

class FloodRiskInput {
  final String zoneId;
  final double rainfall1hMm;
  final double rainfall24hMm;
  final double? previousRainfall24hMm;
  final int dataAgeMinutes;

  FloodRiskInput({
    required this.zoneId,
    required this.rainfall1hMm,
    required this.rainfall24hMm,
    this.previousRainfall24hMm,
    this.dataAgeMinutes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'rainfall_1h_mm': rainfall1hMm,
      'rainfall_24h_mm': rainfall24hMm,
      'previous_rainfall_24h_mm':
          previousRainfall24hMm,
      'data_age_minutes': dataAgeMinutes,
    };
  }
}

// ============================================================
// EARTHQUAKE RISK INPUT
// ============================================================

class EarthquakeRiskInput {
  final String zoneId;
  final double magnitude;
  final double depthKm;
  final double distanceKm;
  final int dataAgeMinutes;
  final bool sourceVerified;

  EarthquakeRiskInput({
    required this.zoneId,
    required this.magnitude,
    required this.depthKm,
    required this.distanceKm,
    this.dataAgeMinutes = 0,
    this.sourceVerified = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'magnitude': magnitude,
      'depth_km': depthKm,
      'distance_km': distanceKm,
      'data_age_minutes': dataAgeMinutes,
      'source_verified': sourceVerified,
    };
  }
}

// ============================================================
// RISK ASSESSMENT
// ============================================================

class RiskAssessment {
  final Hazard hazard;
  final String zoneId;
  final int riskScore;
  final RiskLevel riskLevel;
  final double confidence;
  final List<String> reasons;
  final DateTime evaluatedAt;

  RiskAssessment({
    required this.hazard,
    required this.zoneId,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.reasons,
    required this.evaluatedAt,
  });

  factory RiskAssessment.fromJson(
    Map<String, dynamic> json,
  ) {
    return RiskAssessment(
      hazard: Hazard.values.firstWhere(
        (e) => e.name == json['hazard'],
      ),
      zoneId: json['zone_id'] ?? '',
      riskScore: json['risk_score'] ?? 0,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['risk_level'],
        orElse: () => RiskLevel.unknown,
      ),
      confidence:
          (json['confidence'] ?? 0).toDouble(),
      reasons:
          List<String>.from(json['reasons'] ?? []),
      evaluatedAt:
          DateTime.parse(json['evaluated_at']),
    );
  }
}

// ============================================================
// REPORT SEVERITY
// ============================================================

enum ReportSeverity {
  low,
  moderate,
  high,
  critical,
}

enum HazardType {
  flood,
  earthquake,
  unknown,
}

enum EvidenceType {
  blocked_road,
  rising_water,
  building_damage,
  people_trapped,
  infrastructure_damage,
  other,
}

enum AnalysisSource {
  GEMINI,
  DETERMINISTIC_FALLBACK,
}

// ============================================================
// COMMUNITY REPORT INPUT
// ============================================================

class CommunityReportInput {
  final String reportText;
  final String zoneId;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? reporterId;

  CommunityReportInput({
    required this.reportText,
    required this.zoneId,
    required this.location,
    this.latitude,
    this.longitude,
    this.reporterId,
  });

  Map<String, dynamic> toJson() {
    return {
      'report_text': reportText,
      'zone_id': zoneId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'reporter_id': reporterId,
    };
  }
}

// ============================================================
// COMMUNITY REPORT ANALYSIS
// ============================================================

class CommunityReportAnalysis {
  final HazardType hazardType;
  final ReportSeverity severity;
  final bool risingWater;
  final bool blockedRoad;
  final bool buildingDamage;
  final bool infrastructureDamage;
  final bool peopleTrapped;
  final bool transportationNeeded;
  final bool helpNeeded;
  final bool mobilityAssistanceNeeded;
  final double analysisConfidence;
  final List<String> extractedEvidence;
  final String analysisVersion;

  CommunityReportAnalysis({
    required this.hazardType,
    required this.severity,
    this.risingWater = false,
    this.blockedRoad = false,
    this.buildingDamage = false,
    this.infrastructureDamage = false,
    this.peopleTrapped = false,
    this.transportationNeeded = false,
    this.helpNeeded = false,
    this.mobilityAssistanceNeeded = false,
    required this.analysisConfidence,
    this.extractedEvidence = const [],
    this.analysisVersion = '1.0',
  });

  factory CommunityReportAnalysis.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityReportAnalysis(
      hazardType: HazardType.values.firstWhere(
        (e) => e.name == json['hazard_type'],
        orElse: () => HazardType.unknown,
      ),
      severity: ReportSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
      ),
      risingWater: json['rising_water'] ?? false,
      blockedRoad: json['blocked_road'] ?? false,
      buildingDamage:
          json['building_damage'] ?? false,
      infrastructureDamage:
          json['infrastructure_damage'] ?? false,
      peopleTrapped:
          json['people_trapped'] ?? false,
      transportationNeeded:
          json['transportation_needed'] ?? false,
      helpNeeded:
          json['help_needed'] ?? false,
      mobilityAssistanceNeeded:
          json['mobility_assistance_needed'] ?? false,
      analysisConfidence:
          (json['analysis_confidence'] ?? 0).toDouble(),
      extractedEvidence:
          List<String>.from(
        json['extracted_evidence'] ?? [],
      ),
      analysisVersion:
          json['analysis_version'] ?? '1.0',
    );
  }
}

// ============================================================
// COMMUNITY REPORT RECORD
// ============================================================

class CommunityReportRecord {
  final String reportId;
  final String zoneId;
  final String location;
  final double? latitude;
  final double? longitude;
  final String reportText;
  final String? reporterId;
  final CommunityReportAnalysis analysis;
  final AnalysisSource analysisSource;
  final bool verified;
  final bool resolved;
  final DateTime? verifiedAt;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  CommunityReportRecord({
    required this.reportId,
    required this.zoneId,
    required this.location,
    this.latitude,
    this.longitude,
    required this.reportText,
    this.reporterId,
    required this.analysis,
    required this.analysisSource,
    this.verified = false,
    this.resolved = false,
    this.verifiedAt,
    this.resolvedAt,
    required this.createdAt,
  });

  factory CommunityReportRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityReportRecord(
      reportId: json['report_id'] ?? '',
      zoneId: json['zone_id'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      reportText: json['report_text'] ?? '',
      reporterId: json['reporter_id'],
      analysis:
          CommunityReportAnalysis.fromJson(
        json['analysis'] ?? {},
      ),
      analysisSource:
          AnalysisSource.values.firstWhere(
        (e) => e.name == json['analysis_source'],
      ),
      verified: json['verified'] ?? false,
      resolved: json['resolved'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      createdAt:
          DateTime.parse(json['created_at']),
    );
  }
}

// ============================================================
// COMMUNITY EVIDENCE
// ============================================================

class CommunityEvidence {
  final String zoneId;
  final EvidenceType evidenceType;
  final String description;
  final int ageMinutes;
  final bool verified;

  CommunityEvidence({
    required this.zoneId,
    required this.evidenceType,
    required this.description,
    required this.ageMinutes,
    this.verified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'evidence_type': evidenceType.name,
      'description': description,
      'age_minutes': ageMinutes,
      'verified': verified,
    };
  }
}

// ============================================================
// DECISION INPUT
// ============================================================

enum DecisionStatus {
  no_adjustment,
  action_adjusted,
  alert_required,
  human_review_required,
}

class DecisionInput {
  final Hazard hazard;
  final String zoneId;
  final double riskScore;
  final RiskLevel riskLevel;
  final double confidence;
  final List<CommunityEvidence> evidence;

  DecisionInput({
    required this.hazard,
    required this.zoneId,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    this.evidence = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'hazard': hazard.name,
      'zone_id': zoneId,
      'risk_score': riskScore,
      'risk_level': riskLevel.name,
      'confidence': confidence,
      'evidence':
          evidence.map((e) => e.toJson()).toList(),
    };
  }
}

// ============================================================
// DECISION FROM RISK
// ============================================================

class DecisionFromRiskInput {
  final Hazard hazard;
  final String zoneId;
  final double riskScore;
  final RiskLevel riskLevel;
  final double confidence;

  DecisionFromRiskInput({
    required this.hazard,
    required this.zoneId,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'hazard': hazard.name,
      'zone_id': zoneId,
      'risk_score': riskScore,
      'risk_level': riskLevel.name,
      'confidence': confidence,
    };
  }
}

// ============================================================
// FINAL DECISION
// ============================================================

class FinalDecision {
  final Hazard hazard;
  final String zoneId;
  final double riskScore;
  final RiskLevel riskLevel;
  final double confidence;
  final int evidenceUsed;
  final DecisionStatus decisionStatus;
  final bool notificationRequired;
  final String currentAction;
  final String backupAction;
  final List<String> reasons;

  FinalDecision({
    required this.hazard,
    required this.zoneId,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.evidenceUsed,
    required this.decisionStatus,
    this.notificationRequired = false,
    required this.currentAction,
    required this.backupAction,
    this.reasons = const [],
  });

  factory FinalDecision.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinalDecision(
      hazard: Hazard.values.firstWhere(
        (e) => e.name == json['hazard'],
      ),
      zoneId: json['zone_id'] ?? '',
      riskScore:
          (json['risk_score'] ?? 0).toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['risk_level'],
        orElse: () => RiskLevel.unknown,
      ),
      confidence:
          (json['confidence'] ?? 0).toDouble(),
      evidenceUsed:
          json['evidence_used'] ?? 0,
      decisionStatus:
          DecisionStatus.values.firstWhere(
        (e) => e.name == json['decision_status'],
      ),
      notificationRequired:
          json['notification_required'] ?? false,
      currentAction:
          json['current_action'] ?? '',
      backupAction:
          json['backup_action'] ?? '',
      reasons:
          List<String>.from(json['reasons'] ?? []),
    );
  }
}

// ============================================================
// ASSISTANCE ENUMS
// ============================================================

enum AssistanceRequestType {
  evacuation,
  transportation,
  mobility_assistance,
  medical_support,
  rescue_support,
  other,
}

enum AssistancePriority {
  low,
  moderate,
  high,
  critical,
}

enum AssistanceStatus {
  pending,
  assigned,
  in_progress,
  resolved,
}

enum AssistanceSource {
  manual,
  decision_engine,
}

// ============================================================
// ASSISTANCE REQUEST INPUT
// ============================================================

class AssistanceRequestInput {
  final String zoneId;
  final String location;
  final double? latitude;
  final double? longitude;
  final Hazard hazard;
  final AssistanceRequestType requestType;
  final AssistancePriority priority;
  final String description;
  final List<String> accessibilityNeeds;
  final String? requesterPhone;

  AssistanceRequestInput({
    required this.zoneId,
    required this.location,
    this.latitude,
    this.longitude,
    required this.hazard,
    required this.requestType,
    required this.priority,
    required this.description,
    this.accessibilityNeeds = const [],
    this.requesterPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'hazard': hazard.name,
      'request_type': requestType.name,
      'priority': priority.name,
      'description': description,
      'accessibility_needs':
          accessibilityNeeds,
      'requester_phone': requesterPhone,
    };
  }
}

// ============================================================
// ASSISTANCE REQUEST RECORD
// ============================================================

class AssistanceRequestRecord {
  final String requestId;
  final String zoneId;
  final String location;
  final double? latitude;
  final double? longitude;
  final Hazard hazard;
  final AssistanceRequestType requestType;
  final AssistancePriority priority;
  final String description;
  final String? requesterPhone;
  final AssistanceStatus status;
  final String? assignedVolunteerId;
  final AssistanceSource source;
  final String? decisionStatus;
  final int evidenceUsed;
  final List<String> sourceReportIds;
  final List<String> accessibilityNeeds;
  final bool requiresTrainedResponder;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? resolvedAt;

  AssistanceRequestRecord({
    required this.requestId,
    required this.zoneId,
    required this.location,
    this.latitude,
    this.longitude,
    required this.hazard,
    required this.requestType,
    required this.priority,
    required this.description,
    this.requesterPhone,
    this.status = AssistanceStatus.pending,
    this.assignedVolunteerId,
    this.source = AssistanceSource.manual,
    this.decisionStatus,
    this.evidenceUsed = 0,
    this.sourceReportIds = const [],
    this.accessibilityNeeds = const [],
    this.requiresTrainedResponder = false,
    required this.createdAt,
    this.assignedAt,
    this.startedAt,
    this.resolvedAt,
  });

  factory AssistanceRequestRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssistanceRequestRecord(
      requestId: json['request_id'] ?? '',
      zoneId: json['zone_id'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      hazard: Hazard.values.firstWhere(
        (e) => e.name == json['hazard'],
      ),
      requestType:
          AssistanceRequestType.values.firstWhere(
        (e) => e.name == json['request_type'],
      ),
      priority:
          AssistancePriority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      description: json['description'] ?? '',
      requesterPhone: json['requester_phone'],
      status: AssistanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssistanceStatus.pending,
      ),
      assignedVolunteerId:
          json['assigned_volunteer_id'],
      source: AssistanceSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => AssistanceSource.manual,
      ),
      decisionStatus:
          json['decision_status'],
      evidenceUsed:
          json['evidence_used'] ?? 0,
      sourceReportIds:
          List<String>.from(
        json['source_report_ids'] ?? [],
      ),
      accessibilityNeeds:
          List<String>.from(
        json['accessibility_needs'] ?? [],
      ),
      requiresTrainedResponder:
          json['requires_trained_responder'] ?? false,
      createdAt:
          DateTime.parse(json['created_at']),
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }
}

// ============================================================
// MONJED ASSESSMENT
// ============================================================

class MonjedAssessment {
  final RiskAssessment risk;
  final FinalDecision decision;
  final dynamic accessibleAction;
  final AssistanceRequestRecord? assistanceRequest;
  final Map<String, dynamic>? aiAlert;
  final Map<String, dynamic>? delivery;

  MonjedAssessment({
    required this.risk,
    required this.decision,
    this.accessibleAction,
    this.assistanceRequest,
    this.aiAlert,
    this.delivery,
  });

  factory MonjedAssessment.fromJson(
    Map<String, dynamic> json,
  ) {
    return MonjedAssessment(
      risk: RiskAssessment.fromJson(
        json['risk'] ?? {},
      ),
      decision: FinalDecision.fromJson(
        json['decision'] ?? {},
      ),
      accessibleAction:
          json['accessible_action'],
      assistanceRequest:
          json['assistance_request'] != null
              ? AssistanceRequestRecord.fromJson(
                  json['assistance_request'],
                )
              : null,
      aiAlert: json['ai_alert'] != null
          ? Map<String, dynamic>.from(
              json['ai_alert'],
            )
          : null,
      delivery: json['delivery'] != null
          ? Map<String, dynamic>.from(
              json['delivery'],
            )
          : null,
    );
  }
}

// ============================================================
// DISTRESS REQUEST
// ============================================================

class DistressRequest {
  final String phone;
  final double? latitude;
  final double? longitude;
  final String? details;

  DistressRequest({
    required this.phone,
    this.latitude,
    this.longitude,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'details': details,
    };
  }
}
```