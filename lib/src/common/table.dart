part of dslink.common;

class TableColumn {
  String? type;
  String? name;
  Object? defaultValue;

  TableColumn(this.name, this.type, [this.defaultValue]);

  Map getData() {
    var rslt = <String, dynamic>{
      'type': type,
      'name': name
    };

    if (defaultValue != null) {
      rslt['default'] = defaultValue;
    }
    return rslt;
  }

  /// convert tableColumns into List of Map
  static List<Map> serializeColumns(List list) {
    var rslts = <Map>[];
    for (Object m in list) {
      if (m is Map) {
        rslts.add(m);
      } else if (m is TableColumn) {
        rslts.add(m.getData());
      }
    }
    return rslts;
  }

  /// parse List of Map into TableColumn
  static List<TableColumn>? parseColumns(List list) {
    var rslt = <TableColumn>[];
    for (Object m in list) {
      if (m is Map && m['name'] is String) {
        var type = 'string';
        if (m['type'] is String) {
          type = m['type'];
        }
        rslt.add(TableColumn(m['name'], type, m['default']));
      } else if (m is TableColumn) {
        rslt.add(m);
      } else {
        // invalid column data
        return null;
      }
    }
    return rslt;
  }
}

class Table {
  List<TableColumn> columns;
  List<List> rows;
  Map? meta;

  Table(this.columns, this.rows, {this.meta});
}

class TableColumns {
  final List<TableColumn> columns;

  TableColumns(this.columns);
}

class TableMetadata {
  final Map meta;

  TableMetadata(this.meta);
}
