package com.example.springbootapp.todo;

import java.util.List;

public record TodoSnapshot(List<Todo> todos, TodoStats stats) {
}
