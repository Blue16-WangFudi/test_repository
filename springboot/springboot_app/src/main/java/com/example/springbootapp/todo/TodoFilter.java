package com.example.springbootapp.todo;

public enum TodoFilter {
	ALL,
	ACTIVE,
	COMPLETED;

	public static TodoFilter from(String value) {
		if ("active".equalsIgnoreCase(value)) {
			return ACTIVE;
		}

		if ("completed".equalsIgnoreCase(value)) {
			return COMPLETED;
		}

		return ALL;
	}
}
