package com.example.todo.controller;

import com.example.todo.dto.TodoCreateRequest;
import com.example.todo.dto.TodoResponse;
import com.example.todo.dto.TodoUpdateRequest;
import com.example.todo.exception.ResourceNotFoundException;
import com.example.todo.service.TodoService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(TodoController.class)
class TodoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private TodoService todoService;

    @Test
    void createReturnsCreatedTodo() throws Exception {
        TodoCreateRequest request = new TodoCreateRequest();
        request.setTitle("New todo");
        request.setDescription("description");

        when(todoService.create(any(TodoCreateRequest.class))).thenReturn(response(1L, "New todo", "description", false));

        mockMvc.perform(post("/api/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("New todo"));
    }

    @Test
    void createRejectsBlankTitle() throws Exception {
        TodoCreateRequest request = new TodoCreateRequest();
        request.setTitle("");

        mockMvc.perform(post("/api/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.messages[0]").value("title: title must not be blank"));
    }

    @Test
    void findAllReturnsTodos() throws Exception {
        when(todoService.findAll()).thenReturn(List.of(
                response(1L, "A", null, false),
                response(2L, "B", null, true)
        ));

        mockMvc.perform(get("/api/todos"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("A"))
                .andExpect(jsonPath("$[1].completed").value(true));
    }

    @Test
    void findByIdReturnsNotFound() throws Exception {
        when(todoService.findById(99L)).thenThrow(new ResourceNotFoundException("Todo not found: 99"));

        mockMvc.perform(get("/api/todos/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.messages[0]").value("Todo not found: 99"));
    }

    @Test
    void updateReturnsUpdatedTodo() throws Exception {
        TodoUpdateRequest request = new TodoUpdateRequest();
        request.setCompleted(true);

        when(todoService.update(eq(1L), any(TodoUpdateRequest.class)))
                .thenReturn(response(1L, "Existing", null, true));

        mockMvc.perform(put("/api/todos/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completed").value(true));
    }

    @Test
    void deleteReturnsNoContent() throws Exception {
        doNothing().when(todoService).delete(1L);

        mockMvc.perform(delete("/api/todos/1"))
                .andExpect(status().isNoContent());
    }

    private TodoResponse response(Long id, String title, String description, boolean completed) {
        TodoResponse response = new TodoResponse();
        response.setId(id);
        response.setTitle(title);
        response.setDescription(description);
        response.setCompleted(completed);
        response.setCreatedAt(LocalDateTime.now());
        response.setUpdatedAt(LocalDateTime.now());
        return response;
    }
}
