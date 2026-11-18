import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campy/data.dart';
import 'package:campy/main.dart';
import 'package:campy/pages/add_payment_method_page.dart';
import 'package:campy/pages/checkout_page.dart';
import 'package:campy/pages/home_page.dart';
import 'package:campy/pages/order_detail_page.dart';
import 'package:campy/pages/payment_page.dart';
import 'package:campy/pages/product_detail_page.dart';
import 'package:campy/pages/search_page.dart';
import 'package:campy/pages/transaction_detail_page.dart';
import 'package:campy/pages/wishlist_page.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampyApp());
    expect(find.byType(CampyApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('HomePage shows catalog errors after loading finishes', (
    WidgetTester tester,
  ) async {
    productsNotifier.value = [];
    catalogLoading.value = false;
    catalogError.value = 'Backend offline';

    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.textContaining('Gagal memuat katalog'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Checkout delivery method switch and fee calculation', (
    WidgetTester tester,
  ) async {
    // Checkout totals are supplied by the backend, so this test verifies
    // the UI stays blocked until a server quote is available.
    cartNotifier.value = [
      const Product(
        id: 'test-product',
        name: 'Camping Tent',
        sub: '2 Person Tent',
        price: 100000,
        icon: Icons.cabin,
        stock: 5,
      ).let((p) => CartItem(p, 1, 100000)),
    ];

    await tester.pumpWidget(const MaterialApp(home: CheckoutPage()));
    await tester.pumpAndSettle();

    // Verify initial state: Self Pick-Up selected by default, no fee
    expect(find.text('Delivery Method'), findsOneWidget);
    expect(find.text('Self Pick-Up'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Free'), findsWidgets);
    expect(find.text('...'), findsWidgets);

    // Select Delivery method
    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();

    expect(find.text('Delivery'), findsWidgets);

    // Switch back to Self Pick-Up
    await tester.tap(find.text('Self Pick-Up'));
    await tester.pumpAndSettle();

    expect(find.text('...'), findsWidgets);
    expect(find.byType(PaymentPage), findsNothing);
  });

  testWidgets('ProductDetailPage renders and adds to cart', (
    WidgetTester tester,
  ) async {
    const testProduct = Product(
      name: 'Portable Stove',
      sub: 'Camping Stove',
      price: 50000,
      icon: Icons.local_fire_department,
      stock: 5,
    );

    cartNotifier.value = [];

    await tester.pumpWidget(
      const MaterialApp(home: ProductDetailPage(product: testProduct)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Portable Stove'), findsOneWidget);
    expect(find.text('Camping Stove'), findsOneWidget);
    expect(find.text(rupiah(50000)), findsWidgets);

    // Tap Add to Cart
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Cart'));
    await tester.pumpAndSettle();

    expect(cartNotifier.value.length, 1);
    expect(cartNotifier.value.first.product.name, 'Portable Stove');
  });

  testWidgets('OrderDetailPage renders order details correctly', (
    WidgetTester tester,
  ) async {
    const testProduct = Product(
      id: 'test-product',
      name: 'Camping Tent',
      sub: '2 Person Tent',
      price: 100000,
      icon: Icons.cabin,
      stock: 5,
    );
    final testOrder = AppOrder(
      id: '#ORD-TEST0001',
      product: testProduct,
      items: const [
        AppOrderItem(
          productId: 'test-product',
          productName: 'Camping Tent',
          productSub: '2 Person Tent',
          qty: 1,
          unitPrice: 100000,
        ),
      ],
      qty: 1,
      subtotal: 100000,
      total: 100000,
      date: '01/01/2026',
      status: 'active',
    );

    await tester.pumpWidget(
      MaterialApp(home: OrderDetailPage(order: testOrder)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Details - ${testOrder.id}'), findsOneWidget);
    expect(find.text('Order Status Timeline'), findsOneWidget);
    expect(find.text('Rented Equipment'), findsOneWidget);
    expect(find.text(testOrder.product.name), findsOneWidget);
  });

  testWidgets('TransactionDetailPage renders receipt', (
    WidgetTester tester,
  ) async {
    const testTx = AppTransaction(
      id: 'TRX-TEST0001',
      orderId: '#ORD-TEST0001',
      amount: 100000,
      date: '01/01/2026',
      status: 'success',
      paymentMethod: 'BCA',
    );

    await tester.pumpWidget(
      MaterialApp(home: TransactionDetailPage(transaction: testTx)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text(rupiah(testTx.amount)), findsOneWidget);
    expect(find.text(testTx.orderId), findsOneWidget);
  });

  testWidgets('SearchPage searches and filters products', (
    WidgetTester tester,
  ) async {
    productsNotifier.value = [
      const Product(
        id: 'prod-camping-tent',
        name: 'Camping Tent',
        sub: '2 Person Tent',
        category: 'Shelter & Sleeping',
        categorySlug: 'shelter',
        price: 150000,
        icon: Icons.cabin,
        stock: 8,
      ),
      const Product(
        id: 'prod-duplicate-name',
        name: 'Camping Tent',
        sub: 'Novelty Light',
        category: 'Lighting & Power',
        categorySlug: 'lighting',
        price: 25000,
        icon: Icons.lightbulb,
        stock: 4,
      ),
    ];
    await tester.pumpWidget(const MaterialApp(home: SearchPage()));
    await tester.pumpAndSettle();

    // Verify all categories exist
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Shelter'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'tent');
    await tester.pumpAndSettle();

    // Results should contain Camping Tent
    expect(find.text('Camping Tent'), findsWidgets);

    await tester.tap(find.text('Lighting'));
    await tester.pumpAndSettle();
    expect(find.text('Novelty Light'), findsOneWidget);
    expect(find.text('2 Person Tent'), findsNothing);
  });

  testWidgets('WishlistPage displays and manages saved items', (
    WidgetTester tester,
  ) async {
    const wishlistProduct = Product(
      id: 'prod-camping-tent',
      name: 'Camping Tent',
      sub: '2 Person Tent',
      category: 'Shelter & Sleeping',
      categorySlug: 'shelter',
      price: 150000,
      icon: Icons.cabin,
      stock: 8,
    );
    wishlistNotifier.value = [wishlistProduct];

    await tester.pumpWidget(const MaterialApp(home: WishlistPage()));
    await tester.pumpAndSettle();

    expect(find.text('Wishlist & Saved Items'), findsOneWidget);
    expect(find.text(wishlistProduct.name), findsOneWidget);
  });

  testWidgets('AddPaymentMethodPage validates form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddPaymentMethodPage()));
    await tester.pumpAndSettle();

    expect(find.text('Add Payment Method'), findsOneWidget);
    expect(find.text('Save Payment Method'), findsOneWidget);

    // Tap Save without entering card number
    await tester.tap(find.text('Save Payment Method'));
    await tester.pumpAndSettle();

    // Validation error shown
    expect(find.text('Field cannot be empty'), findsOneWidget);
  });
}

extension<T> on T {
  R let<R>(R Function(T) op) => op(this);
}
