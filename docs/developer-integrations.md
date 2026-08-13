# Developer Integrations

The MVP does not integrate with real developer tools yet. It defines the contract and provides a mock provider.

## Provider Contract

`DeveloperActivityProvider` exposes:

```text
commit_created
tests_passed
tests_failed
build_passed
build_failed
coding_session_started
coding_session_finished
break_recommended
```

## Mock Provider

`MockDeveloperActivityProvider` can trigger:

- commit created
- tests passed
- tests failed
- break recommended

The debug panel calls the mock provider to test reactions without reading files or external services.

## Future Providers

Possible opt-in providers:

- Git
- GitHub
- WakaTime
- JetBrains
- VS Code
- Pomodoro

Future integrations must not collect telemetry by default or inspect arbitrary user files.
