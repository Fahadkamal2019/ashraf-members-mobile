class DuesSummary {
  DuesSummary({
    required this.available,
    required this.blockedMessage,
    required this.lastRenewedYear,
    required this.currentYear,
    required this.yearsOwed,
    required this.perYearFee,
    required this.renewalCardFee,
    required this.electronicServicesFee,
    required this.suggestedTotalDue,
    required this.maxYearsToRenew,
  });

  // False (with blockedMessage set) for a non-Egyptian member, who must renew in person instead.
  final bool available;
  final String? blockedMessage;
  final int? lastRenewedYear;
  final int currentYear;
  final int yearsOwed;
  final double perYearFee;
  final double renewalCardFee;
  final double electronicServicesFee;
  final double suggestedTotalDue;
  final int maxYearsToRenew;

  factory DuesSummary.fromJson(Map<String, dynamic> json) => DuesSummary(
        available: json['available'] as bool,
        blockedMessage: json['blockedMessage'] as String?,
        lastRenewedYear: json['lastRenewedYear'] as int?,
        currentYear: json['currentYear'] as int,
        yearsOwed: json['yearsOwed'] as int,
        perYearFee: (json['perYearFee'] as num).toDouble(),
        renewalCardFee: (json['renewalCardFee'] as num).toDouble(),
        electronicServicesFee: (json['electronicServicesFee'] as num).toDouble(),
        suggestedTotalDue: (json['suggestedTotalDue'] as num).toDouble(),
        maxYearsToRenew: json['maxYearsToRenew'] as int,
      );
}
