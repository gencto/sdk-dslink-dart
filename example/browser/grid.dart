import 'dart:html';

import 'package:dslink/browser.dart';

late LinkProvider link;
late Requester r;

void main() async {
  var brokerUrl = await BrowserUtils.fetchBrokerUrlFromPath(
      'broker_url', 'https://dsa.gencto.uk/conn');

  link = LinkProvider(brokerUrl, 'HtmlGrid-',
      isRequester: true, isResponder: false);
  await link.connect();

  r = link.requester!;

  var dataNode = await r.getRemoteNode('/data');
  if (!dataNode.children.containsKey('grid')) {
    await r.invoke('/data/addValue', <String, dynamic>{
      'Name': 'grid',
      'Type': 'array'
    }).firstWhere((x) => x.streamStatus == StreamStatus.closed);

    var generateList = (int i) => List<bool>.generate(15, (x) => false);
    var list = List<List<bool>>.generate(15, generateList);
    await r.set('/data/grid', list);
  }

  r.onValueChange('/data/grid').listen((ValueUpdate update) {
    if (update.value is! List) return;

    var isNew = _grid == null;

    loadGrid(update.value as List<List<bool>>);

    if (isNew) {
      resizeGrid(15, 15);
    }
  });

  querySelector('#clear-btn')?.onClick.listen((e) {
    clearGrid();
  });
}

List<List<bool?>?>? _grid = <List<bool>>[];

void resizeGrid(int width, int height) {
  List<List<bool?>?> grid = deepCopy(_grid) as List<List<bool>>;

  print(grid);

  grid.length = height;
  for (var i = 0; i < height; i++) {
    var row = grid[i];
    row ??= grid[i] = [];

    row.length = width;
    for (var x = 0; x < width; x++) {
      if (row[x] == null) {
        row[x] = false;
      }
    }
  }

  _grid = grid;
  r.set('/data/grid', _grid as Object);
}

dynamic deepCopy(dynamic input) {
  if (input is List) {
    return input.map<bool>((dynamic value) => deepCopy(value)).toList();
  }
  return input;
}

void clearGrid() {
  for (var row in _grid!) {
    row!.fillRange(0, _grid!.length, false);
  }
  r.set('/data/grid', _grid!);
}

void loadGrid(List<List<bool>> input) {
  _grid = input;

  var root = querySelector('#root');

  for (var i = 1; i <= input.length; i++) {
    var row = input[i - 1];

    var rowe = querySelector('#row-$i') as DivElement?;
    if (rowe == null) {
      rowe = DivElement();
      rowe.id = 'row-$i';
      rowe.classes.add('row');
      root?.append(rowe);
    }

    for (var x = 1; x <= row.length; x++) {
      var val = row[x - 1];
      var cow = querySelector('#block-$i-$x') as DivElement?;
      if (cow == null) {
        cow = DivElement();
        cow.id = 'block-$i-$x';
        cow.classes.add('block');
        cow.style.transition = 'background-color 0.2s';
        cow.onClick.listen((e) {
          if (_grid![i - 1]![x - 1] != null && _grid![i - 1]![x - 1]!) {
            _grid?[i - 1]?[x - 1] = false;
          } else {
            _grid?[i - 1]?[x - 1] = true;
          }

          r.set('/data/grid', _grid!);
        });
        rowe.append(cow);
      }

      String color;

      if (val == true) {
        color = 'red';
      } else if (val == false) {
        color = 'white';
      } else {
        color = 'gray';
      }

      if (cow.style.backgroundColor != color) {
        cow.style.backgroundColor = color;
      }
    }
  }
}
