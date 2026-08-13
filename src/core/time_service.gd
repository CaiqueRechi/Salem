extends Node
class_name TimeService

enum DayPeriod {
	MORNING,
	AFTERNOON,
	EVENING,
	NIGHT,
	LATE_NIGHT
}

func get_current_period() -> DayPeriod:
	var hour := int(Time.get_datetime_dict_from_system()["hour"])
	return get_period_for_hour(hour)

func get_period_for_hour(hour: int) -> DayPeriod:
	if hour >= 5 and hour < 12:
		return DayPeriod.MORNING
	if hour >= 12 and hour < 17:
		return DayPeriod.AFTERNOON
	if hour >= 17 and hour < 21:
		return DayPeriod.EVENING
	if hour >= 21 or hour < 1:
		return DayPeriod.NIGHT
	return DayPeriod.LATE_NIGHT

func get_period_name(period := -1) -> String:
	if period == -1:
		period = get_current_period()
	return DayPeriod.keys()[period].to_lower()
