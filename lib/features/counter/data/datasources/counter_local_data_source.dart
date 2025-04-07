import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/counter.dart';

abstract class CounterLocalDataSource {
  Future<Counter> getCounter();
  Future<Counter> incrementCounter(Counter counter);
  Future<Counter> decrementCounter(Counter counter);
}

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String COUNTER_KEY = 'counter_value';

  CounterLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<Counter> getCounter() async {
    final value = sharedPreferences.getInt(COUNTER_KEY) ?? 0;
    return Counter(value);
  }

  @override
  Future<Counter> incrementCounter(Counter counter) async {
    final newValue = counter.value + 1;
    await sharedPreferences.setInt(COUNTER_KEY, newValue);
    return Counter(newValue);
  }

  @override
  Future<Counter> decrementCounter(Counter counter) async {
    final newValue = counter.value - 1;
    await sharedPreferences.setInt(COUNTER_KEY, newValue);
    return Counter(newValue);
  }
} 