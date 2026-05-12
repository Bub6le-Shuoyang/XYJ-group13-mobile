import 'package:flutter_test/flutter_test.dart';

import 'package:sunday_project/main.dart';

void main() {
  testWidgets('登录页展示用户登录和工作人员入口', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('乡村快递协同平台'), findsOneWidget);
    expect(find.text('手机号登录'), findsOneWidget);
    expect(find.text('工作人员入口'), findsOneWidget);
  });
}
