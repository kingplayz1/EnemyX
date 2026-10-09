# EnemyX Security Audit - Phase 2

This directory contains security tests for the EnemyX framework as part of Phase 2 hardening.

## Security Test Categories

- Permission Bypass Testing
- Event Spoofing
- NPC Input Validation
- Group Input Validation
- Zone Input Validation
- Configuration Security
- Rate-Limit Verification
- NUI Security
- Entity Abuse
- Framework Permission Isolation
- Resource Lifecycle Security

Each test file should attempt to breach security boundaries and verify that proper protections are in place.

## Testing Approach

For each externally reachable entry point:
1. Identify who can call it
2. Check authentication
3. Check authorization
4. Validate arguments
5. Check rate limiting
6. Verify server authoritativeness
7. Test impact on other players' resources

All tests should verify that unauthorized actions are properly rejected without state changes.