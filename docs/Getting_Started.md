# Getting Started with Craigslist Flutter App

This guide will help you get started with the Craigslist Flutter App development.

## Prerequisites

Before you begin, make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (version 3.0.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- [Git](https://git-scm.com/downloads)
- [Docker](https://www.docker.com/products/docker-desktop/) and [Docker Compose](https://docs.docker.com/compose/install/) (for local Supabase development)

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/rabinderFuturescape/Craiglist-Flutter_app.git
   cd Craiglist-Flutter_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Start the Supabase local development environment**

   ```bash
   docker-compose up -d
   ```

   This will start the following services:
   - PostgreSQL database
   - Supabase Studio (http://localhost:3000)
   - Supabase Auth
   - Supabase Storage
   - Supabase Realtime

4. **Apply database migrations**

   Access Supabase Studio at http://localhost:3000 and run the SQL scripts in the `supabase/migrations` directory.

5. **Run the app**

   ```bash
   flutter run
   ```

## Project Structure

The project follows Clean Architecture principles with the following structure:

```
lib/
├── core/                  # Core functionality
├── features/              # App features
│   ├── auth/              # Authentication
│   ├── product/           # Product listings
│   ├── looking_for/       # Looking for items
│   ├── cart/              # Shopping cart
│   └── notification/      # Notifications
└── main.dart              # App entry point
```

## Key Features

- **Authentication**: User registration, login, and profile management
- **Product Listings**: Browse, search, and filter products
- **Looking For Items**: Post and browse requests for items
- **Shopping Cart**: Add products to cart and checkout
- **Notifications**: Real-time notifications for users

## Development Workflow

1. **Create a new branch for your feature or bug fix**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**

   Follow the existing code style and architecture patterns.

3. **Test your changes**

   ```bash
   flutter test
   ```

4. **Commit your changes**

   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

5. **Push your changes**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a pull request**

   Go to the GitHub repository and create a pull request for your branch.

## Supabase Integration

The app uses Supabase for backend services:

- **Authentication**: Supabase Auth with email/password
- **Database**: PostgreSQL with Row Level Security
- **Storage**: Supabase Storage for images
- **Realtime**: Supabase Realtime for notifications

### Supabase Client

The app uses a custom `AppSupabaseClient` class to interact with Supabase:

```dart
// Initialize Supabase
await AppSupabaseClient.initialize();

// Get Supabase client instance
final supabaseClient = AppSupabaseClient.instance;

// Use Supabase client
final user = supabaseClient.auth.currentUser;
```

## UI Structure

The app has two main sections:

1. **Offer to Sell**: For product listings
2. **Looking to Buy**: For buyer requests

These are implemented as tabs in the `MainNavigationPage`.

## State Management

The app uses the BLoC pattern for state management:

```dart
// Create a BLoC
final productBloc = ProductBloc(productRepository: productRepository);

// Add an event
productBloc.add(const LoadProducts());

// Listen to state changes
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state is ProductLoading) {
      return const LoadingIndicator();
    } else if (state is ProductLoaded) {
      return ProductList(products: state.products);
    } else if (state is ProductError) {
      return ErrorDisplay(message: state.message);
    }
    return const SizedBox();
  },
)
```

## Additional Resources

- [Developer Guide](./Developer_Guide.md): Comprehensive documentation for developers
- [Flutter Documentation](https://flutter.dev/docs): Official Flutter documentation
- [Supabase Documentation](https://supabase.io/docs): Official Supabase documentation
- [BLoC Documentation](https://bloclibrary.dev/): Official BLoC documentation
