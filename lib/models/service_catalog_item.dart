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

class ServiceCatalog {
  ServiceCatalog({required this.available, required this.blockedMessage, required this.items});

  // False (with blockedMessage set) for a non-Egyptian member, who must buy services in person instead.
  final bool available;
  final String? blockedMessage;
  final List<ServiceCatalogItem> items;

  factory ServiceCatalog.fromJson(Map<String, dynamic> json) => ServiceCatalog(
        available: json['available'] as bool,
        blockedMessage: json['blockedMessage'] as String?,
        items: (json['items'] as List).map((e) => ServiceCatalogItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
