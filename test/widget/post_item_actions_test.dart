import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/screens/forum/post_item.dart';
import 'package:tipsterino/features/forum/domain/post.dart';

void main() {
  testWidgets('post item shows action buttons', (tester) async {
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.comment,
      content: 'Hi',
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(home: PostItem(post: post)));
    expect(find.byIcon(Icons.reply), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
  });
}
