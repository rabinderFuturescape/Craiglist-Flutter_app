import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/product.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/product_bloc.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/location_picker_dialog.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/ai_image_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../../../../core/models/location_result.dart';
import 'package:intl/intl.dart';

class CreateListingPage extends StatefulWidget {
  final Product? editProduct;

  const CreateListingPage({
    Key? key,
    this.editProduct,
  }) : super(key: key);

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;
  bool _isDraft = false;

  String _selectedCondition = 'New';
  List<String> _selectedCategories = [];
  List<File> _selectedImages = [];
  Map<String, String> _specifications = {};
  final TextEditingController _specKeyController = TextEditingController();
  final TextEditingController _specValueController = TextEditingController();

  final List<String> _conditions = [
    'New',
    'Like New',
    'Very Good',
    'Good',
    'Fair',
    'Poor',
  ];

  final List<String> _availableCategories = [
    'Electronics',
    'Furniture',
    'Home Goods',
    'Clothing',
    'Sports Equipment',
    'Automotive',
    'Books',
    'Toys & Games',
    'Other',
  ];

  String _location = '';
  LatLng? _coordinates;

  final StorageService _storageService = StorageService();
  final AIImageService _aiImageService =
      AIImageService(const String.fromEnvironment('OPENAI_API_KEY'));

  String _aiImagePrompt = '';

  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();

    // Initialize form with existing product data if editing
    if (widget.editProduct != null) {
      _titleController.text = widget.editProduct!.title;
      _descriptionController.text = widget.editProduct!.description;
      _priceController.text = widget.editProduct!.price.toString();
      _locationController.text = widget.editProduct!.location;
      _contactController.text = widget.editProduct!.sellerContact;
      _selectedCondition = widget.editProduct!.condition;
      _selectedCategories = List.from(widget.editProduct!.categories);
      _specifications = Map.from(widget.editProduct!.specifications);
      // Note: We can't initialize _selectedImages with network images
      // They would need to be downloaded first
    } else {
      // Pre-fill contact details from authenticated user
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated && authState.phone != null) {
        _contactController.text = authState.phone!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _specKeyController.dispose();
    _specValueController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _addSpecification() {
    if (_specKeyController.text.isNotEmpty &&
        _specValueController.text.isNotEmpty) {
      setState(() {
        _specifications[_specKeyController.text] = _specValueController.text;
        _specKeyController.clear();
        _specValueController.clear();
      });
    }
  }

  void _removeSpecification(String key) {
    setState(() {
      _specifications.remove(key);
    });
  }

  Future<List<String>> _uploadImages() async {
    final List<String> uploadedUrls = [];
    for (final image in _selectedImages) {
      try {
        final url = await _storageService.uploadImage(image);
        uploadedUrls.add(url);
      } catch (e) {
        // Handle upload error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
    return uploadedUrls;
  }

  Future<void> _generateAIImage() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in title and description first')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prompt =
          'Generate a high-quality product image for: ${_titleController.text}. ${_descriptionController.text}';
      final imageUrl = await _aiImageService.generateImage(prompt);

      // Download the image and add it to selected images
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/ai_generated_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _selectedImages.add(file);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate image: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _submitForm({bool asDraft = false}) async {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;

      // Only enforce sign-in for publishing, not for drafts
      if (!asDraft && authState is! Authenticated) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text('You need to sign in to publish a listing'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  ).then((_) {
                    // After sign-in, check if user is authenticated and submit the form
                    if (context.read<AuthBloc>().state is Authenticated) {
                      _submitForm(asDraft: asDraft);
                    }
                  });
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        );
        return;
      }

      // Validate expiry date for non-draft listings
      if (!asDraft &&
          _expiryDate != null &&
          _expiryDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expiry date must be in the future')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Upload images first
        final imageUrls = await _uploadImages();

        // Create or update product
        final product = Product(
          id: widget.editProduct?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrls: imageUrls,
          datePosted: widget.editProduct?.datePosted ?? DateTime.now(),
          expiryDate: !asDraft
              ? _expiryDate
              : null, // Only set expiry date for published listings
          sellerId:
              authState is Authenticated ? authState.userId : 'draft_user',
          sellerName: authState is Authenticated
              ? authState.displayName ?? 'User ${authState.userId}'
              : 'Draft User',
          sellerContact: _contactController.text.isNotEmpty
              ? _contactController.text
              : (authState is Authenticated && authState.phone != null)
                  ? authState.phone!
                  : '',
          location: _location,
          coordinates: _coordinates,
          isAvailable: !asDraft,
          condition: _selectedCondition,
          categories: _selectedCategories,
          specifications: _specifications,
          rating: widget.editProduct?.rating ?? 0.0,
          reviewCount: widget.editProduct?.reviewCount ?? 0,
        );

        // Add product to bloc
        context.read<ProductBloc>().add(AddProduct(product));

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(asDraft
                  ? 'Saved as draft'
                  : 'Listing published successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.editProduct != null ? 'Edit Listing' : 'Create Listing'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _submitForm(asDraft: true),
            child: const Text('Save as Draft'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 900;
          final padding = constraints.maxWidth > 600 ? 32.0 : 16.0;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWideScreen)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildMainForm(isWideScreen),
                            ),
                            SizedBox(width: padding),
                            Expanded(
                              flex: 2,
                              child: _buildImageSection(isWideScreen),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildMainForm(isWideScreen),
                            SizedBox(height: padding),
                            _buildImageSection(isWideScreen),
                          ],
                        ),
                      SizedBox(height: padding * 2),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => _submitForm(asDraft: false),
                            child: const Text('Publish Listing'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainForm(bool isWideScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Enter product title',
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter product description',
          ),
          maxLines: 5,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                ),
                items: _conditions.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCondition = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Categories
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Location
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            suffixIcon: IconButton(
              icon: const Icon(Icons.map),
              onPressed: () async {
                final result = await showDialog<LocationResult>(
                  context: context,
                  builder: (context) => const LocationPickerDialog(),
                );
                if (result != null) {
                  setState(() {
                    _location = result.address;
                    _coordinates = result.coordinates;
                    _locationController.text = result.address;
                  });
                }
              },
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please select a location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Contact
        TextFormField(
          controller: _contactController,
          decoration: const InputDecoration(
            labelText: 'Contact Number',
            hintText: 'Enter your contact number',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a contact number';
            }
            return null;
          },
        ),
        if (!_isDraft) ...[
          const SizedBox(height: 16),
          // Expiry Date
          ListTile(
            title: Text(
              'Listing Expiry Date',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              _expiryDate != null
                  ? DateFormat('MMM d, yyyy').format(_expiryDate!)
                  : 'Not set (listing will not expire)',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_expiryDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _expiryDate = null;
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _expiryDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageSection(bool isWideScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // AI Image Generation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Image Generation',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe the image you want to generate...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Store the AI image prompt
                    setState(() {
                      _aiImagePrompt = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateAIImage,
                    icon: const Icon(Icons.auto_awesome),
                    label:
                        Text(_isLoading ? 'Generating...' : 'Generate Image'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Manual Image Upload
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Images',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DragTarget<String>(
                  onAccept: (data) {
                    // Handle dropped files
                    setState(() {
                      _selectedImages.add(File(data));
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Click or drag images here to upload',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Selected Images Preview
        if (_selectedImages.isNotEmpty) ...[
          Text(
            'Selected Images',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Image.file(
                        _selectedImages[index],
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// Comment out incomplete functions
// Future<String> uploadImageToCloud(File imageFile) async {
//   // TODO: Implement image upload to cloud storage
// }

// class ApiService {
//   final int page;
//   final int pageSize;
//   final String baseUrl;
//   final http.Client client;
//   final String? searchQuery;
//   final Map<String, dynamic> filters;

//   ApiService({
//     required this.baseUrl,
//     required this.client,
//   });

//   Future<List<Product>> getProducts({int page = 1, int pageSize = 20}) async {
//     // TODO: Implement API call to get products
//   }
// }

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthenticationService _authService;
//   // TODO: Implement AuthBloc
// }
