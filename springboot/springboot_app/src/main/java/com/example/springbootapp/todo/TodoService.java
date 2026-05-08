package com.example.springbootapp.todo;

import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class TodoService {
	private final Map<String, Todo> todos = new ConcurrentHashMap<>();
	private final Clock clock;

	public TodoService() {
		this(Clock.systemUTC());
	}

	TodoService(Clock clock) {
		this.clock = clock;
	}

	public TodoSnapshot list(TodoFilter filter) {
		List<Todo> filteredTodos = todos.values().stream()
				.filter(todo -> switch (filter) {
					case ACTIVE -> !todo.completed();
					case COMPLETED -> todo.completed();
					case ALL -> true;
				})
				.sorted(Comparator.comparing(Todo::createdAt))
				.toList();

		return new TodoSnapshot(filteredTodos, stats());
	}

	public Todo create(String title) {
		String normalizedTitle = normalizeTitle(title);
		Instant now = Instant.now(clock);
		Todo todo = new Todo(UUID.randomUUID().toString(), normalizedTitle, false, now, now);
		todos.put(todo.id(), todo);
		return todo;
	}

	public Todo update(String id, TodoUpdateRequest request) {
		Todo existing = findById(id);
		String title = request.title() == null ? existing.title() : normalizeTitle(request.title());
		boolean completed = request.completed() == null ? existing.completed() : request.completed();
		Todo updated = new Todo(existing.id(), title, completed, existing.createdAt(), Instant.now(clock));
		todos.put(updated.id(), updated);
		return updated;
	}

	public void delete(String id) {
		if (todos.remove(id) == null) {
			throw new TodoNotFoundException(id);
		}
	}

	public void clear() {
		todos.clear();
	}

	private Todo findById(String id) {
		Todo todo = todos.get(id);

		if (todo == null) {
			throw new TodoNotFoundException(id);
		}

		return todo;
	}

	private TodoStats stats() {
		int total = todos.size();
		int completed = (int) todos.values().stream().filter(Todo::completed).count();
		return new TodoStats(total, total - completed, completed);
	}

	private String normalizeTitle(String title) {
		if (!StringUtils.hasText(title)) {
			throw new IllegalArgumentException("Todo title is required");
		}

		String normalizedTitle = title.trim();

		if (normalizedTitle.length() > 120) {
			throw new IllegalArgumentException("Todo title must be 120 characters or less");
		}

		return normalizedTitle;
	}
}
