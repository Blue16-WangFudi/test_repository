package com.example.todo.dto;

import jakarta.validation.constraints.Size;

public class TodoUpdateRequest {

    @Size(max = 120, message = "title must be at most 120 characters")
    private String title;

    @Size(max = 1000, message = "description must be at most 1000 characters")
    private String description;

    private Boolean completed;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }
}
