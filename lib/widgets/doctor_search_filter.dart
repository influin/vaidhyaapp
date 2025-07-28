import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class DoctorSearchFilter extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final List<String> specialties;
  final String selectedSpecialty;
  final Function(String) onSpecialtyChanged;
  final double minRating;
  final Function(double) onRatingChanged;
  final bool showAvailableOnly;
  final Function(bool) onAvailabilityChanged;
  final RangeValues? priceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final List<String> recentSearches;

  // New properties
  final String consultationType;
  final Function(String) onConsultationTypeChanged;
  final String sortBy;
  final Function(String) onSortByChanged;
  final bool availableNow;
  final Function(bool) onAvailableNowChanged;

  const DoctorSearchFilter({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.specialties,
    required this.selectedSpecialty,
    required this.onSpecialtyChanged,
    required this.minRating,
    required this.onRatingChanged,
    required this.showAvailableOnly,
    required this.onAvailabilityChanged,
    this.priceRange,
    required this.onPriceRangeChanged,
    this.recentSearches = const [],
    required this.consultationType,
    required this.onConsultationTypeChanged,
    required this.sortBy,
    required this.onSortByChanged,
    required this.availableNow,
    required this.onAvailableNowChanged,
  }) : super(key: key);

  @override
  State<DoctorSearchFilter> createState() => _DoctorSearchFilterState();
}

class _DoctorSearchFilterState extends State<DoctorSearchFilter> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus && 
                          widget.recentSearches.isNotEmpty &&
                          _searchController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar with filter button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) {
                          widget.onSearchChanged(value);
                          setState(() {
                            _showSuggestions = _searchFocusNode.hasFocus && 
                                            widget.recentSearches.isNotEmpty &&
                                            value.isEmpty;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search by doctor name or specialty',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      if (_showSuggestions) _buildSuggestions(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter button
              InkWell(
                onTap: () {
                  setState(() {
                    _showFilterPanel = !_showFilterPanel;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _showFilterPanel 
                        ? AppTheme.primaryBlue 
                        : AppTheme.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: _showFilterPanel ? AppTheme.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          // Filter panel
          if (_showFilterPanel) _buildFilterPanel(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          ...widget.recentSearches.map((search) => ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 16),
                title: Text(search),
                onTap: () {
                  _searchController.text = search;
                  widget.onSearchChanged(search);
                  _searchFocusNode.unfocus();
                  setState(() {
                    _showSuggestions = false;
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consultation Type filter
          Text(
            'Consultation Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: widget.consultationType,
                items: ['All Types', 'In-person', 'Video', 'Chat'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.onConsultationTypeChanged(value);
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sort By filter
          Text(
            'Sort By',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: widget.sortBy,
                items: ['Rating', 'Price: Low to High', 'Price: High to Low', 'Distance'].map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.onSortByChanged(value);
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Existing filters (specialty, rating, price range)
          Text(
            'Specialty',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: widget.selectedSpecialty,
                items: widget.specialties.map((specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.onSpecialtyChanged(value);
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Rating filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum Rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${widget.minRating.toInt()}+',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          Slider(
            value: widget.minRating,
            min: 0,
            max: 5,
            divisions: 5,
            label: widget.minRating.toString(),
            onChanged: (value) {
              widget.onRatingChanged(value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Price range filter
          if (widget.priceRange != null) ...[  
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Range',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '₹${widget.priceRange!.start.toInt()} - ₹${widget.priceRange!.end.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: widget.priceRange!,
              min: 0,
              max: 5000,
              divisions: 50,
              labels: RangeLabels(
                '₹${widget.priceRange!.start.toInt()}',
                '₹${widget.priceRange!.end.toInt()}',
              ),
              onChanged: (values) {
                widget.onPriceRangeChanged(values);
              },
            ),
            
            const SizedBox(height: 16),
          ],
          
          // Availability filter
          Row(
            children: [
              Checkbox(
                value: widget.showAvailableOnly,
                onChanged: (value) {
                  if (value != null) {
                    widget.onAvailabilityChanged(value);
                  }
                },
                activeColor: AppTheme.primaryBlue,
              ),
              const Text('Show available doctors only'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Availability timing filter
          Row(
            children: [
              Checkbox(
                value: widget.availableNow,
                onChanged: (value) {
                  if (value != null) {
                    widget.onAvailableNowChanged(value);
                  }
                },
                activeColor: AppTheme.primaryBlue,
              ),
              const Text('Available now'),
            ],
          ),
          
          // Existing availability filter
          Row(
            children: [
              Checkbox(
                value: widget.showAvailableOnly,
                onChanged: (value) {
                  if (value != null) {
                    widget.onAvailabilityChanged(value);
                  }
                },
                activeColor: AppTheme.primaryBlue,
              ),
              const Text('Show available doctors only'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Apply and Reset buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Reset all filters
                    widget.onSearchChanged(''); // Reset search query
                    widget.onSpecialtyChanged('All Specialties');
                    widget.onRatingChanged(0);
                    widget.onAvailabilityChanged(false);
                    widget.onConsultationTypeChanged('All Types'); // Reset consultation type
                    widget.onSortByChanged('Rating'); // Reset sort by
                    widget.onAvailableNowChanged(false); // Reset available now
                    if (widget.priceRange != null) {
                      widget.onPriceRangeChanged(const RangeValues(500, 2000));
                    }
                    // Clear search text field
                    _searchController.clear();
                    setState(() {
                      _showFilterPanel = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryBlue),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showFilterPanel = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}