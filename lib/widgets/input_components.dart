import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vaidhya_front_end/theme/app_theme.dart';

/// A collection of reusable input components for the Vaidhya application

// ================ TEXT INPUT ================
class VaidhyaTextInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;

  const VaidhyaTextInput({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          enabled: enabled,
          focusNode: focusNode,
          onChanged: onChanged,
          onTap: onTap,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? AppTheme.white : AppTheme.lightGrey,
          ),
        ),
      ],
    );
  }
}

// ================ NUMBER INPUT ================
class VaidhyaNumberInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLength;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool allowDecimal;
  final bool allowNegative;

  const VaidhyaNumberInput({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.allowDecimal = false,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: TextInputType.numberWithOptions(
            decimal: allowDecimal,
            signed: allowNegative,
          ),
          maxLength: maxLength,
          enabled: enabled,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          inputFormatters: [
            if (!allowDecimal && !allowNegative)
              FilteringTextInputFormatter.digitsOnly
            else if (!allowDecimal && allowNegative)
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
            if (allowDecimal && !allowNegative)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            if (allowDecimal && allowNegative)
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? AppTheme.white : AppTheme.lightGrey,
          ),
        ),
      ],
    );
  }
}

// ================ TEXTAREA INPUT ================
class VaidhyaTextArea extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  const VaidhyaTextArea({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 5,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLength: maxLength,
          enabled: enabled,
          focusNode: focusNode,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? AppTheme.white : AppTheme.lightGrey,
          ),
        ),
      ],
    );
  }
}

// ================ DROPDOWN WITH SEARCH ================
class VaidhyaDropdown<T> extends StatefulWidget {
  final String label;
  final String? hintText;
  final List<DropdownItem<T>> items;
  final DropdownItem<T>? value;
  final void Function(DropdownItem<T>?)? onChanged;
  final bool enabled;
  final bool showSearchBox;
  final String searchHintText;

  const VaidhyaDropdown({
    super.key,
    required this.label,
    this.hintText,
    required this.items,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.showSearchBox = false,
    this.searchHintText = 'Search...',
  });

  @override
  State<VaidhyaDropdown<T>> createState() => _VaidhyaDropdownState<T>();
}

class _VaidhyaDropdownState<T> extends State<VaidhyaDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  bool _isDropdownOpen = false;
  List<DropdownItem<T>> _filteredItems = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _filteredItems = widget.items;
    _searchController.clear();
    _isDropdownOpen = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isDropdownOpen = false;
    setState(() {});
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.items;
      });
    } else {
      setState(() {
        _filteredItems =
            widget.items
                .where(
                  (item) =>
                      item.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      });
    }
    _updateOverlay();
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _selectItem(DropdownItem<T> item) {
    if (widget.onChanged != null) {
      widget.onChanged!(item);
    }
    _closeDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    minWidth: size.width,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.grey),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showSearchBox)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: widget.searchHintText,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: _filterItems,
                          ),
                        ),
                      Flexible(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected =
                                widget.value?.value == item.value;
                            return InkWell(
                              onTap: () => _selectItem(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color:
                                    isSelected
                                        ? AppTheme.lightBlue.withOpacity(0.2)
                                        : null,
                                child: Row(
                                  children: [
                                    if (item.icon != null) ...[
                                      item.icon!,
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(child: Text(item.label)),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check,
                                        color: AppTheme.primaryBlue,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isDropdownOpen ? AppTheme.primaryBlue : AppTheme.grey,
                  width: _isDropdownOpen ? 2 : 1,
                ),
                color: widget.enabled ? AppTheme.white : AppTheme.lightGrey,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value?.label ??
                          widget.hintText ??
                          'Select an option',
                      style: TextStyle(
                        color:
                            widget.value != null
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    _isDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: AppTheme.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownItem<T> {
  final String label;
  final T value;
  final Widget? icon;

  DropdownItem({required this.label, required this.value, this.icon});
}

// ================ OTP INPUT ================
class VaidhyaOtpInput extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;
  final void Function(String)? onChanged;
  final bool obscureText;
  final bool enabled;

  const VaidhyaOtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
  });

  @override
  State<VaidhyaOtpInput> createState() => _VaidhyaOtpInputState();
}

class _VaidhyaOtpInputState extends State<VaidhyaOtpInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late String _otp;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _otp = '';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged() {
    _otp = _controllers.map((controller) => controller.text).join();
    if (widget.onChanged != null) {
      widget.onChanged!(_otp);
    }
    if (_otp.length == widget.length) {
      widget.onCompleted(_otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 50,
          height: 60,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.enabled ? AppTheme.white : AppTheme.lightGrey,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move to next field
                if (index < widget.length - 1) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  _focusNodes[index].unfocus();
                }
              }
              _onOtpChanged();
            },
          ),
        ),
      ),
    );
  }
}

// ================ USAGE EXAMPLE ================
// This is an example of how to use these components
class InputComponentsExample extends StatefulWidget {
  const InputComponentsExample({super.key});

  @override
  State<InputComponentsExample> createState() => _InputComponentsExampleState();
}

class _InputComponentsExampleState extends State<InputComponentsExample> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _textAreaController = TextEditingController();
  DropdownItem<String>? _selectedItem;
  String _otpValue = '';

  final List<DropdownItem<String>> _dropdownItems = [
    DropdownItem(
      label: 'Option 1',
      value: 'option1',
      icon: const Icon(Icons.person),
    ),
    DropdownItem(
      label: 'Option 2',
      value: 'option2',
      icon: const Icon(Icons.home),
    ),
    DropdownItem(
      label: 'Option 3',
      value: 'option3',
      icon: const Icon(Icons.settings),
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    _textAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Components')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input
            VaidhyaTextInput(
              label: 'Name',
              hintText: 'Enter your name',
              controller: _textController,
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 24),

            // Number Input
            VaidhyaNumberInput(
              label: 'Age',
              hintText: 'Enter your age',
              controller: _numberController,
              allowDecimal: false,
            ),
            const SizedBox(height: 24),

            // Dropdown
            VaidhyaDropdown<String>(
              label: 'Select Option',
              hintText: 'Choose an option',
              items: _dropdownItems,
              value: _selectedItem,
              showSearchBox: true,
              onChanged: (item) {
                setState(() {
                  _selectedItem = item;
                });
              },
            ),
            const SizedBox(height: 24),

            // OTP Input
            const Text(
              'OTP',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            VaidhyaOtpInput(
              length: 6,
              onCompleted: (otp) {
                setState(() {
                  _otpValue = otp;
                });
                print('OTP Completed: $otp');
              },
            ),
            const SizedBox(height: 8),
            Text('OTP Value: $_otpValue'),
            const SizedBox(height: 24),

            // Text Area
            VaidhyaTextArea(
              label: 'Description',
              hintText: 'Enter a description',
              controller: _textAreaController,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  print('Text: ${_textController.text}');
                  print('Number: ${_numberController.text}');
                  print('Dropdown: ${_selectedItem?.value}');
                  print('OTP: $_otpValue');
                  print('Text Area: ${_textAreaController.text}');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
