import 'dart:math';
import 'package:flutter/material.dart';

// --------------------------------------------------------------------------
// BAGIAN 1: SIMULASI DATA.DART (Model & Services)
// PENTING: Jika Anda sudah memiliki data.dart, ganti bagian ini dengan:
// import 'data.dart';
// --------------------------------------------------------------------------

/// Model untuk Produk
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final Color color;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.color,
  });
}

/// Model untuk Item Keranjang
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

/// Product Service (Menyediakan data produk)
class ProductService {
  static final ProductService instance = ProductService._internal();
  factory ProductService() => instance;
  ProductService._internal();

  /// Daftar produk dummy
  List<Product> getProducts() {
    return const [
      Product(
        id: '1',
        name: 'Aether Pods',
        description: 'Headphones nirkabel dengan suara jernih dan noise cancellation premium.',
        price: 199.99,
        imageUrl: 'https://placehold.co/600x600/1e88e5/ffffff?text=Pods',
        color: Color(0xFF1E88E5), // Blue
      ),
      Product(
        id: '2',
        name: 'Chroma Watch',
        description: 'Smartwatch futuristik dengan pelacakan kesehatan canggih dan layar AMOLED.',
        price: 249.00,
        imageUrl: 'https://placehold.co/600x600/f4511e/ffffff?text=Watch',
        color: Color(0xFFF4511E), // Orange
      ),
      Product(
        id: '3',
        name: 'Kinetic Keyboard',
        description: 'Keyboard mekanik taktil, full RGB, untuk pengalaman mengetik superior.',
        price: 129.50,
        imageUrl: 'https://placehold.co/600x600/43a047/ffffff?text=Keyboard',
        color: Color(0xFF43A047), // Green
      ),
      Product(
        id: '4',
        name: 'Orbital Mouse',
        description: 'Mouse ergonomis dengan presisi laser untuk gamer profesional.',
        price: 79.90,
        imageUrl: 'https://placehold.co/600x600/8e24aa/ffffff?text=Mouse',
        color: Color(0xFF8E24AA), // Purple
      ),
    ];
  }
}

/// Cart Service (Manajemen state keranjang)
class CartService {
  static final CartService instance = CartService._internal();
  factory CartService() => instance;
  CartService._internal();

  // State keranjang menggunakan ValueNotifier untuk update real-time
  final ValueNotifier<List<CartItem>> _cart = ValueNotifier([]);
  ValueListenable<List<CartItem>> get cartNotifier => _cart;

  // Notifiers untuk nilai turunan yang dianimasikan
  final ValueNotifier<double> _totalPrice = ValueNotifier(0.0);
  ValueListenable<double> get totalPriceNotifier => _totalPrice;
  
  final ValueNotifier<int> _totalItems = ValueNotifier(0);
  ValueListenable<int> get totalItemsNotifier => _totalItems;

  /// Menghitung ulang total harga dan jumlah item
  void _calculateTotals() {
    double newTotal = 0.0;
    int newItems = 0;
    for (var item in _cart.value) {
      newTotal += item.subtotal;
      newItems += item.quantity;
    }
    _totalPrice.value = newTotal;
    _totalItems.value = newItems;
  }

  /// Menambah produk ke keranjang
  void addToCart(Product product) {
    int index = _cart.value.indexWhere((item) => item.product.id == product.id);
    
    // Duplikat list untuk memicu ValueNotifier update
    List<CartItem> newCart = List.from(_cart.value); 

    if (index >= 0) {
      newCart[index].quantity += 1;
    } else {
      newCart.add(CartItem(product: product, quantity: 1));
    }
    
    _cart.value = newCart;
    _calculateTotals();
  }

  /// Mengurangi kuantitas produk atau menghapusnya jika kuantitas = 1
  void removeFromCart(Product product) {
    int index = _cart.value.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      List<CartItem> newCart = List.from(_cart.value);
      if (newCart[index].quantity > 1) {
        newCart[index].quantity -= 1;
      } else {
        newCart.removeAt(index);
      }
      _cart.value = newCart;
      _calculateTotals();
    }
  }

  /// Menghapus semua item dari satu jenis produk
  void removeAllOfProduct(Product product) {
    List<CartItem> newCart = _cart.value.where((item) => item.product.id != product.id).toList();
    _cart.value = newCart;
    _calculateTotals();
  }

  /// Mengosongkan keranjang
  void clearCart() {
    _cart.value = [];
    _calculateTotals();
  }
}

// --------------------------------------------------------------------------
// BAGIAN 2: MAIN APP & SETUP
// --------------------------------------------------------------------------

void main() {
  runApp(const MyApp());
}

/// Kelas utama aplikasi, menggunakan Material 3
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech Cart Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomePage(),
    );
  }
}

// --------------------------------------------------------------------------
// BAGIAN 3: UTILITAS (CustomRouteTransition)
// --------------------------------------------------------------------------

/// Helper untuk animasi transisi antar halaman (fade + slide dari bawah)
class CustomTransition<T> extends PageRouteBuilder<T> {
  final Widget page;

  CustomTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animasi slide dari bawah
            const begin = Offset(0.0, 0.1);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation, // Animasi fade
                child: child,
              ),
            );
          },
        );
}

// --------------------------------------------------------------------------
// BAGIAN 4: HOMEPAGE (Daftar Produk)
// --------------------------------------------------------------------------

/// Halaman utama menampilkan daftar produk dalam grid
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> products = ProductService.instance.getProducts();

  /// Menavigasi ke CartPage dengan CustomTransition
  void _goToCart() async {
    // Navigasi dengan CustomTransition dan tunggu hasilnya (untuk refresh)
    final shouldRefresh = await Navigator.of(context).push(
      CustomTransition(page: const CartPage()),
    );

    // Persyaratan 6: Kembali dari cart otomatis reload data di HomePage
    if (shouldRefresh == true && mounted) {
      setState(() {
        // State kosong pun akan memicu build ulang, yang cukup untuk skenario ini
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Tentukan jumlah kolom berdasarkan lebar layar
    final crossAxisCount = screenWidth > 600 ? 3 : 2; 
    final aspectRatio = screenWidth > 600 ? 0.8 : 0.75;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Gadgets Store'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _AnimatedCartBadge(onTap: _goToCart),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return AnimatedProductCard(product: product);
          },
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// BAGIAN 5: KOMPONEN BERBAGUNA
// --------------------------------------------------------------------------

/// Komponen wajib: Badge jumlah item cart dengan animasi
class _AnimatedCartBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _AnimatedCartBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder untuk mendengarkan perubahan jumlah item keranjang
    return ValueListenableBuilder<int>(
      valueListenable: CartService.instance.totalItemsNotifier,
      builder: (context, totalItems, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              iconSize: 28,
              onPressed: onTap,
            ),
            if (totalItems > 0)
              Positioned(
                right: 8,
                top: 8,
                // AnimatedContainer untuk animasi ukuran dan warna badge
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  constraints: BoxConstraints(
                    minWidth: 20.0,
                    minHeight: 20.0,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // AnimatedDefaultTextStyle untuk animasi perubahan teks (jika perlu)
                  child: Text(
                    totalItems > 99 ? '99+' : totalItems.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Komponen wajib: Card produk dengan animasi fade & scale
class AnimatedProductCard extends StatelessWidget {
  final Product product;
  
  const AnimatedProductCard({super.key, required this.product});

  /// Navigasi ke detail produk dengan CustomTransition
  void _goToDetails(BuildContext context) {
    Navigator.of(context).push(
      CustomTransition(
        page: ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Hero untuk transisi gambar
    return GestureDetector(
      onTap: () => _goToDetails(context),
      // ScaleTransition untuk efek klik kecil
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.98).animate(
          CurvedAnimation(parent: const AlwaysStoppedAnimation(1.0), curve: Curves.easeOut),
        ),
        // Card bersih Material 3
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Area Gambar dan Animasi
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Hero(
                    tag: 'product_image_${product.id}',
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png', // Placeholder (simulasi)
                      image: product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      imageErrorBuilder: (context, error, stackTrace) => 
                        Container(
                          color: product.color.withOpacity(0.3),
                          child: const Center(child: Icon(Icons.broken_image, size: 40)),
                        ),
                    ),
                  ),
                ),
              ),
              // Area Deskripsi
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      // Tombol Add to Cart kecil
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedAddButton(
                          product: product,
                          isMini: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Komponen wajib: Tombol Add to Cart dengan efek ripple + animasi scale
class AnimatedAddButton extends StatefulWidget {
  final Product product;
  final bool isMini;
  const AnimatedAddButton({super.key, required this.product, this.isMini = false});

  @override
  State<AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    // Animasi Scale Kecil
    _controller.forward().then((_) => _controller.reverse());

    // Fungsionalitas: Menambah produk ke keranjang
    CartService.instance.addToCart(widget.product);

    // Tampilkan snackbar konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ditambahkan ke keranjang!'),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMini) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton.small(
          heroTag: 'add_mini_${widget.product.id}',
          onPressed: _onTap,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 2,
          child: Icon(
            Icons.add_shopping_cart_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 18,
          ),
        ),
      );
    }
    
    // Tombol besar untuk Detail Page
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ElevatedButton.icon(
        onPressed: _onTap,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Tambah ke Keranjang'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          elevation: 4,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}


// --------------------------------------------------------------------------
// BAGIAN 6: PRODUCT DETAIL PAGE
// --------------------------------------------------------------------------

/// Halaman Detail Produk
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk dengan Hero
            Hero(
              tag: 'product_image_${product.id}',
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: product.color.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(
                          color: product.color.withOpacity(0.3),
                          child: const Center(child: Icon(Icons.broken_image, size: 80)),
                        ),
                    ),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Deskripsi Produk',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar berisi tombol Add to Cart
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: AnimatedAddButton(product: product),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// BAGIAN 7: CART PAGE
// --------------------------------------------------------------------------

/// Halaman Keranjang
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  
  /// Komponen wajib: Checkout dialog
  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CheckoutDialog(
          onConfirm: () {
            CartService.instance.clearCart();
            Navigator.of(context).pop(); // Tutup dialog
            // Kembali ke HomePage, mengirim 'true' untuk refresh (persyaratan 6)
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // ValueListenableBuilder untuk mendengarkan perubahan daftar keranjang
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartService.instance.cartNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Keranjang Anda kosong.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return _CartItemTile(item: cartItems[index]);
                  },
                ),
              ),
              // Komponen wajib: Total section dengan animasi perubahan angka
              _CartTotalSection(onCheckout: () => _showCheckoutDialog(context)),
            ],
          );
        },
      ),
    );
  }
}

/// Widget untuk menampilkan detail item di keranjang
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final Product product = item.product;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Rp ${product.price.toStringAsFixed(2)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => CartService.instance.removeFromCart(product),
              ),
              // AnimatedSwitcher untuk animasi jumlah kuantitas
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  item.quantity.toString(),
                  key: ValueKey<int>(item.quantity), // Kunci unik memicu animasi
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => CartService.instance.addToCart(product),
              ),
              const SizedBox(width: 8),
              // Tombol hapus total item
              IconButton(
                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                onPressed: () => CartService.instance.removeAllOfProduct(product),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Komponen wajib: Total section dengan animasi perubahan angka
class _CartTotalSection extends StatelessWidget {
  final VoidCallback onCheckout;
  const _CartTotalSection({required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga:',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              // ValueListenableBuilder untuk mendengarkan perubahan total harga
              ValueListenableBuilder<double>(
                valueListenable: CartService.instance.totalPriceNotifier,
                builder: (context, total, child) {
                  // TweenAnimationBuilder untuk animasi perubahan angka
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: total),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (BuildContext context, double value, Widget? child) {
                      return Text(
                        'Rp ${value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCheckout,
            icon: const Icon(Icons.payment),
            label: const Text('Lanjutkan ke Checkout'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              elevation: 4,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Komponen wajib: Checkout dialog (AlertDialog)
class CheckoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const CheckoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Konfirmasi Pembelian'),
      content: const Text('Apakah Anda yakin ingin menyelesaikan pesanan ini? Keranjang akan dikosongkan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Ya, Beli Sekarang'),
        ),
      ],
    );
  }
}
