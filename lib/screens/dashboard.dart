import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;
import '../widgets/item_container.dart';
import 'cart.dart';
import 'account.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String searchQuery = "";

  void _showProductDetail(
      BuildContext context, Map<String, dynamic> product, String productId) {
    int quantity = 1;
    final user = FirebaseAuth.instance.currentUser!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      product["img"] ?? "",
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product["name"] ?? "",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("Rs. ${product["price"]}",
                      style: const TextStyle(fontSize: 18)),
                  Text("${product["discount"]}% OFF",
                      style: const TextStyle(color: Colors.deepOrange)),
                  const SizedBox(height: 16),

                  // Quantity Selector
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final cartRef = FirebaseFirestore.instance
                            .collection("users")
                            .doc(user.uid)
                            .collection("cart")
                            .doc(productId);

                        final doc = await cartRef.get();

                        if (doc.exists) {
                          int existingQty = doc["quantity"] ?? 1;
                          await cartRef
                              .update({"quantity": existingQty + quantity});
                        } else {
                          await cartRef.set({
                            "name": product["name"],
                            "price": product["price"],
                            "discount": product["discount"],
                            "img": product["img"],
                            "quantity": quantity,
                            "addedAt": Timestamp.now(),
                          });
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart")),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add to Cart"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        if (user != null)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Logged in as: ${user.email}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ),

        // search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: (value) =>
                setState(() => searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search for products...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(height: 10),

        //products
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
            FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No items found"));
              }

              final docs = snapshot.data!.docs.where((doc) {
                final name =
                (doc['name'] ?? "").toString().toLowerCase().trim();
                return name.contains(searchQuery);
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data =
                      docs[index].data() as Map<String, dynamic>? ?? {};
                  final price = data['price'];
                  final discount = data['discount'];

                  return GestureDetector(
                    onTap: () => _showProductDetail(
                        context, data, docs[index].id), //detail bottom sheet
                    child: ItemContainer(
                      img: data['img'] ?? "",
                      name: data['name'] ?? "No name",
                      price: (price is int)
                          ? price.toDouble()
                          : (price is double ? price : 0.0),
                      discount: (discount is int)
                          ? discount.toDouble()
                          : (discount is double ? discount : 0.0),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),

          //badeges
          BottomNavigationBarItem(
            icon: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("cart")
                  .snapshots(),
              builder: (context, snapshot) {
                int itemCount = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    itemCount += (data["quantity"] ?? 1) as int;
                  }
                }

                return badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  showBadge: itemCount > 0,
                  badgeContent: Text(
                    itemCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: const Icon(Icons.shopping_cart),
                );
              },
            ),
            label: "Cart",
          ),

          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
