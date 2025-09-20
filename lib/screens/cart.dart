import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  // quantity plus
  Future<void> _increaseQuantity(String docId, int currentQty) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(docId)
        .update({"quantity": currentQty + 1});
  }

  // quantity minus
  Future<void> _decreaseQuantity(String docId, int currentQty) async {
    if (currentQty > 1) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("cart")
          .doc(docId)
          .update({"quantity": currentQty - 1});
    } else {
      _removeItem(docId);
    }
  }

  // removing item
  Future<void> _removeItem(String docId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(docId)
        .delete();
  }

  // calculating price
  double _calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      final data = item.data() as Map<String, dynamic>;
      double price = (data["price"] ?? 0).toDouble();
      double discount = (data["discount"] ?? 0).toDouble();
      int qty = (data["quantity"] ?? 1) is int
          ? data["quantity"]
          : (data["quantity"] ?? 1).toInt();

      double discountedPrice = price - (price * discount / 100);
      total += discountedPrice * qty;
    }
    return total;
  }

  //checkout and saving purchase history
  Future<void> _checkout(List<QueryDocumentSnapshot> cartItems) async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    double total = _calculateTotal(cartItems);
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderData = {
      "items": cartItems
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList(),
      "total": total,
      "purchasedAt": Timestamp.now(),
      "purchasedAtFormatted":
      DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
    };

    final userDoc =
    FirebaseFirestore.instance.collection("users").doc(user.uid);

    await userDoc.collection("purchaseHistory").doc(orderId).set(orderData);

    // clean
    for (var item in cartItems) {
      await item.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Purchase successful!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("cart")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final cartItems = snapshot.data!.docs;

        if (cartItems.isEmpty) {
          return const Center(
            child: Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }

        double total = _calculateTotal(cartItems);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final data = item.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Image.network(
                        data["img"] ?? "",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
                      ),
                      title: Text(data["name"] ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Rs. ${data["price"]}"),
                          Text("${data["discount"]}% OFF",
                              style:
                              const TextStyle(color: Colors.deepOrange)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () =>
                                _decreaseQuantity(item.id, data["quantity"]),
                          ),
                          Text("${data["quantity"]}"),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                _increaseQuantity(item.id, data["quantity"]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: Rs. ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _checkout(cartItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text("Checkout"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
