import { beforeEach, describe, expect, it } from "vitest";

import { DELETE, PUT } from "./[id]/route";
import { GET, POST } from "./route";
import { todoStore } from "@/app/lib/todos";

function jsonRequest(path: string, body?: unknown) {
  return new Request(`http://localhost${path}`, {
    body: body === undefined ? undefined : JSON.stringify(body),
    headers: { "Content-Type": "application/json" },
    method: body === undefined ? "GET" : "POST",
  });
}

describe("Todo route handlers", () => {
  beforeEach(() => {
    todoStore.reset();
  });

  it("creates and lists todos", async () => {
    const createResponse = await POST(jsonRequest("/api/todos", { title: "Learn Next.js" }));
    const created = await createResponse.json();

    expect(createResponse.status).toBe(201);
    expect(created.title).toBe("Learn Next.js");

    const listResponse = await GET(jsonRequest("/api/todos?filter=active"));
    const snapshot = await listResponse.json();

    expect(snapshot.todos).toHaveLength(1);
    expect(snapshot.stats).toEqual({ total: 1, active: 1, completed: 0 });
  });

  it("updates and deletes todos", async () => {
    const todo = todoStore.create("Review API");
    const updateResponse = await PUT(
      new Request(`http://localhost/api/todos/${todo.id}`, {
        body: JSON.stringify({ completed: true, title: "Review Todo API" }),
        headers: { "Content-Type": "application/json" },
        method: "PUT",
      }),
      { params: { id: todo.id } },
    );

    expect(updateResponse.status).toBe(200);
    expect(await updateResponse.json()).toMatchObject({
      completed: true,
      title: "Review Todo API",
    });

    const deleteResponse = await DELETE(
      new Request(`http://localhost/api/todos/${todo.id}`, { method: "DELETE" }),
      { params: { id: todo.id } },
    );

    expect(deleteResponse.status).toBe(204);
    expect(todoStore.list().todos).toHaveLength(0);
  });

  it("returns errors for invalid input and unknown ids", async () => {
    const invalidResponse = await POST(jsonRequest("/api/todos", { title: " " }));
    expect(invalidResponse.status).toBe(400);

    const missingResponse = await PUT(
      new Request("http://localhost/api/todos/missing", {
        body: JSON.stringify({ completed: true }),
        headers: { "Content-Type": "application/json" },
        method: "PUT",
      }),
      { params: { id: "missing" } },
    );

    expect(missingResponse.status).toBe(404);
  });
});
