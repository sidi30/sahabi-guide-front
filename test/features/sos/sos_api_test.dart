// Ce qui compte ici : ce que l'app considère (ou non) comme une confirmation.
// Une réponse HTTP qui ne prouve pas la création de l'alerte ne doit jamais
// remonter comme un succès.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/network/dio_client.dart';
import 'package:sahabi_guide/features/sos/data/sos_api.dart';
import 'package:sahabi_guide/features/sos/domain/sos_request.dart';

/// Adaptateur HTTP bouchonné : aucune requête ne sort de la machine.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final List<RequestOptions> received = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    received.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, int status) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

({SosApi api, _StubAdapter adapter}) buildApi(
  ResponseBody Function(RequestOptions options) respond,
) {
  final dio = Dio();
  final client = DioClient(dio);
  final adapter = _StubAdapter(respond);
  dio.httpClientAdapter = adapter;
  return (api: SosApiImpl(client), adapter: adapter);
}

SosRequest request() => SosRequest(
      clientAlertId: 'client-99',
      createdAt: DateTime(2026, 7, 29, 10),
      status: SosDeliveryStatus.pending,
      latitude: 21.4133,
      longitude: 39.8933,
      capturedAt: DateTime.utc(2026, 7, 29, 9, 59),
    );

void main() {
  test('une réponse 201 avec identifiant vaut confirmation', () async {
    final built = buildApi((_) => _json({
          'id': 'alert-1',
          'clientAlertId': 'client-99',
          'status': 'ACTIVE',
          'createdAt': '2026-07-29T10:00:05Z',
          'positionRecorded': true,
        }, 201));

    final ack = await built.api.send(request());

    expect(ack.alertId, 'alert-1');
    expect(ack.positionRecorded, isTrue);
    expect(built.adapter.received.single.path, SosApiImpl.endpoint);
  });

  test('le corps envoyé porte le clientAlertId et la position', () async {
    final built = buildApi((_) => _json({'id': 'alert-1'}, 200));

    await built.api.send(request());

    final body = built.adapter.received.single.data as Map<String, dynamic>;
    expect(body['clientAlertId'], 'client-99');
    expect(body['latitude'], closeTo(21.4133, 0.0001));
    expect(body['capturedAt'], '2026-07-29T09:59:00.000Z');
  });

  test('une réponse 200 SANS identifiant n\'est pas un succès', () async {
    final built = buildApi((_) => _json({'status': 'ACTIVE'}, 200));

    await expectLater(
      built.api.send(request()),
      throwsA(isA<SosSendException>()
          .having((e) => e.retryable, 'retryable', isTrue)),
    );
  });

  test('une panne serveur est réessayable', () async {
    final built = buildApi((_) => _json({'error': 'boom'}, 503));

    await expectLater(
      built.api.send(request()),
      throwsA(isA<SosSendException>()
          .having((e) => e.retryable, 'retryable', isTrue)),
    );
  });

  test('un refus 403 n\'est pas réessayable', () async {
    final built = buildApi((_) => _json({'message': 'interdit'}, 403));

    await expectLater(
      built.api.send(request()),
      throwsA(isA<SosSendException>()
          .having((e) => e.retryable, 'retryable', isFalse)),
    );
  });

  test('un 429 est réessayable (le serveur demande d\'attendre)', () async {
    final built = buildApi((_) => _json({'message': 'trop de requêtes'}, 429));

    await expectLater(
      built.api.send(request()),
      throwsA(isA<SosSendException>()
          .having((e) => e.retryable, 'retryable', isTrue)),
    );
  });

  test('une coupure réseau est réessayable', () async {
    final dio = Dio();
    final client = DioClient(dio);
    dio.httpClientAdapter = _ThrowingAdapter();

    await expectLater(
      SosApiImpl(client).send(request()),
      throwsA(isA<SosSendException>()
          .having((e) => e.retryable, 'retryable', isTrue)),
    );
  });

  test('un SOS sans position n\'envoie aucune coordonnée', () async {
    final built = buildApi((_) => _json({'id': 'alert-1'}, 201));

    await built.api.send(SosRequest(
      clientAlertId: 'client-sans-position',
      createdAt: DateTime(2026, 7, 29, 10),
      status: SosDeliveryStatus.pending,
    ));

    final body = built.adapter.received.single.data as Map<String, dynamic>;
    expect(body.containsKey('latitude'), isFalse);
    expect(body.containsKey('longitude'), isFalse);
    expect(body['clientAlertId'], 'client-sans-position');
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'réseau coupé',
    );
  }

  @override
  void close({bool force = false}) {}
}
