import { describe, expect, it } from "vitest";
import {
  parseCreateTodoInput,
  parseUpdateTodoInput,
} from "@/lib/todos/validation";

describe("todo input validation", () => {
  it("trims and accepts a valid todo title", () => {
    expect(parseCreateTodoInput({ title: "  Ship project  " })).toEqual({
      title: "Ship project",
    });
  });

  it("rejects empty todo titles", () => {
    expect(() => parseCreateTodoInput({ title: "   " })).toThrow(
      "Todo title cannot be empty.",
    );
  });

  it("rejects invalid completed values", () => {
    expect(() => parseUpdateTodoInput({ completed: "yes" })).toThrow(
      "Todo completed status must be a boolean.",
    );
  });

  it("accepts boolean completed values", () => {
    expect(parseUpdateTodoInput({ completed: true })).toEqual({
      completed: true,
    });
  });
});
