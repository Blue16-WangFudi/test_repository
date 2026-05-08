package com.example.springbootapp.todo;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

import org.junit.jupiter.api.Test;

class TodoServiceTests {
	private final TodoService todoService = new TodoService(
			Clock.fixed(Instant.parse("2026-05-08T00:00:00Z"), ZoneOffset.UTC)
	);

	@Test
	void createsFiltersUpdatesAndDeletesTodos() {
		Todo first = todoService.create("  Write Spring test  ");
		Todo second = todoService.create("Build Flutter client");

		assertThat(first.title()).isEqualTo("Write Spring test");
		assertThat(todoService.list(TodoFilter.ALL).stats()).isEqualTo(new TodoStats(2, 2, 0));

		todoService.update(first.id(), new TodoUpdateRequest(null, true));

		assertThat(todoService.list(TodoFilter.COMPLETED).todos()).containsExactly(
				new Todo(first.id(), first.title(), true, first.createdAt(), first.updatedAt())
		);
		assertThat(todoService.list(TodoFilter.ACTIVE).todos()).containsExactly(second);

		Todo updatedSecond = todoService.update(second.id(), new TodoUpdateRequest("Build API client", null));
		assertThat(updatedSecond.title()).isEqualTo("Build API client");

		todoService.delete(first.id());
		assertThat(todoService.list(TodoFilter.ALL).stats()).isEqualTo(new TodoStats(1, 1, 0));
	}

	@Test
	void rejectsBlankTitleAndUnknownId() {
		assertThatThrownBy(() -> todoService.create(" "))
				.isInstanceOf(IllegalArgumentException.class)
				.hasMessage("Todo title is required");

		assertThatThrownBy(() -> todoService.update("missing", new TodoUpdateRequest(null, true)))
				.isInstanceOf(TodoNotFoundException.class);

		assertThatThrownBy(() -> todoService.delete("missing"))
				.isInstanceOf(TodoNotFoundException.class);
	}
}
