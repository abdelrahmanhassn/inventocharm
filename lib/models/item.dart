class Item {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String? image;
  final double price;
  final double cost;
  final int quantity;
  final String? code;
  final DateTime? createdAt;

  const Item({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.quantity,
    this.image,
    this.code,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      code: json['code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'code': code,
    };
  }

  Item copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? image,
    double? price,
    double? cost,
    int? quantity,
    String? code,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
