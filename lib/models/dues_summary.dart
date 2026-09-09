class DuesSummary {
  DuesSummary({
    required this.lastRenewedYear,
    required this.currentYear,
    required this.yearsOwed,
    required this.perYearFee,
    required this.renewalCardFee,
    required this.electronicServicesFee,
    required this.suggestedTotalDue,
  });

  final int? lastRenewedYear;
  final int currentYear;
  final int yearsOwed;
  final double perYearFee;
  final double renewalCardFee;
  final double electronicServicesFee;
  final double suggestedTotalDue;

  factory DuesSummary.fromJson(Map<String, dynamic> json) => DuesSummary(
        lastRenewedYear: json['lastRenewedYear'] as int?,
        currentYear: json['currentYear'] as int,
        yearsOwed: json['yearsOwed'] as int,
        perYearFee: (json['perYearFee'] as num).toDouble(),
        renewalCardFee: (json['renewalCardFee'] as num).toDouble(),
        electronicServicesFee: (json['electronicServicesFee'] as num).toDouble(),
        suggestedTotalDue: (json['suggestedTotalDue'] as num).toDouble(),
      );
}
