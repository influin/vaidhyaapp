import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;
  final Map<String, String> addressComponents;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    required this.addressComponents,
  });
}

class GooglePlacesAddressInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(PlaceDetails) onPlaceSelected;
  final String hint;
  final InputDecoration? decoration;

  const GooglePlacesAddressInput({
    Key? key,
    required this.controller,
    required this.onPlaceSelected,
    this.hint = 'Search for an address',
    this.decoration,
  }) : super(key: key);

  @override
  State<GooglePlacesAddressInput> createState() =>
      _GooglePlacesAddressInputState();
}

class _GooglePlacesAddressInputState extends State<GooglePlacesAddressInput> {
  final _uuid = Uuid();
  String _sessionToken = '';
  List<dynamic> _placesList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (widget.controller.text.isNotEmpty) {
      if (_sessionToken.isEmpty) {
        setState(() {
          _sessionToken = _uuid.v4();
        });
      }
      // Increase delay to 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && widget.controller.text.isNotEmpty) {
          _getSuggestions(widget.controller.text);
        }
      });
    } else {
      setState(() {
        _placesList = [];
      });
    }
  }

  void _getSuggestions(String input) async {
    // Replace with your actual API key
    const String apiKey = "AIzaSyB7lz_JZ3yHx6DPrHgiHcqRUgaFnkhoE3k";

    // Add these parameters
    const String region = "in"; // For India, change as needed
    const String language = "en";

    setState(() {
      _isLoading = true;
    });

    try {
      final String baseUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      final String request =
          '$baseUrl?input=$input&key=$apiKey&sessiontoken=$_sessionToken&region=$region&language=$language';

      // Add more debug info
      print("Request URL: $request");

      final response = await http.get(Uri.parse(request));
      final data = json.decode(response.body);

      // Add debug prints here where response and data are in scope
      print("API response status: ${response.statusCode}");
      print("Predictions count: ${data['predictions']?.length ?? 0}");

      if (response.statusCode == 200) {
        setState(() {
          _placesList = data['predictions'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching place suggestions: $e');
    }
  }

  void _getPlaceDetails(String placeId) async {
    // Replace with your actual API key
    const String apiKey = "AIzaSyB7lz_JZ3yHx6DPrHgiHcqRUgaFnkhoE3k";

    setState(() {
      _isLoading = true;
    });

    try {
      final String baseUrl =
          'https://maps.googleapis.com/maps/api/place/details/json';
      final String request =
          '$baseUrl?place_id=$placeId&key=$apiKey&sessiontoken=$_sessionToken';

      final response = await http.get(Uri.parse(request));
      final data = json.decode(response.body);

      // More detailed debug prints
      print("API response status: ${response.statusCode}");
      print("API response body: ${response.body}");
      print("Predictions count: ${data['predictions']?.length ?? 0}");
      print("Status message: ${data['status']}");

      if (response.statusCode == 200 && data['status'] == 'OK') {
        final details = data['result'];
        final placeDetails = PlaceDetails(
          placeId: details['place_id'],
          name: details['name'] ?? '',
          formattedAddress: details['formatted_address'] ?? '',
          lat: details['geometry']['location']['lat'],
          lng: details['geometry']['location']['lng'],
          addressComponents: _parseAddressComponents(
            details['address_components'],
          ),
        );

        // Print all place details
        print('Selected Place Details:');
        print('Place ID: ${placeDetails.placeId}');
        print('Name: ${placeDetails.name}');
        print('Formatted Address: ${placeDetails.formattedAddress}');
        print('Latitude: ${placeDetails.lat}');
        print('Longitude: ${placeDetails.lng}');
        print('Address Components:');
        placeDetails.addressComponents.forEach((key, value) {
          print('  $key: $value');
        });

        widget.controller.text = placeDetails.formattedAddress;
        widget.onPlaceSelected(placeDetails);

        setState(() {
          _placesList = [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching place details: $e');
    }
  }

  Map<String, String> _parseAddressComponents(List<dynamic> components) {
    final Map<String, String> result = {};
  
    for (var component in components) {
      final List<dynamic> types = component['types'];
      if (types.contains('street_number')) {
        result['street_number'] = component['long_name'];
      } else if (types.contains('route')) {
        result['route'] = component['long_name'];
      } else if (types.contains('locality')) {
        result['city'] = component['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        result['state'] = component['long_name'];
      } else if (types.contains('country')) {
        result['country'] = component['long_name'];
      } else if (types.contains('postal_code')) { // Changed from postalCode to postal_code
        result['postal_code'] = component['long_name']; // Changed from postalCode to postal_code
      }
    }
  
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          decoration:
              widget.decoration ??
              InputDecoration(
                labelText: widget.hint,
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : widget.controller.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            widget.controller.clear();
                            setState(() {
                              _placesList = [];
                            });
                          },
                        )
                        : null,
                border: const OutlineInputBorder(),
              ),
        ),
        // Removed the debug text "Suggestions: ${_placesList.length}"
        if (_placesList.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(top: 4),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _placesList.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryBlue,
                  ),
                  title: Text(_placesList[index]['description']),
                  onTap: () {
                    _getPlaceDetails(_placesList[index]['place_id']);
                  },
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}
