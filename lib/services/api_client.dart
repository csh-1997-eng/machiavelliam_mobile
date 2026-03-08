/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: api_client.dart
 * Purpose: Base URL config for Vercel API routes. Passed in via --dart-define.
 */

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
