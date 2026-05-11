package com.example.springbootapp.todo;

public class TodoNotFoundException extends RuntimeException {
	public TodoNotFoundException(String id) {
		super("Todo " + id + " was not found");
	}
}
