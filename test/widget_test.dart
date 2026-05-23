import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunday_project/main.dart';

void main() {
  testWidgets('登录页展示用户登录和工作人员入口', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('乡村快递协同平台'), findsOneWidget);
    expect(find.text('手机号登录'), findsOneWidget);
    expect(find.text('工作人员入口'), findsOneWidget);
  });

  testWidgets('工作人员入口需要先选择角色并输入账号密码', (tester) async {
    await tester.pumpWidget(const MyApp());

    final staffEntrance = find.byKey(const ValueKey('staff_entrance_button'));
    await tester.ensureVisible(staffEntrance);
    await tester.tap(staffEntrance);
    await tester.pumpAndSettle();

    expect(find.text('工作人员登录'), findsOneWidget);
    expect(find.text('站点管理员'), findsWidgets);
    expect(find.text('配送员'), findsWidgets);
    expect(find.byKey(const ValueKey('staff_account_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('staff_password_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('staff_login_button')), findsOneWidget);
  });
}
