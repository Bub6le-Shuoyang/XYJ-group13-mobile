import 'package:flutter_test/flutter_test.dart';

import 'package:sunday_project/main.dart';

void main() {
  testWidgets('登录页展示三个角色入口', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('乡村快递协同平台'), findsOneWidget);
    expect(find.text('村民用户'), findsOneWidget);
    expect(find.text('配送员'), findsOneWidget);
    expect(find.text('站点管理员'), findsOneWidget);
  });

  testWidgets('站点管理员可以进入入库与任务发布界面', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('站点管理员'));
    await tester.pumpAndSettle();

    expect(find.text('包裹入库'), findsOneWidget);
    expect(find.text('任务发布'), findsOneWidget);
    expect(find.text('确认入库'), findsOneWidget);
  });
}
