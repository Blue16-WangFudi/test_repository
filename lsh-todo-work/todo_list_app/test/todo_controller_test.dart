import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_app/todo_controller.dart';

void main() {
  group('TodoListController', () {
    test('adds trimmed todos to the top of the list', () {
      final controller = TodoListController();

      final first = controller.add('  Buy milk  ');
      final second = controller.add('Write tests');

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(controller.totalCount, 2);
      expect(controller.activeCount, 2);
      expect(controller.completedCount, 0);
      expect(controller.items.first.title, 'Write tests');
      expect(controller.items.last.title, 'Buy milk');
    });

    test('ignores empty todo titles', () {
      final controller = TodoListController();
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      final item = controller.add('   ');

      expect(item, isNull);
      expect(controller.items, isEmpty);
      expect(notificationCount, 0);
    });

    test('toggles completion state and count totals', () {
      final controller = TodoListController();
      final item = controller.add('Ship the app')!;

      controller.toggle(item.id);

      expect(controller.items.single.isCompleted, isTrue);
      expect(controller.activeCount, 0);
      expect(controller.completedCount, 1);

      controller.toggle(item.id);

      expect(controller.items.single.isCompleted, isFalse);
      expect(controller.activeCount, 1);
      expect(controller.completedCount, 0);
    });

    test('removes a todo by id', () {
      final controller = TodoListController();
      final first = controller.add('First')!;
      final second = controller.add('Second')!;

      controller.remove(first.id);

      expect(controller.totalCount, 1);
      expect(controller.items.single.id, second.id);
    });
  });
}
