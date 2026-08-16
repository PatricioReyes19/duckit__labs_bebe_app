import 'dart:convert';
import 'dart:developer' as developer;

typedef StartupTraceSink = void Function(
  String event,
  Map<String, Object?> attributes,
);

void emitStartupTrace(String event, Map<String, Object?> attributes) {
  developer.log(
    jsonEncode({'event': event, ...attributes}),
    name: 'bebe_app.startup',
  );
}
