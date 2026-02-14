import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../services/hive_service.dart';

class ProductEditScreen extends StatefulWidget {
  final HiveService hiveService;
  final Product? existing;

  const ProductEditScreen({
    super.key,
    required this.hiveService,
    this.existing,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.existing;
    if (product != null) {
      _titleController.text = product.title;
      _imageController.text = product.imagePath;
      _priceController.text = product.price.toString();
      _locationController.text = product.location;
      _reviewsController.text = product.reviewsCount.toString();
      _descriptionController.text = product.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _reviewsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final product = Product(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      imagePath: _imageController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      location: _locationController.text.trim(),
      reviewsCount: int.parse(_reviewsController.text.trim()),
      description: _descriptionController.text.trim(),
      isLiked: widget.existing?.isLiked ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await widget.hiveService.addOrUpdateProduct(product);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Добавить товар' : 'Редактировать товар'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField(
              controller: _titleController,
              label: 'Название',
              validator: _requiredValidator,
            ),
            _buildField(
              controller: _imageController,
              label: 'URL изображения или путь',
              validator: _requiredValidator,
            ),
            _buildField(
              controller: _priceController,
              label: 'Цена',
              keyboardType: TextInputType.number,
              validator: (value) => _numberValidator(value, isDouble: true),
            ),
            _buildField(
              controller: _locationController,
              label: 'Расположение',
              validator: _requiredValidator,
            ),
            _buildField(
              controller: _reviewsController,
              label: 'Количество отзывов',
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            _buildField(
              controller: _descriptionController,
              label: 'Описание',
              maxLines: 4,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.existing == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Поле обязательно';
    }
    return null;
  }

  String? _numberValidator(String? value, {bool isDouble = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'Поле обязательно';
    }
    return isDouble
        ? double.tryParse(value.trim()) == null
            ? 'Введите число'
            : null
        : int.tryParse(value.trim()) == null
            ? 'Введите целое число'
            : null;
  }
}

