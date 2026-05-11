package com.example.springbootapp.todo;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/todos")
public class TodoController {
	private final TodoService todoService;

	public TodoController(TodoService todoService) {
		this.todoService = todoService;
	}

	@GetMapping
	public TodoSnapshot list(@RequestParam(required = false, defaultValue = "all") String filter) {
		return todoService.list(TodoFilter.from(filter));
	}

	@PostMapping
	public ResponseEntity<Todo> create(@RequestBody TodoCreateRequest request) {
		return ResponseEntity.status(HttpStatus.CREATED).body(todoService.create(request.title()));
	}

	@PutMapping("/{id}")
	public Todo update(@PathVariable String id, @RequestBody TodoUpdateRequest request) {
		return todoService.update(id, request);
	}

	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable String id) {
		todoService.delete(id);
	}

	@ExceptionHandler(IllegalArgumentException.class)
	public ResponseEntity<Map<String, String>> handleValidation(IllegalArgumentException error) {
		return ResponseEntity.badRequest().body(Map.of("error", error.getMessage()));
	}

	@ExceptionHandler(TodoNotFoundException.class)
	public ResponseEntity<Map<String, String>> handleNotFound(TodoNotFoundException error) {
		return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", error.getMessage()));
	}
}
