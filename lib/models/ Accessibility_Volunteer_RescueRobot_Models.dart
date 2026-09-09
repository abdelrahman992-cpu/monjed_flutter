```text
lib/models/accessibility/
    accessibility_models.dart

lib/models/volunteers/
    volunteer_models.dart

lib/models/rescue_robot/
    rescue_robot_models.dart
```

```dart
// ============================================================
// ACCESSIBILITY
// ============================================================

enum AccessibilityNeed {
  mobility,
  visual,
  hearing,
  cognitive,
}

// ============================================================
// ACCESSIBILITY PROFILE
// ============================================================

class AccessibilityProfile {
  final List<AccessibilityNeed> accessibilityNeeds;

  AccessibilityProfile({
    this.accessibilityNeeds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'accessibility_needs':
          accessibilityNeeds
              .map((e) => e.name)
              .toList(),
    };
  }

  factory AccessibilityProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccessibilityProfile(
      accessibilityNeeds:
          (json['accessibility_needs'] ?? [])
              .map<AccessibilityNeed>(
        (e) => AccessibilityNeed.values
            .firstWhere((x) => x.name == e),
      ).toList(),
    );
  }
}

// ============================================================
// ACCESSIBILITY DECISION INPUT
// ============================================================

class AccessibilityDecisionInput {
  final dynamic decision;
  final AccessibilityProfile profile;

  AccessibilityDecisionInput({
    required this.decision,
    required this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'decision': decision,
      'profile': profile.toJson(),
    };
  }
}

// ============================================================
// ACCESSIBLE ACTION PLAN
// ============================================================

class AccessibleActionPlan {
  final String hazard;
  final String zoneId;
  final List<AccessibilityNeed> accessibilityNeeds;
  final String originalCurrentAction;
  final String originalBackupAction;
  final String adaptedCurrentAction;
  final String adaptedBackupAction;
  final List<String> communicationRequirements;
  final bool assistanceRequestRecommended;

  AccessibleActionPlan({
    required this.hazard,
    required this.zoneId,
    required this.accessibilityNeeds,
    required this.originalCurrentAction,
    required this.originalBackupAction,
    required this.adaptedCurrentAction,
    required this.adaptedBackupAction,
    required this.communicationRequirements,
    this.assistanceRequestRecommended = false,
  });

  factory AccessibleActionPlan.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccessibleActionPlan(
      hazard: json['hazard'] ?? '',
      zoneId: json['zone_id'] ?? '',
      accessibilityNeeds:
          (json['accessibility_needs'] ?? [])
              .map<AccessibilityNeed>(
        (e) => AccessibilityNeed.values
            .firstWhere((x) => x.name == e),
      ).toList(),
      originalCurrentAction:
          json['original_current_action'] ?? '',
      originalBackupAction:
          json['original_backup_action'] ?? '',
      adaptedCurrentAction:
          json['adapted_current_action'] ?? '',
      adaptedBackupAction:
          json['adapted_backup_action'] ?? '',
      communicationRequirements:
          List<String>.from(
        json['communication_requirements'] ?? [],
      ),
      assistanceRequestRecommended:
          json['assistance_request_recommended'] ??
              false,
    );
  }
}

// ============================================================
// VOLUNTEER
// ============================================================

enum ResponderLevel {
  volunteer,
  trained_responder,
}

enum VolunteerSkill {
  evacuation,
  transportation,
  mobility_assistance,
  medical_support,
  rescue_support,
  general_support,
}

// ============================================================
// VOLUNTEER INPUT
// ============================================================

class VolunteerInput {
  final String name;
  final String zoneId;
  final double? latitude;
  final double? longitude;
  final bool available;
  final ResponderLevel responderLevel;
  final String? vehicleType;
  final int capacity;
  final List<VolunteerSkill> skills;

  VolunteerInput({
    required this.name,
    required this.zoneId,
    this.latitude,
    this.longitude,
    this.available = true,
    this.responderLevel =
        ResponderLevel.volunteer,
    this.vehicleType,
    this.capacity = 1,
    this.skills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'zone_id': zoneId,
      'latitude': latitude,
      'longitude': longitude,
      'available': available,
      'responder_level':
          responderLevel.name,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'skills':
          skills.map((e) => e.name).toList(),
    };
  }
}

// ============================================================
// VOLUNTEER RECORD
// ============================================================

class VolunteerRecord {
  final String name;
  final String zoneId;
  final double? latitude;
  final double? longitude;
  final bool available;
  final ResponderLevel responderLevel;
  final String? vehicleType;
  final int capacity;
  final List<VolunteerSkill> skills;
  final String volunteerId;

  VolunteerRecord({
    required this.name,
    required this.zoneId,
    this.latitude,
    this.longitude,
    this.available = true,
    this.responderLevel =
        ResponderLevel.volunteer,
    this.vehicleType,
    this.capacity = 1,
    this.skills = const [],
    required this.volunteerId,
  });

  factory VolunteerRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return VolunteerRecord(
      name: json['name'] ?? '',
      zoneId: json['zone_id'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      available: json['available'] ?? true,
      responderLevel:
          ResponderLevel.values.firstWhere(
        (e) => e.name == json['responder_level'],
        orElse: () =>
            ResponderLevel.volunteer,
      ),
      vehicleType: json['vehicle_type'],
      capacity: json['capacity'] ?? 1,
      skills:
          (json['skills'] ?? [])
              .map<VolunteerSkill>(
        (e) => VolunteerSkill.values
            .firstWhere((x) => x.name == e),
      ).toList(),
      volunteerId:
          json['volunteer_id'] ?? '',
    );
  }
}

// ============================================================
// VOLUNTEER AVAILABILITY UPDATE
// PATCH /assistance/volunteers/{id}
// ============================================================

class VolunteerAvailabilityUpdate {
  final bool available;

  VolunteerAvailabilityUpdate({
    required this.available,
  });

  Map<String, dynamic> toJson() {
    return {
      'available': available,
    };
  }
}

// ============================================================
// RESCUE MISSION CREATE
// ============================================================

enum RescuePriority {
  LOW,
  MODERATE,
  HIGH,
  CRITICAL,
}

class RescueMissionCreate {
  final String? missionId;
  final String missionType;
  final String hazard;
  final RescuePriority priority;
  final String targetLabel;
  final String objective;
  final String robotId;

  RescueMissionCreate({
    this.missionId,
    this.missionType = 'Search & Rescue',
    this.hazard = 'FLOOD',
    this.priority = RescuePriority.HIGH,
    this.targetLabel = 'Building 04',
    this.objective = 'Inspect affected area',
    this.robotId = 'MONJED-R01',
  });

  Map<String, dynamic> toJson() {
    return {
      'mission_id': missionId,
      'mission_type': missionType,
      'hazard': hazard,
      'priority': priority.name,
      'target_label': targetLabel,
      'objective': objective,
      'robot_id': robotId,
    };
  }
}

// ============================================================
// RESCUE MISSION RECORD
// ============================================================

class RescueMissionRecord {
  final String missionId;
  final String missionType;
  final String hazard;
  final String priority;
  final String targetLabel;
  final String objective;
  final String robotId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>> findings;

  RescueMissionRecord({
    required this.missionId,
    required this.missionType,
    required this.hazard,
    required this.priority,
    required this.targetLabel,
    required this.objective,
    required this.robotId,
    this.status = 'created',
    required this.createdAt,
    required this.updatedAt,
    this.findings = const [],
  });

  factory RescueMissionRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return RescueMissionRecord(
      missionId: json['mission_id'] ?? '',
      missionType: json['mission_type'] ?? '',
      hazard: json['hazard'] ?? '',
      priority: json['priority'] ?? '',
      targetLabel: json['target_label'] ?? '',
      objective: json['objective'] ?? '',
      robotId: json['robot_id'] ?? '',
      status: json['status'] ?? 'created',
      createdAt:
          DateTime.parse(json['created_at']),
      updatedAt:
          DateTime.parse(json['updated_at']),
      findings:
          List<Map<String, dynamic>>.from(
        json['findings'] ?? [],
      ),
    );
  }
}

// ============================================================
// RESCUE TELEMETRY INPUT
// ============================================================

class RescueTelemetryIn {
  final String robotId;
  final String status;
  final double battery;
  final double temperature;
  final String gasLevel;
  final Map<String, double> position;
  final String? missionId;
  final Map<String, double>? ultrasonic;
  final double? speed;
  final double? yaw;
  final Map<String, dynamic>? imu;
  final bool? cameraOnline;
  final Map<String, dynamic>? arm;
  final List<String> warnings;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> findings;
  final String? hazard;
  final String? riskLevel;

  RescueTelemetryIn({
    this.robotId = 'MONJED-R01',
    required this.status,
    required this.battery,
    required this.temperature,
    required this.gasLevel,
    required this.position,
    this.missionId,
    this.ultrasonic,
    this.speed,
    this.yaw,
    this.imu,
    this.cameraOnline,
    this.arm,
    this.warnings = const [],
    this.events = const [],
    this.findings = const [],
    this.hazard,
    this.riskLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'robotId': robotId,
      'status': status,
      'battery': battery,
      'temperature': temperature,
      'gasLevel': gasLevel,
      'position': position,
      'missionId': missionId,
      'ultrasonic': ultrasonic,
      'speed': speed,
      'yaw': yaw,
      'imu': imu,
      'cameraOnline': cameraOnline,
      'arm': arm,
      'warnings': warnings,
      'events': events,
      'findings': findings,
      'hazard': hazard,
      'riskLevel': riskLevel,
    };
  }
}

// ============================================================
// RESCUE TELEMETRY RECORD
// ============================================================

class RescueTelemetryRecord extends RescueTelemetryIn {
  final DateTime receivedAt;

  RescueTelemetryRecord({
    String robotId = 'MONJED-R01',
    required String status,
    required double battery,
    required double temperature,
    required String gasLevel,
    required Map<String, double> position,
    String? missionId,
    Map<String, double>? ultrasonic,
    double? speed,
    double? yaw,
    Map<String, dynamic>? imu,
    bool? cameraOnline,
    Map<String, dynamic>? arm,
    List<String> warnings = const [],
    List<Map<String, dynamic>> events = const [],
    List<Map<String, dynamic>> findings = const [],
    String? hazard,
    String? riskLevel,
    required this.receivedAt,
  }) : super(
          robotId: robotId,
          status: status,
          battery: battery,
          temperature: temperature,
          gasLevel: gasLevel,
          position: position,
          missionId: missionId,
          ultrasonic: ultrasonic,
          speed: speed,
          yaw: yaw,
          imu: imu,
          cameraOnline: cameraOnline,
          arm: arm,
          warnings: warnings,
          events: events,
          findings: findings,
          hazard: hazard,
          riskLevel: riskLevel,
        );

  factory RescueTelemetryRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return RescueTelemetryRecord(
      robotId: json['robotId'] ?? 'MONJED-R01',
      status: json['status'] ?? '',
      battery:
          (json['battery'] ?? 0).toDouble(),
      temperature:
          (json['temperature'] ?? 0).toDouble(),
      gasLevel: json['gasLevel'] ?? '',
      position: Map<String, double>.from(
        (json['position'] ?? {}).map(
          (key, value) =>
              MapEntry(key, (value as num).toDouble()),
        ),
      ),
      missionId: json['missionId'],
      ultrasonic:
          json['ultrasonic'] != null
              ? Map<String, double>.from(
                  json['ultrasonic'].map(
                    (key, value) =>
                        MapEntry(
                          key,
                          (value as num).toDouble(),
                        ),
                  ),
                )
              : null,
      speed: json['speed']?.toDouble(),
      yaw: json['yaw']?.toDouble(),
      imu: json['imu'] != null
          ? Map<String, dynamic>.from(
              json['imu'],
            )
          : null,
      cameraOnline: json['cameraOnline'],
      arm: json['arm'] != null
          ? Map<String, dynamic>.from(
              json['arm'],
            )
          : null,
      warnings:
          List<String>.from(json['warnings'] ?? []),
      events:
          List<Map<String, dynamic>>.from(
        json['events'] ?? [],
      ),
      findings:
          List<Map<String, dynamic>>.from(
        json['findings'] ?? [],
      ),
      hazard: json['hazard'],
      riskLevel: json['riskLevel'],
      receivedAt:
          DateTime.parse(json['received_at']),
    );
  }
}
```