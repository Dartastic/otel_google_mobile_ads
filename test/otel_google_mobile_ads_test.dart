// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_google_mobile_ads/otel_google_mobile_ads.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_google_mobile_ads-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('rewarded.show records reward + AdValue precision', () async {
    await tracedGoogleMobileAds<String>(
      operation: 'rewarded.show',
      invoke: () async => const GoogleMobileAdsCallResult(
        value: 'ok',
        result: GoogleMobileAdsResult(
          adUnitId: 'ca-app-pub-123/rewarded',
          adFormat: 'rewarded',
          mediationAdapter: 'meta',
          loadStatus: 'paid',
          estimatedValueMicros: 12000,
          precisionType: 'precise',
          currencyCode: 'USD',
          rewardType: 'coins',
          rewardAmount: 100,
          viewabilityValid: true,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('google_mobile_ads rewarded.show')!);
    expect(a['google_mobile_ads.ad.format'], 'rewarded');
    expect(a['google_mobile_ads.mediation.adapter'], 'meta');
    expect(a['google_mobile_ads.value.micros'], 12000);
    expect(a['google_mobile_ads.value.precision'], 'precise');
    expect(a['google_mobile_ads.reward.amount'], 100);
  });

  test('failed_to_load with no-fill sets span error', () async {
    await tracedGoogleMobileAds<String>(
      operation: 'banner.load',
      invoke: () async => const GoogleMobileAdsCallResult(
        value: 'ok',
        result: GoogleMobileAdsResult(
          adFormat: 'banner',
          loadStatus: 'failed_to_load',
          errorCode: 3,
          errorDomain: 'com.google.android.gms.ads',
        ),
      ),
    );
    final s = spans.findSpanByName('google_mobile_ads banner.load')!;
    expect(s.status, SpanStatusCode.Error);
    expect(attrsOf(s)['google_mobile_ads.error.code'], 3);
  });

  test('suppression skips spans', () async {
    await runWithoutGoogleMobileAdsInstrumentationAsync(() async {
      await tracedGoogleMobileAds<String>(
        operation: 'mobileads.initialize',
        invoke: () async => const GoogleMobileAdsCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('google_mobile_ads '), isEmpty);
  });
}
