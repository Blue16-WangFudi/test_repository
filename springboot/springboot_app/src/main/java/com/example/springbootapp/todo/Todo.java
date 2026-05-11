package com.example.springbootapp.todo;

import java.time.Instant;

public record Todo(
		String id,
		String title,
		boolean completed,
		Instant createdAt,
		Instant updatedAt
) {
}
