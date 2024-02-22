import 'package:dslink/client.dart';
import 'package:dslink/common.dart';
import 'package:dslink/utils.dart';

void main() async {
  var key = PrivateKey.loadFromString(
      '1aEqqRYk-yf34tcLRogX145szFsdVtrpywDEPuxRQtM BGt1WHhkwCn2nWSDXHTg-IxruXLrPPUlU--0ghiBIQC7HMWWcNQGAoO03l_BQYx7_DYn0sn2gWW9wESbixzWuKg');

  var link = HttpClientLink('https://dev.sviteco.ua/conn', 'rick-req-', key,
      isRequester: true);
  link.connect();
  var requester = await link.onRequesterReady;
  updateLogLevel('debug');

  // configure

  await requester?.subscribe('/sys/dataInPerSecond', (ValueUpdate update) {
    print('${update.ts} : ${update.value}');
  }, 1);
  requester?.set('/data/req', 'test111');
}
