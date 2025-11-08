import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/publication_model.dart';
import 'package:admin_can_care/data/repositories/publication_repository.dart';
import 'package:admin_can_care/ui/widgets/empty_state.dart';

// Publications Screen - شاشة المنشورات
class PublicationsScreen extends StatelessWidget {
  const PublicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final repo = PublicationRepository();

    return Scaffold(
      appBar: AppBar(title: Text(isRTL ? 'المنشورات' : 'Publications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/publications/create'),
        icon: const Icon(Icons.add),
        label: Text(isRTL ? 'إنشاء منشور' : 'Create'),
      ),
      body: StreamBuilder<List<PublicationModel>>(
        stream: repo.streamPublications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final publications = snapshot.data ?? [];
          if (publications.isEmpty) {
            return EmptyState(
              icon: Icons.article_outlined,
              message: 'No publications yet',
              messageAr: 'لا توجد منشورات',
              actionLabel: 'Create Publication',
              actionLabelAr: 'إنشاء منشور',
              onAction: () => Navigator.pushNamed(context, '/publications/create'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: publications.length,
            itemBuilder: (context, index) {
              final pub = publications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: pub.coverImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(pub.coverImageUrl!, width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.article, size: 40),
                  title: Text(pub.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(pub.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // View details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

