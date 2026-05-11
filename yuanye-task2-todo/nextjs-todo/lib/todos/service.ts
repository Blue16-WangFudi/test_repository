import mongoose from "mongoose";
import { connectMongoDB } from "@/lib/db/mongodb";
import { recordTodoOperation } from "@/lib/db/mysql";
import { TodoModel, serializeTodo } from "@/lib/models/todo";
import type { CreateTodoInput, Todo, UpdateTodoInput } from "./types";

export async function listTodos(): Promise<Todo[]> {
  await connectMongoDB();
  const todos = await TodoModel.find().sort({ createdAt: -1 });
  return todos.map(serializeTodo);
}

export async function createTodo(input: CreateTodoInput): Promise<Todo> {
  await connectMongoDB();
  const todo = await TodoModel.create({
    title: input.title,
    completed: false,
  });
  const serialized = serializeTodo(todo);

  await recordTodoOperation(serialized.id, "create", {
    title: serialized.title,
    completed: serialized.completed,
  });

  return serialized;
}

export async function updateTodo(
  id: string,
  input: UpdateTodoInput,
): Promise<Todo | null> {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return null;
  }

  await connectMongoDB();
  const todo = await TodoModel.findByIdAndUpdate(
    id,
    { completed: input.completed },
    { new: true, runValidators: true },
  );

  if (!todo) {
    return null;
  }

  const serialized = serializeTodo(todo);
  await recordTodoOperation(serialized.id, "update", {
    completed: serialized.completed,
  });

  return serialized;
}

export async function deleteTodo(id: string): Promise<boolean> {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return false;
  }

  await connectMongoDB();
  const todo = await TodoModel.findByIdAndDelete(id);

  if (!todo) {
    return false;
  }

  await recordTodoOperation(id, "delete", {
    title: todo.title,
    completed: todo.completed,
  });

  return true;
}
