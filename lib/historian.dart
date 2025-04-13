library dsalink.historian;

import 'dart:async';
import 'dart:math';

import 'package:dsalink/convert_consts.dart';
import 'package:dsalink/dsalink.dart';
import 'package:dsalink/nodes.dart';
import 'package:dsalink/utils.dart';

part 'src/historian/adapter.dart';
part 'src/historian/container.dart';
part 'src/historian/get_history.dart';
part 'src/historian/interval.dart';
part 'src/historian/main.dart';
part 'src/historian/manage.dart';
part 'src/historian/publish.dart';
part 'src/historian/rollup.dart';
part 'src/historian/values.dart';

late LinkProvider _link;
late HistorianAdapter _historian;

HistorianAdapter get historian => _historian;
LinkProvider get link => _link;
