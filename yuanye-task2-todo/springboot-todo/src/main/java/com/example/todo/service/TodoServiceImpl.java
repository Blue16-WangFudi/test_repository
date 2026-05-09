package com.example.todo.service;

import com.example.todo.dto.TodoCreateRequest;
import com.example.todo.dto.TodoResponse;
import com.example.todo.dto.TodoUpdateRequest;
import com.example.todo.entity.OperationLog;
import com.example.todo.entity.Todo;
import com.example.todo.exception.ResourceNotFoundException;
import com.example.todo.repository.OperationLogRepository;
import com.example.todo.repository.TodoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TodoServiceImpl implements TodoService {

    private final TodoRepository todoRepository;
    private final OperationLogRepository operationLogRepository;

    public TodoServiceImpl(TodoRepository todoRepository, OperationLogRepository operationLogRepository) {
        this.todoRepository = todoRepository;
        this.operationLogRepository = operationLogRepository;
    }

    @Override
    @Transactional
    public TodoResponse create(TodoCreateRequest request) {
        Todo todo = new Todo();
        todo.setTitle(request.getTitle());
        todo.setDescription(request.getDescription());
        todo.setCompleted(Boolean.TRUE.equals(request.getCompleted()));

        Todo saved = todoRepository.save(todo);
        log(saved.getId(), "CREATE", "Created todo: " + saved.getTitle());
        return TodoResponse.from(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TodoResponse> findAll() {
        return todoRepository.findAll()
                .stream()
                .map(TodoResponse::from)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public TodoResponse findById(Long id) {
        return TodoResponse.from(getTodo(id));
    }

    @Override
    @Transactional
    public TodoResponse update(Long id, TodoUpdateRequest request) {
        Todo todo = getTodo(id);

        if (request.getTitle() != null) {
            todo.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            todo.setDescription(request.getDescription());
        }
        if (request.getCompleted() != null) {
            todo.setCompleted(request.getCompleted());
        }

        Todo saved = todoRepository.save(todo);
        log(saved.getId(), "UPDATE", "Updated todo: " + saved.getTitle());
        return TodoResponse.from(saved);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Todo todo = getTodo(id);
        todoRepository.delete(todo);
        log(id, "DELETE", "Deleted todo: " + todo.getTitle());
    }

    private Todo getTodo(Long id) {
        return todoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Todo not found: " + id));
    }

    private void log(Long todoId, String operation, String detail) {
        operationLogRepository.save(new OperationLog(todoId, operation, detail));
    }
}
