import 'package:flutter/material.dart';

class RitualStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String stepNumber;
  final bool isDone;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RitualStepCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepNumber,
    required this.isDone,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect + AntiAlias biar efek klik InkWell kepotong rapi di pojokan melengkung
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap, // Aksi tap full satu kotak penuh
            child: Padding(
              padding: const EdgeInsets.all(
                16,
              ), // Padding di dalam InkWell biar area klik luas full sekotak
              child: Row(
                children: [
                  // Icon Checkbox (Kiri) - Berubah warna & icon kalau dicentang
                  Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? const Color(0xFF436155) : Colors.grey,
                    size: 26,
                  ),
                  const SizedBox(width: 14),

                  // Teks Detail kecoret kalau dicentang
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: isDone ? Colors.grey : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nomor Step (Bagian kanan )
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit?.call();
                            } else if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
