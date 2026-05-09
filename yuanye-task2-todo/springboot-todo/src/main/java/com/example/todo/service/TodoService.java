package com.example.todo.service;

import com.example.todo.dto.TodoCreateRequest;
import com.example.todo.dto.TodoResponse;
import com.example.todo.dto.TodoUpdateRequest;

import java.util.List;

public interface TodoService {

    TodoResponse create(TodoCreateRequest request);

    List<TodoResponse> findAll();

    TodoResponse findById(Long id);

    TodoResponse update(Long id, TodoUpdateRequest request);

    void delete(Long id);
}
