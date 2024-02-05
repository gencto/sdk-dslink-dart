import 'package:dslink/dslink.dart';

void main() async {
  var client = BrokerDiscoveryClient();

  await client.init();

  await for (var url in client.discover()) {
    print('Discovered Broker at $url');
  }
}