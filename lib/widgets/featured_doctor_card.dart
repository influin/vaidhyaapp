import 'package:flutter/material.dart';
import 'package:vaidhya_front_end/theme/app_theme.dart';

class FeaturedDoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;
  final VoidCallback onBookTap;

  const FeaturedDoctorCard({
    Key? key,
    required this.doctor,
    required this.onTap,
    required this.onBookTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Doctor image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 30),
                  ),
                  const SizedBox(width: 12),
                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['specialty'],
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              doctor['rating'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Location
              Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor['city'],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fee
              Row(
                children: [
                  Icon(Icons.currency_rupee, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Fee: ${doctor['fee']}',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Availability
              if (doctor['available'])
                Row(
                  children: [
                    Icon(Icons.access_time, color: AppTheme.primaryGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Available Today',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBookTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}