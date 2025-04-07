import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/counter_bloc.dart';
import 'package:craigslist_flutter_app/features/product/presentation/pages/product_listing_page.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductListingPage()),
          );
        },
        child: const Center(
          child: Text('Tap to navigate to Product Listing'),
        ),
      ),

      // Center(
      //   child: BlocBuilder<CounterBloc, CounterState>(
      //     builder: (context, state) {
      //       if (state is CounterLoading) {
      //         return const CircularProgressIndicator();
      //       }

      //       if (state is CounterError) {
      //         return Text('Error: ${state.message}');
      //       }

      //       if (state is CounterLoaded) {
      //         return GestureDetector(
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => const ProductListingPage(),
      //               ),
      //             );
      //           },
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               const Text(
      //                 'You have pushed the button this many times:',
      //                 style: TextStyle(fontSize: 16),
      //               ),
      //               const SizedBox(height: 8),
      //               Text(
      //                 '${state.counter.value}',
      //                 style: Theme.of(context).textTheme.headlineMedium,
      //               ),
      //               const SizedBox(height: 16),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   FloatingActionButton(
      //                     onPressed: () {
      //                       context
      //                           .read<CounterBloc>()
      //                           .add(DecrementCounterEvent());
      //                     },
      //                     tooltip: 'Decrement',
      //                     child: const Icon(Icons.remove),
      //                   ),
      //                   const SizedBox(width: 16),
      //                   FloatingActionButton(
      //                     onPressed: () {
      //                       //navigate to ProductListingPage
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(
      //                           builder: (context) =>
      //                               const ProductListingPage(),
      //                         ),
      //                       );
      //                       // context.read<CounterBloc>().add(IncrementCounterEvent());
      //                     },
      //                     tooltip: 'Increment',
      //                     child: const Icon(Icons.add),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         );
      //       }

      //       return const Text('Press the button to start');
      //     },
      //   ),
      // ),
    );
  }
}
