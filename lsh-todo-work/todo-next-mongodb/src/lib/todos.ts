import { ObjectId } from "mongodb";
import { getMongoClient } from "./mongodb";
import type { Todo } from "@/types/todo";

type TodoDocument = {
  _id: ObjectId;
  title: string;
  createdAt: Date;
};

const databaseName = process.env.MONGODB_DB ?? "todo_next_app";
const collectionName = "todos";

async function todoCollection() {
  const client = await getMongoClient();
  return client.db(databaseName).collection<TodoDocument>(collectionName);
}

function serializeTodo(todo: TodoDocument): Todo {
  return {
    id: todo._id.toString(),
    title: todo.title,
    createdAt: todo.createdAt.toISOString(),
  };
}

export async function listTodos(): Promise<Todo[]> {
  const collection = await todoCollection();
  const todos = await collection.find().sort({ createdAt: -1 }).toArray();

  return todos.map(serializeTodo);
}

export async function createTodo(title: string): Promise<Todo> {
  const collection = await todoCollection();
  const now = new Date();
  const result = await collection.insertOne({
    _id: new ObjectId(),
    title,
    createdAt: now,
  });

  return {
    id: result.insertedId.toString(),
    title,
    createdAt: now.toISOString(),
  };
}

export async function deleteTodo(id: string): Promise<boolean> {
  if (!ObjectId.isValid(id)) {
    return false;
  }

  const collection = await todoCollection();
  const result = await collection.deleteOne({ _id: new ObjectId(id) });

  return result.deletedCount === 1;
}
