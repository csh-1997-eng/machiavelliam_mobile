/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: api_client.dart
 * Purpose: Base URL config and feature flags for Vercel API routes.
 */

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

// Feature flags — set to true to enable backend integration
const bool kCoachingEnabled = true;
const bool kSessionPersistenceEnabled = true;
const bool kProfileEnabled = true;
const bool kScenarioEnabled = true;
const bool kDebriefEnabled = true;
const bool kHistoryEnabled = true;

// Mock flag — when true, InsightsService returns hardcoded strings (zero API cost).
// Flip to false only when smoke-testing the real Vercel+OpenAI pipeline.
const bool kMockInsights = false;
