import mongoose, { Schema, type HydratedDocument, type Model } from "mongoose";
import type { Todo } from "@/lib/todos/types";

type TodoRecord = {
  title: string;
  completed: boolean;
  createdAt: Date;
  updatedAt: Date;
};

export type TodoDocument = HydratedDocument<TodoRecord>;

const TodoSchema = new Schema<TodoRecord>(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 160,
    },
    completed: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  },
);

export const TodoModel =
  (mongoose.models.Todo as Model<TodoRecord> | undefined) ??
  mongoose.model<TodoRecord>("Todo", TodoSchema);

export function serializeTodo(todo: TodoDocument): Todo {
  return {
    id: todo._id.toString(),
    title: todo.title,
    completed: todo.completed,
    createdAt: todo.createdAt.toISOString(),
    updatedAt: todo.updatedAt.toISOString(),
  };
}
