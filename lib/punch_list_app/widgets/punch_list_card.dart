import 'package:flutter/material.dart';
import '../models/punch_list_item.dart';
import 'package:intl/intl.dart';

class PunchListCard extends StatelessWidget {
  final PunchListItem item;
  final VoidCallback onTap;

  const PunchListCard({super.key, required this.item, required this.onTap});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'On Hold':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Safety':
        return '⚠️';
      case 'Finishes':
        return '🎨';
      case 'Structural':
        return '🏗️';
      case 'Utilities':
        return '⚡';
      case 'Cleaning':
        return '🧹';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(item.priority);
    final statusColor = _getStatusColor(item.status);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: priorityColor.withOpacity(0.3), width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: priorityColor, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_getCategoryEmoji(item.category),
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (item.description.isNotEmpty)
                  Text(item.description,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                        Icons.location_on, item.location, Colors.blue),
                    _buildInfoChip(
                        Icons.access_time,
                        '${item.estimatedHours?.toStringAsFixed(1) ?? "?"} hrs',
                        Colors.purple),
                    if (item.assignedTo != null)
                      _buildInfoChip(
                          Icons.person, item.assignedTo!, Colors.teal),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: priorityColor)),
                          child: Text(item.priority,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(item.status,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                    if (item.photoPaths.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.photo_camera,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${item.photoPaths.length}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
                if (item.isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                            'Overdue: ${DateFormat('MMM dd').format(item.dueDate!)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
