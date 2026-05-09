package com.example.todo.service;

import com.example.todo.dto.TodoCreateRequest;
import com.example.todo.dto.TodoResponse;
import com.example.todo.dto.TodoUpdateRequest;
import com.example.todo.entity.OperationLog;
import com.example.todo.entity.Todo;
import com.example.todo.exception.ResourceNotFoundException;
import com.example.todo.repository.OperationLogRepository;
import com.example.todo.repository.TodoRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TodoServiceImplTest {

    @Mock
    private TodoRepository todoRepository;

    @Mock
    private OperationLogRepository operationLogRepository;

    @InjectMocks
    private TodoServiceImpl todoService;

    @Test
    void createSavesTodoAndOperationLog() {
        TodoCreateRequest request = new TodoCreateRequest();
        request.setTitle("Write tests");
        request.setDescription("Cover service");

        Todo saved = todo(1L, "Write tests", "Cover service", false);
        when(todoRepository.save(any(Todo.class))).thenReturn(saved);

        TodoResponse response = todoService.create(request);

        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getTitle()).isEqualTo("Write tests");

        ArgumentCaptor<OperationLog> logCaptor = ArgumentCaptor.forClass(OperationLog.class);
        verify(operationLogRepository).save(logCaptor.capture());
        assertThat(logCaptor.getValue().getTodoId()).isEqualTo(1L);
        assertThat(logCaptor.getValue().getOperation()).isEqualTo("CREATE");
    }

    @Test
    void findAllReturnsTodoResponses() {
        when(todoRepository.findAll()).thenReturn(List.of(
                todo(1L, "A", "first", false),
                todo(2L, "B", "second", true)
        ));

        List<TodoResponse> responses = todoService.findAll();

        assertThat(responses).hasSize(2);
        assertThat(responses).extracting(TodoResponse::getTitle).containsExactly("A", "B");
    }

    @Test
    void updateChangesProvidedFieldsOnly() {
        Todo existing = todo(1L, "Old title", "Old description", false);
        TodoUpdateRequest request = new TodoUpdateRequest();
        request.setTitle("New title");
        request.setCompleted(true);

        when(todoRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(todoRepository.save(existing)).thenReturn(existing);

        TodoResponse response = todoService.update(1L, request);

        assertThat(response.getTitle()).isEqualTo("New title");
        assertThat(response.getDescription()).isEqualTo("Old description");
        assertThat(response.isCompleted()).isTrue();
        verify(operationLogRepository).save(any(OperationLog.class));
    }

    @Test
    void deleteRemovesTodoAndWritesLog() {
        Todo existing = todo(1L, "Delete me", null, false);
        when(todoRepository.findById(1L)).thenReturn(Optional.of(existing));

        todoService.delete(1L);

        verify(todoRepository).delete(existing);
        verify(operationLogRepository).save(any(OperationLog.class));
    }

    @Test
    void findByIdThrowsWhenTodoDoesNotExist() {
        when(todoRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> todoService.findById(99L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Todo not found: 99");
    }

    private Todo todo(Long id, String title, String description, boolean completed) {
        Todo todo = new Todo();
        todo.setId(id);
        todo.setTitle(title);
        todo.setDescription(description);
        todo.setCompleted(completed);
        todo.setCreatedAt(LocalDateTime.now());
        todo.setUpdatedAt(LocalDateTime.now());
        return todo;
    }
}
