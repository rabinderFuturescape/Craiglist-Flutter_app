import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/tailwind_utils.dart';
import '../../../../core/presentation/widgets/layout/app_bar_widget.dart';
import '../../../../core/presentation/widgets/layout/app_drawer.dart';
import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../bloc/cart_bloc.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBarWidget(
        title: 'Shopping Cart',
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<CartBloc>().add(ClearCart());
            },
            icon: const Icon(Icons.remove_shopping_cart),
            label: const Text('Clear'),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: Tailwind.spacing4),
                  Text(
                    'Your cart is empty',
                    style: Tailwind.textLg(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Tailwind.spacing2),
                  Text(
                    'Add some products to your cart',
                    style: Tailwind.textBase(context).copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(Tailwind.spacing4),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Dismissible(
                      key: Key(item.product.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        context
                            .read<CartBloc>()
                            .add(RemoveFromCart(productId: item.product.id));
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding:
                            const EdgeInsets.only(right: Tailwind.spacing4),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        margin:
                            const EdgeInsets.only(bottom: Tailwind.spacing3),
                        child: Padding(
                          padding: const EdgeInsets.all(Tailwind.spacing3),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: Tailwind.borderRadiusLg,
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Theme.of(context).cardColor,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Theme.of(context).cardColor,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported,
                                              size: 24,
                                              color: Theme.of(context)
                                                  .disabledColor,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'No image',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: Tailwind.spacing3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style:
                                          Tailwind.textBase(context).copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: Tailwind.spacing1),
                                    Text(
                                      '\$${item.product.price.toStringAsFixed(2)}',
                                      style: Tailwind.textSm(context).copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            UpdateQuantity(
                                              productId: item.product.id,
                                              quantity: item.quantity - 1,
                                            ),
                                          );
                                    },
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: Tailwind.textBase(context),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            UpdateQuantity(
                                              productId: item.product.id,
                                              quantity: item.quantity + 1,
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: Tailwind.spacing4,
                  right: Tailwind.spacing4,
                  top: Tailwind.spacing4,
                  bottom:
                      MediaQuery.of(context).padding.bottom + Tailwind.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Tailwind.textLg(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${state.totalAmount.toStringAsFixed(2)}',
                          style: Tailwind.textLg(context).copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Tailwind.spacing3),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is! Authenticated) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocListener<AuthBloc, AuthState>(
                                  listener: (context, state) {
                                    if (state is Authenticated) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckoutPage(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const SignInPage(),
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutPage(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: Tailwind.spacing4,
                          ),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: Tailwind.borderRadiusLg,
                          ),
                        ),
                        child: Text(
                          'Proceed to Checkout',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Looking For',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/products');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/looking-for');
          } else if (index == 2) {
            // Already on Cart page
          }
        },
      ),
    );
  }
}
