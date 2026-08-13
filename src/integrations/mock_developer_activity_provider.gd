extends DeveloperActivityProvider
class_name MockDeveloperActivityProvider

func trigger_commit_created() -> void:
	emit_developer_event("commit_created", {"source": "mock"})

func trigger_tests_passed() -> void:
	emit_developer_event("tests_passed", {"source": "mock"})

func trigger_tests_failed() -> void:
	emit_developer_event("tests_failed", {"source": "mock"})

func trigger_break_recommended() -> void:
	emit_developer_event("break_recommended", {"source": "mock"})
