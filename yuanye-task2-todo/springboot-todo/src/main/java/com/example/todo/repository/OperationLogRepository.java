package com.example.todo.repository;

import com.example.todo.entity.OperationLog;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface OperationLogRepository extends MongoRepository<OperationLog, String> {
}
