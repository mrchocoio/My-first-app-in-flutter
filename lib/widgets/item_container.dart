import 'package:flutter/material.dart';

class ItemContainer extends StatelessWidget {
  final String img;
  final String name;
  final double price;
  final double discount;

  const ItemContainer({
    super.key,
    required this.img,
    required this.name,
    required this.price,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                img,
                width: double.infinity,
                fit: BoxFit.cover, // crop to fit
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
            ),
          ),

          // text section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // product name
                  Text(
                    name,
                    maxLines: 2, // never overflows
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // product price
                  Text(
                    "\Pkr${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),

                  // discount
                  if (discount > 0)
                    Text(
                      "Discount: ${discount.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
