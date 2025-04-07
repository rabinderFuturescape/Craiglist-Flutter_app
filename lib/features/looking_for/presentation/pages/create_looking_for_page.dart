import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/presentation/widgets/layout/app_bar_widget.dart';
import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/presentation/widgets/inputs/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/looking_for_item.dart';
import '../bloc/looking_for_bloc.dart';
import '../bloc/looking_for_event.dart';
import '../bloc/looking_for_state.dart';

/// Page to create or edit a "Looking For" item
class CreateLookingForPage extends StatefulWidget {
  final LookingForItem? editItem;

  const CreateLookingForPage({
    Key? key,
    this.editItem,
  }) : super(key: key);

  @override
  State<CreateLookingForPage> createState() => _CreateLookingForPageState();
}

class _CreateLookingForPageState extends State<CreateLookingForPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactInfoController = TextEditingController();
  
  List<String> _selectedCategories = [];
  List<String> _selectedConditions = [];
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  
  bool _isLoading = false;
  
  // Available categories
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
  
  // Available conditions
  final List<String> _availableConditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Any Condition',
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing an existing item, populate the form
    if (widget.editItem != null) {
      _titleController.text = widget.editItem!.title;
      _descriptionController.text = widget.editItem!.description;
      _budgetController.text = widget.editItem!.maxBudget.toString();
      _locationController.text = widget.editItem!.location ?? '';
      _contactInfoController.text = widget.editItem!.contactInfo ?? '';
      _selectedCategories = List.from(widget.editItem!.categories);
      _selectedConditions = List.from(widget.editItem!.preferredConditions ?? []);
      _expiryDate = widget.editItem!.expiryDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.editItem != null ? 'Edit Request' : 'Create Request',
      ),
      body: BlocListener<LookingForBloc, LookingForState>(
        listener: (context, state) {
          if (state is LookingForItemCreated || state is LookingForItemUpdated) {
            setState(() {
              _isLoading = false;
            });
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.editItem != null
                      ? 'Request updated successfully'
                      : 'Request created successfully',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Navigate back
            Navigator.pop(context);
          } else if (state is LookingForError) {
            setState(() {
              _isLoading = false;
            });
            
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is LookingForLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'What are you looking for?',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.length < 5) {
                      return 'Title must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description field
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Provide details about what you\'re looking for',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 20) {
                      return 'Description must be at least 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Budget field
                AppTextField(
                  controller: _budgetController,
                  label: 'Maximum Budget',
                  hint: 'Enter your maximum budget',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget';
                    }
                    final budget = double.tryParse(value);
                    if (budget == null || budget <= 0) {
                      return 'Please enter a valid budget';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Location field
                AppTextField(
                  controller: _locationController,
                  label: 'Location (Optional)',
                  hint: 'Where are you located?',
                  prefixIcon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                
                // Contact info field
                AppTextField(
                  controller: _contactInfoController,
                  label: 'Contact Information (Optional)',
                  hint: 'Email or phone number',
                  prefixIcon: Icons.contact_mail,
                ),
                const SizedBox(height: 24),
                
                // Categories section
                Text(
                  'Categories',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                      selectedColor: isDarkMode ? AppColors.primaryDark.withAlpha(100) : AppColors.primary.withAlpha(100),
                      checkmarkColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    );
                  }).toList(),
                ),
                if (_selectedCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select at least one category',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Preferred conditions section
                Text(
                  'Preferred Conditions (Optional)',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableConditions.map((condition) {
                    final isSelected = _selectedConditions.contains(condition);
                    return FilterChip(
                      label: Text(condition),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedConditions.add(condition);
                          } else {
                            _selectedConditions.remove(condition);
                          }
                        });
                      },
                      selectedColor: isDarkMode ? AppColors.primaryDark.withAlpha(100) : AppColors.primary.withAlpha(100),
                      checkmarkColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Expiry date section
                Text(
                  'Expiry Date',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectExpiryDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expires on: ${_formatDate(_expiryDate)}',
                          style: AppTextStyles.body1,
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Submit button
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: widget.editItem != null ? 'Update' : 'Create',
                          onPressed: _submitForm,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format a date to a readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show date picker to select expiry date
  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  /// Submit the form
  void _submitForm() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate categories
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create or update the item
    final item = LookingForItem(
      id: widget.editItem?.id ?? const Uuid().v4(),
      userId: authState.userId,
      userName: authState.displayName ?? 'User ${authState.userId}',
      title: _titleController.text,
      description: _descriptionController.text,
      maxBudget: double.parse(_budgetController.text),
      categories: _selectedCategories,
      createdAt: widget.editItem?.createdAt ?? DateTime.now(),
      expiryDate: _expiryDate,
      isActive: true,
      contactInfo: _contactInfoController.text.isNotEmpty ? _contactInfoController.text : null,
      location: _locationController.text.isNotEmpty ? _locationController.text : null,
      preferredConditions: _selectedConditions.isNotEmpty ? _selectedConditions : null,
    );
    
    // Dispatch event to create or update the item
    if (widget.editItem != null) {
      context.read<LookingForBloc>().add(UpdateLookingForItemEvent(item));
    } else {
      context.read<LookingForBloc>().add(CreateLookingForItemEvent(item));
    }
  }
}
