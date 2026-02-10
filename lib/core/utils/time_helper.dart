String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inMinutes < 1) return "À l'instant";
  if (difference.inMinutes < 60) return "Il y a ${difference.inMinutes} min";
  if (difference.inHours < 24) return "Il y a ${difference.inHours}h";
  if (difference.inDays == 1) return "Hier";
  if (difference.inDays < 7) return "Il y a ${difference.inDays}j";
  
  // Otherwise show date
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return "$day/$month";
}
