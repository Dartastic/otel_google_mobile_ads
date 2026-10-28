// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_google_mobile_ads_suppression.dart';

const _tracerName = 'dartastic_otel_libs_google_mobile_ads';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class GoogleMobileAdsResult {
  /// Creates a result.
  const GoogleMobileAdsResult({
    this.appId,
    this.adUnitId,
    this.adFormat,
    this.mediationAdapter,
    this.responseId,
    this.loadStatus,
    this.errorCode,
    this.errorDomain,
    this.loadTimeMs,
    this.estimatedValueMicros,
    this.precisionType,
    this.currencyCode,
    this.rewardType,
    this.rewardAmount,
    this.viewabilityValid,
    this.statusCode,
  });

  /// Publisher AdMob app id (`ca-app-pub-{publisher}~{app}`).
  final String? appId;

  /// Ad unit id (`ca-app-pub-{publisher}/{unit}`).
  final String? adUnitId;

  /// `banner` / `interstitial` / `rewarded` / `rewarded_interstitial` /
  /// `native` / `app_open`.
  final String? adFormat;

  /// Mediation adapter that filled the request (`google_mobile_ads` /
  /// `meta` / `applovin` / `unity` / `mintegral` / `pangle` /
  /// `liftoff` / `vungle` / `chartboost` / ...).
  final String? mediationAdapter;

  /// AdMob response_id (correlation key in AdMob console).
  final String? responseId;

  /// `loaded` / `failed_to_load` / `dismissed` / `clicked` /
  /// `impression` / `paid` / `opened` / `closed`.
  final String? loadStatus;

  /// AdMob error code (0=internal_error / 1=invalid_request /
  /// 2=network_error / 3=no_fill / 8=app_id_missing / 9=mediation_no_fill /
  /// 10=mediation_data_error / 11=ad_unit_invalid / etc).
  final int? errorCode;

  /// `com.google.android.gms.ads` / `GADErrorDomain`.
  final String? errorDomain;

  final int? loadTimeMs;

  /// AdValue: revenue in micros (1M = 1 currency unit).
  final int? estimatedValueMicros;

  /// `unknown` / `estimated` / `publisher_provided` / `precise` —
  /// quality signal for ad revenue.
  final String? precisionType;

  final String? currencyCode;

  /// For rewarded ads: virtual currency reward.
  final String? rewardType;
  final int? rewardAmount;

  /// `true` when the ad passed viewability checks (impression valid).
  final bool? viewabilityValid;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class GoogleMobileAdsCallResult<T> {
  /// Creates a call result.
  const GoogleMobileAdsCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final GoogleMobileAdsResult? result;
}

/// Wraps a Google Mobile Ads SDK call in a CLIENT span. [operation]
/// is one of `banner.load`, `interstitial.load`, `interstitial.show`,
/// `rewarded.load`, `rewarded.show`, `rewarded_interstitial.load`,
/// `app_open.load`, `app_open.show`, `native.load`,
/// `mobileads.initialize`, `consent.request`,
/// `consent.show_form`.
Future<T> tracedGoogleMobileAds<T>({
  required String operation,
  required Future<GoogleMobileAdsCallResult<T>> Function() invoke,
}) async {
  if (googleMobileAdsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'google_mobile_ads',
    'rpc.method': operation,
    'google_mobile_ads.operation': operation,
  };

  final span = _tracer().startSpan(
    'google_mobile_ads $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.appId != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.app.id',
          r.result!.appId!,
        ));
      }
      if (r.result!.adUnitId != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.ad_unit.id',
          r.result!.adUnitId!,
        ));
      }
      if (r.result!.adFormat != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.ad.format',
          r.result!.adFormat!,
        ));
      }
      if (r.result!.mediationAdapter != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.mediation.adapter',
          r.result!.mediationAdapter!,
        ));
      }
      if (r.result!.responseId != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.response.id',
          r.result!.responseId!,
        ));
      }
      if (r.result!.loadStatus != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.load.status',
          r.result!.loadStatus!,
        ));
        if (r.result!.loadStatus == 'failed_to_load') {
          span.setStatus(
            SpanStatusCode.Error,
            'AdMob failed_to_load',
          );
        }
      }
      if (r.result!.errorCode != null) {
        extras.add(OTelAPI.attributeInt(
          'google_mobile_ads.error.code',
          r.result!.errorCode!,
        ));
      }
      if (r.result!.errorDomain != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.error.domain',
          r.result!.errorDomain!,
        ));
      }
      if (r.result!.loadTimeMs != null) {
        extras.add(OTelAPI.attributeInt(
          'google_mobile_ads.load.time_ms',
          r.result!.loadTimeMs!,
        ));
      }
      if (r.result!.estimatedValueMicros != null) {
        extras.add(OTelAPI.attributeInt(
          'google_mobile_ads.value.micros',
          r.result!.estimatedValueMicros!,
        ));
      }
      if (r.result!.precisionType != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.value.precision',
          r.result!.precisionType!,
        ));
      }
      if (r.result!.currencyCode != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.currency.code',
          r.result!.currencyCode!,
        ));
      }
      if (r.result!.rewardType != null) {
        extras.add(OTelAPI.attributeString(
          'google_mobile_ads.reward.type',
          r.result!.rewardType!,
        ));
      }
      if (r.result!.rewardAmount != null) {
        extras.add(OTelAPI.attributeInt(
          'google_mobile_ads.reward.amount',
          r.result!.rewardAmount!,
        ));
      }
      if (r.result!.viewabilityValid != null) {
        extras.add(OTelAPI.attributeBool(
          'google_mobile_ads.viewability.valid',
          r.result!.viewabilityValid!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'AdMob HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
