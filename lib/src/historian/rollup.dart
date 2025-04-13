part of dsalink.historian;

abstract class Rollup {
  dynamic get value;

  void add(dynamic input);

  void reset();
}

class FirstRollup extends Rollup {
  @override
  void add(dynamic input) {
    if (set) {
      return;
    }
    value = input;
    set = true;
  }

  @override
  void reset() {
    set = false;
  }

  @override
  dynamic value;
  bool set = false;
}

class LastRollup extends Rollup {
  @override
  void add(dynamic input) {
    value = input;
  }

  @override
  void reset() {}

  @override
  dynamic value;
}

class AvgRollup extends Rollup {
  @override
  void add(dynamic input) {
    if (input is String) {
      try {
        input = num.parse(input);
      } catch (e) {
        input = input.length;
      }
    }

    if (input is! num) {
      return;
    }

    total += input;
    count++;
  }

  @override
  void reset() {
    total = 0.0;
    count = 0;
  }

  dynamic total = 0.0;

  @override
  dynamic get value => total / count;
  int count = 0;
}

class SumRollup extends Rollup {
  @override
  void add(dynamic input) {
    if (input is String) {
      input = num.tryParse(input);
    }

    if (input is! num) {
      return;
    }

    value += input;
  }

  @override
  void reset() {
    value = 0.0;
  }

  @override
  dynamic value = 0.0;
}

class CountRollup extends Rollup {
  @override
  void add(dynamic input) {
    value++;
  }

  @override
  void reset() {
    value = 0;
  }

  @override
  dynamic value = 0;
}

class MaxRollup extends Rollup {
  @override
  void add(dynamic input) {
    if (input is String) {
      input = num.tryParse(input);
    }

    if (input is! num) {
      return;
    }

    value = max(value == null ? double_NEGATIVE_INFINITY : value as num, input);
  }

  @override
  void reset() {
    value = null;
  }

  @override
  dynamic value;
}

class MinRollup extends Rollup {
  @override
  void add(dynamic input) {
    if (input is String) {
      input = num.tryParse(input);
    }

    if (input is! num) {
      return;
    }

    value = min(value == null ? double_INFINITY : value as num, input);
  }

  @override
  void reset() {
    value = null;
  }

  @override
  dynamic value;
}

typedef RollupFactory = Rollup? Function();

final Map<String, RollupFactory?> _rollups = {
  'none': () => null,
  'delta': () => FirstRollup(),
  'first': () => FirstRollup(),
  'last': () => LastRollup(),
  'max': () => MaxRollup(),
  'min': () => MinRollup(),
  'count': () => CountRollup(),
  'sum': () => SumRollup(),
  'avg': () => AvgRollup(),
};
