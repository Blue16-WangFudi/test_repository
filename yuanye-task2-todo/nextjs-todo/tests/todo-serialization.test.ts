import { describe, expect, it } from "vitest";
import { serializeTodo } from "@/lib/models/todo";

describe("todo serialization", () => {
  it("maps a Mongo document into the public todo shape", () => {
    const createdAt = new Date("2026-05-08T12:00:00.000Z");
    const updatedAt = new Date("2026-05-08T13:00:00.000Z");
    const todo = serializeTodo({
      _id: { toString: () => "663d0ca5e8a6f7a8de5aa001" },
      title: "Write tests",
      completed: false,
      createdAt,
      updatedAt,
    } as Parameters<typeof serializeTodo>[0]);

    expect(todo).toEqual({
      id: "663d0ca5e8a6f7a8de5aa001",
      title: "Write tests",
      completed: false,
      createdAt: "2026-05-08T12:00:00.000Z",
      updatedAt: "2026-05-08T13:00:00.000Z",
    });
  });
});
