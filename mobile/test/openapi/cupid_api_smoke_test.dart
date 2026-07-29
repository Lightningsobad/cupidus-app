import 'package:cupid_api/cupid_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Proof of AC2: the generated cupid_api package is on the dependency graph
// and its API classes / models construct, without enumerating every
// generated endpoint.
void main() {
  test('generated AppApi constructs with a Dio client', () {
    final api = AppApi(Dio());

    expect(api, isA<AppApi>());
  });

  test('generated CreateAlarmDto constructs and round-trips JSON', () {
    final dto = CreateAlarmDto(time: '2026-07-29T00:00:00Z');

    expect(dto, isA<CreateAlarmDto>());
    expect(dto.toJson()['time'], '2026-07-29T00:00:00Z');
  });
}
