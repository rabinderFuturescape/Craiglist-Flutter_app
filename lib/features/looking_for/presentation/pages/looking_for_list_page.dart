import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/layout/app_bar_widget.dart';
import '../../../../core/presentation/widgets/layout/app_drawer.dart';
import '../../../../core/presentation/widgets/layout/empty_state.dart';
import '../../../../core/presentation/widgets/layout/error_display.dart';
import '../../../../core/presentation/widgets/layout/loading_indicator.dart';
import '../bloc/looking_for_bloc.dart';
import '../bloc/looking_for_event.dart';
import '../bloc/looking_for_state.dart';
import '../widgets/looking_for_item_card.dart';
import 'create_looking_for_page.dart';

/// Page to display a list of "Looking For" items
class LookingForListPage extends StatefulWidget {
  const LookingForListPage({Key? key}) : super(key: key);

  @override
  State<LookingForListPage> createState() => _LookingForListPageState();
}

class _LookingForListPageState extends State<LookingForListPage> {
  @override
  void initState() {
    super.initState();
    // Load the "Looking For" items when the page is initialized
    context.read<LookingForBloc>().add(const LoadLookingForItems());
    // Check for expired items
    context.read<LookingForBloc>().add(const CheckExpiredItemsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const AppBarWidget(
        title: 'Looking For Items',
      ),
      body: BlocConsumer<LookingForBloc, LookingForState>(
        buildWhen: (previous, current) => current is! ExpiredItemsChecked && current is! LookingForItemDeleted,
        listener: (context, state) {
          // Show a snackbar when items are expired
          if (state is ExpiredItemsChecked && state.expiredCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.expiredCount} expired items have been removed'),
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Show a snackbar when an item is deleted
          if (state is LookingForItemDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );
            // Reload the items
            context.read<LookingForBloc>().add(const LoadLookingForItems());
          }
        },
        builder: (context, state) {
          // Show loading indicator
          if (state is LookingForInitial || state is LookingForLoading) {
            return const LoadingIndicator(message: 'Loading items...');
          }

          // Show error message
          if (state is LookingForError) {
            return ErrorDisplay(
              message: state.message,
              buttonText: 'Try Again',
              onRetry: () {
                context.read<LookingForBloc>().add(const LoadLookingForItems());
              },
            );
          }

          // Show the list of items
          if (state is LookingForLoaded) {
            final items = state.items;

            // Show empty state if there are no items
            if (items.isEmpty) {
              return EmptyState(
                message: 'No "Looking For" items found',
                buttonText: 'Create a Request',
                icon: Icons.search_off,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateLookingForPage(),
                    ),
                  ).then((_) {
                    // Reload the items when returning from the create page
                    if (mounted) {
                      context.read<LookingForBloc>().add(const LoadLookingForItems());
                    }
                  });
                },
              );
            }

            // Show the list of items
            return Stack(
              children: [
                // List of items
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return LookingForItemCard(
                      item: item,
                      onDelete: () {
                        // Show confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Item'),
                            content: const Text(
                              'Are you sure you want to delete this item?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<LookingForBloc>().add(
                                    DeleteLookingForItemEvent(item.id),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateLookingForPage(
                              editItem: item,
                            ),
                          ),
                        ).then((_) {
                          // Reload the items when returning from the edit page
                          if (mounted) {
                            context.read<LookingForBloc>().add(const LoadLookingForItems());
                          }
                        });
                      },
                    );
                  },
                ),

                // Floating action button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateLookingForPage(),
                        ),
                      ).then((_) {
                        // Reload the items when returning from the create page
                        if (mounted) {
                          context.read<LookingForBloc>().add(const LoadLookingForItems());
                        }
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          }

          // Default case
          return const SizedBox();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            // Already on Looking For page
          } else if (index == 2) {
            Navigator.pushNamed(context, '/cart');
          }
        },
      ),
    );
  }
}
