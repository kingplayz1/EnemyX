# EnemyX V1.1 Test Suite

This directory contains the automated test matrix for EnemyX V1.1 hardening phase.

## Test Categories

- `core/` - Resource lifecycle and basic functionality
- `npc/` - NPC lifecycle and properties
- `behavior/` - NPC behaviors (guard, patrol, chase, investigate)
- `framework/` - Framework adapter compatibility (standalone, ESX, QBCore, Qbox, vRP, ND)
- `admin/` - Admin panel functionality and security
- `security/` - Security hardening and attack resistance
- `zones/` - Zone-based spawning and events
- `config/` - Configuration system
- `performance/` - Performance and stress testing

## Test Runner

The test runner is located at `tests/core/test_runner.lua`. It orchestrates running all test suites.

## Inventory

Run `tests/inventory.lua` to generate a complete inventory of:
- Public exports
- Events
- NUI callbacks
- Framework adapter functions
- Configuration entries
- Entity lifecycle paths

This inventory maps to the test cases and identifies untestable areas.

## Usage (when Lua is available)

```bash
# Run inventory
lua tests/inventory.lua

# Run all tests
lua tests/core/test_runner.lua
```

## Test Matrix

See `tests/TEST_MATRIX.md` for the master checklist.

Each test category has its own Lua file implementing the test cases.
Initially, tests are stubbed to return PASS. As hardening progresses,
tests should be implemented with actual verification logic.