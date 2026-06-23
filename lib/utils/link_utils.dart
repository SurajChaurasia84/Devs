import 'dart:core';

/// Constructs the Google Favicon API URL for a given domain/URL.
String getFaviconUrl(String url) {
  try {
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }
    final domain = Uri.parse(cleanUrl).host;
    String host = domain;
    if (host.startsWith('www.')) {
      host = host.substring(4);
    }
    return 'https://www.google.com/s2/favicons?domain=$host&sz=64';
  } catch (_) {
    return 'https://www.google.com/s2/favicons?domain=link&sz=64';
  }
}

/// Extracts a clean domain name (e.g., github.com) from a full URL.
String getDomainName(String url) {
  try {
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }
    String host = Uri.parse(cleanUrl).host;
    if (host.startsWith('www.')) {
      host = host.substring(4);
    }
    return host.isNotEmpty ? host : 'Link';
  } catch (_) {
    return 'Link';
  }
}
