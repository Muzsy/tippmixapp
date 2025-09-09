import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/widgets/forum/quoted_post_card.dart';

void main() {
  testWidgets('tapping card triggers callback', (tester) async {
    bool tapped = false;
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.comment,
      content: 'Hi',
      createdAt: DateTime(2024),
    );
    await tester.pumpWidget(MaterialApp(
      home: QuotedPostCard(post: post, onTap: () => tapped = true),
    ));
    await tester.tap(find.byType(QuotedPostCard));
    expect(tapped, isTrue);
  });
}
