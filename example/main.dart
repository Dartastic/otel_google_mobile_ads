// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_google_mobile_ads/otel_google_mobile_ads.dart';

/// Traces Google Mobile Ads calls with OpenTelemetry.
///
/// `otel_google_mobile_ads` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Google Mobile Ads call in
/// [tracedGoogleMobileAds]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'google-mobile-ads-example');

  // Wraps a Google Mobile Ads SDK call in a CLIENT span.
  final googleMobileAdsId = await tracedGoogleMobileAds<String>(
    operation: 'banner.load',
    invoke: () async {
      // Make the Google Mobile Ads call here, then report what it returned.
      const id = 'google_mobile_ads_8f3a2c';
      return const GoogleMobileAdsCallResult(
          value: id,
          result: GoogleMobileAdsResult(
              appId: 'ca-app-pub-{publisher}~{app}',
              adUnitId: 'ca-app-pub-{publisher}/{unit}',
              adFormat: 'banner',
              mediationAdapter: 'google_mobile_ads',
              responseId: 'response_8f3a2c',
              loadStatus: 'loaded',
              errorCode: 1,
              errorDomain: 'com.google.android.gms.ads',
              loadTimeMs: 120,
              estimatedValueMicros: 1,
              precisionType: 'unknown',
              currencyCode: 'usd',
              rewardType: 'standard',
              rewardAmount: 1999,
              viewabilityValid: true,
              statusCode: 200));
    },
  );
  OTelLog.info('tracedGoogleMobileAds banner.load returned $googleMobileAdsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGoogleMobileAdsInstrumentationAsync.
  await runWithoutGoogleMobileAdsInstrumentationAsync(
    () => tracedGoogleMobileAds<String>(
      operation: 'banner.load',
      invoke: () async {
        const id = 'google_mobile_ads_8f3a2c';
        return const GoogleMobileAdsCallResult(
            value: id,
            result: GoogleMobileAdsResult(
                appId: 'ca-app-pub-{publisher}~{app}',
                adUnitId: 'ca-app-pub-{publisher}/{unit}',
                adFormat: 'banner',
                mediationAdapter: 'google_mobile_ads',
                responseId: 'response_8f3a2c',
                loadStatus: 'loaded',
                errorCode: 1,
                errorDomain: 'com.google.android.gms.ads',
                loadTimeMs: 120,
                estimatedValueMicros: 1,
                precisionType: 'unknown',
                currencyCode: 'usd',
                rewardType: 'standard',
                rewardAmount: 1999,
                viewabilityValid: true,
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
