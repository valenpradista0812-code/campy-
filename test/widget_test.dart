import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campy/data.dart';
import 'package:campy/main.dart';
import 'package:campy/pages/add_payment_method_page.dart';
import 'package:campy/pages/checkout_page.dart';
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

  testWidgets('Checkout delivery method switch and fee calculation',
      (WidgetTester tester) async {
    // Setup cart with 1 item of price 100,000
    cartNotifier.value = [
      const Product(
        name: 'Camping Tent',
        sub: '2 Person Tent',
        price: 100000,
        icon: Icons.cabin,
      ).let((p) => CartItem(p, 1, 100000)),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: CheckoutPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state: Self Pick-Up selected by default, no fee
    expect(find.text('Delivery Method'), findsOneWidget);
    expect(find.text('Self Pick-Up'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Free'), findsWidgets);
    expect(find.text(rupiah(100000)), findsWidgets); // subtotal & total

    // Select Delivery method
    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();

    // Verify delivery fee is automatically added (+20,000) -> total becomes 120,000
    expect(find.text(rupiah(20000)), findsOneWidget);
    expect(find.text(rupiah(120000)), findsOneWidget);

    // Switch back to Self Pick-Up
    await tester.tap(find.text('Self Pick-Up'));
    await tester.pumpAndSettle();

    // Verify fee is removed -> total is back to 100,000
    expect(find.text(rupiah(100000)), findsWidgets);

    // Switch back to Delivery and proceed to Payment
    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Pay'));
    await tester.pumpAndSettle();

    // Verify PaymentPage opens with the updated total (120,000)
    expect(find.byType(PaymentPage), findsOneWidget);
    expect(find.text(rupiah(120000)), findsOneWidget);
  });

  testWidgets('ProductDetailPage renders and adds to cart',
      (WidgetTester tester) async {
    const testProduct = Product(
      name: 'Portable Stove',
      sub: 'Camping Stove',
      price: 50000,
      icon: Icons.local_fire_department,
    );

    cartNotifier.value = [];

    await tester.pumpWidget(
      const MaterialApp(
        home: ProductDetailPage(product: testProduct),
      ),
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

  testWidgets('OrderDetailPage renders order details correctly',
      (WidgetTester tester) async {
    final testOrder = sampleOrders.first;

    await tester.pumpWidget(
      MaterialApp(
        home: OrderDetailPage(order: testOrder),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Details - ${testOrder.id}'), findsOneWidget);
    expect(find.text('Order Status Timeline'), findsOneWidget);
    expect(find.text('Rented Equipment'), findsOneWidget);
    expect(find.text(testOrder.product.name), findsOneWidget);
  });

  testWidgets('TransactionDetailPage renders receipt',
      (WidgetTester tester) async {
    final testTx = sampleTransactions.first;

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailPage(transaction: testTx),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text(rupiah(testTx.amount)), findsOneWidget);
    expect(find.text(testTx.orderId), findsOneWidget);
  });

  testWidgets('SearchPage searches and filters products',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchPage(),
      ),
    );
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
  });

  testWidgets('WishlistPage displays and manages saved items',
      (WidgetTester tester) async {
    wishlistNotifier.value = [shelterItems[0]];

    await tester.pumpWidget(
      const MaterialApp(
        home: WishlistPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wishlist & Saved Items'), findsOneWidget);
    expect(find.text(shelterItems[0].name), findsOneWidget);
  });

  testWidgets('AddPaymentMethodPage validates form',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddPaymentMethodPage(),
      ),
    );
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
