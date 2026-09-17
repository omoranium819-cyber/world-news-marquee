import 'package:flutter_test/flutter_test.dart';

import 'package:world_news_marquee/main.dart';

void main() {
  testWidgets('App builds and shows the app bar title', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldNewsApp());
    expect(find.text('World News Marquee'), findsOneWidget);
  });
}
