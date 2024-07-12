import 'package:dslink/client.dart';
import 'sample_responder.dart';

void main() async {
  var key = PrivateKey.loadFromString(
      '9zaOwGO2iXimn4RXTNndBEpoo32qFDUw72d8mteZP9I BJSgx1t4pVm8VCs4FHYzRvr14BzgCBEm8wJnMVrrlx1u1dnTsPC0MlzAB1LhH2sb6FXnagIuYfpQUJGT_yYtoJM');

  var link = HttpClientLink('https://dev.gencto.uk/conn', 'rick-req-', key,
      isResponder: true, nodeProvider: TestNodeProvider());

  link.connect();
}
