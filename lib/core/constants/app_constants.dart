class AppConstants {
  const AppConstants._();

  // Hive
  static const taskBoxName = 'tasks_box';

  // Mock API
  static const todosUrl = 'https://jsonplaceholder.typicode.com/todos';

  // Finance
  static const defaultBudget = 50000.0;

  // Timing
  static const searchDebounce = Duration(milliseconds: 400);
  static const mockLoginDelay = Duration(milliseconds: 1500);
  static const mockSyncDelay = Duration(milliseconds: 800);
}
