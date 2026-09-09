class ServiceCatalogItem {
  ServiceCatalogItem({required this.paymentTypeId, required this.nameAr, required this.price});

  final int paymentTypeId;
  final String nameAr;
  final double price;

  factory ServiceCatalogItem.fromJson(Map<String, dynamic> json) => ServiceCatalogItem(
        paymentTypeId: json['paymentTypeId'] as int,
        nameAr: json['nameAr'] as String,
        price: (json['price'] as num).toDouble(),
      );
}
