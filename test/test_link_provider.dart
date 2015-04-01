import 'package:dslink/client.dart';
import 'package:dslink/utils.dart';
import 'package:dslink/responder.dart';
import 'dart:math' as Math;

LinkProvider link;
int lastNum;
SimpleNode addNode;
SimpleNode rootNode;

class AddNodeAction extends SimpleNode {
  AddNodeAction(String path) : super(path);
  Object onInvoke(Map params){
    addNode.configs[r'$lastNum'] = ++lastNum;
    
    String nodeName = '/node_$lastNum';
    link.provider.addNode(nodeName, {
      r'$type':'number',
      r'$is':'rng',
      '?value':0,
      'remove': { // an action to delete the node
        r'$is':'removeSelfAction',
        r'$invokable': 'read',
      }
    });
    link.save(); // save json
    return null;
  }
}

class RemoveSelfAction extends SimpleNode {
  RemoveSelfAction(String path) : super(path);
  Object onInvoke(Map params){
    List p = path.split('/')..removeLast();
    String parentPath = p.join('/');
    link.provider.removeNode(parentPath);
    link.save();
    return null;
  }
}

class RngNode extends SimpleNode {
  RngNode(String path) : super(path);
  
  static Math.Random rng = new  Math.Random();
  
  void onCreated() {
    DsTimer.callOnceAfter(updateRng, 1000);
  }
  void updateRng() {
    if (!removed) {
      updateValue(rng.nextDouble());
      DsTimer.callOnceAfter(updateRng, 1000);
    }
  }
}

main(List<String> args){

  Map defaultNodes = {
    'add': {
      r'$is': 'addNodeAction',
      r'$invokable': 'read',
      r'$lastNum':0
    }
  };

  
  Map profiles = {
    'addNodeAction': (String path){return new AddNodeAction(path);},
    'removeSelfAction': (String path){return new RemoveSelfAction(path);},
    'rng': (String path){return new RngNode(path);}
  };
  link = new LinkProvider(args, 'quicklink-', defaultNodes:defaultNodes, profiles:profiles);
  if (link.link == null) {
    // initialization failed
    return;
  }
  
  addNode = link.provider.getNode('/add');
  rootNode = link.provider.getNode('/');
  lastNum = addNode.configs[r'$lastNum'];
  
  link.connect();
}