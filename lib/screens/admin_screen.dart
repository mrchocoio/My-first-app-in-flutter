import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  File? _pickedImage; // store picked gallery image
  bool loading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and pick an image")),
      );
      return;
    }

    double? price = double.tryParse(priceController.text.trim());
    double? discount = discountController.text.isEmpty
        ? 0
        : double.tryParse(discountController.text.trim());

    if (price == null || discount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid numbers for price/discount")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection("products").add({
        "name": nameController.text.trim(),
        "price": price,
        "discount": discount,
        "localImg": _pickedImage?.path, // only local image path saved
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product uploaded successfully")),
      );

      nameController.clear();
      priceController.clear();
      discountController.clear();
      _pickedImage = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteProduct(String docId) async {
    await FirebaseFirestore.instance.collection("products").doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // product description fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Discount (%)"),
            ),
            const SizedBox(height: 20),

            // image button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick Product Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),

            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(_pickedImage!, height: 120),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _uploadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload Product"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Uploaded Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // product list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return const Center(
                      child: Text("No products uploaded yet"),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final data = product.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          leading: data["localImg"] != null &&
                              data["localImg"].toString().isNotEmpty
                              ? Image.file(
                            File(data["localImg"]),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image_not_supported),
                          title: Text(data["name"] ?? ""),
                          subtitle: Text(
                            "Rs. ${data["price"]} • ${data["discount"]}% OFF",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
