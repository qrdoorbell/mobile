import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:quiver/core.dart';

class ParsedRoute extends Route<dynamic> {
  final String path;
  final String pathTemplate;
  final Map<String, String> parameters;
  final Map<String, String> queryParameters;

  static const _mapEquality = MapEquality<String, String>();

  ParsedRoute(this.path, this.pathTemplate, this.parameters, this.queryParameters, {RouteSettings? settings}) : super(settings: settings);

  Uri toUri() => Uri(path: path, queryParameters: queryParameters);

  @override
  bool operator ==(Object other) =>
      other is ParsedRoute &&
      other.pathTemplate == pathTemplate &&
      other.path == path &&
      _mapEquality.equals(parameters, other.parameters) &&
      _mapEquality.equals(queryParameters, other.queryParameters);

  @override
  int get hashCode => hash4(
        path,
        pathTemplate,
        _mapEquality.hash(parameters),
        _mapEquality.hash(queryParameters),
      );

  @override
  String toString() => '<ParsedRoute '
      'template: $pathTemplate '
      'path: $path '
      'parameters: $parameters '
      'query parameters: $queryParameters>';
}
