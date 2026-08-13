# Tests

The MVP includes a small headless smoke test for domain rules.

Run it with Godot installed:

```text
godot --headless --path . --script res://tests/domain_cli_test.gd
```

The test covers:

- mood calculation
- weighted state selection
- random event conditions
- time period mapping
- save default merge behaviour
