import { describe, expect, it } from "vitest";

import { TodoNotFoundError, TodoStore, TodoValidationError } from "./todos";

describe("TodoStore", () => {
  it("creates, filters, updates, and deletes todos", () => {
    const store = new TodoStore();
    const first = store.create("  Write tests  ");
    const second = store.create("Ship feature");

    expect(store.list().stats).toEqual({ total: 2, active: 2, completed: 0 });
    expect(first.title).toBe("Write tests");

    store.update(first.id, { completed: true });
    expect(store.list("completed").todos).toHaveLength(1);
    expect(store.list("active").todos).toEqual([second]);

    store.update(second.id, { title: "Ship Todo feature" });
    expect(store.list("active").todos[0].title).toBe("Ship Todo feature");

    store.delete(first.id);
    expect(store.list().stats).toEqual({ total: 1, active: 1, completed: 0 });
  });

  it("rejects blank titles and unknown ids", () => {
    const store = new TodoStore();

    expect(() => store.create(" ")).toThrow(TodoValidationError);
    expect(() => store.update("missing", { completed: true })).toThrow(
      TodoNotFoundError,
    );
    expect(() => store.delete("missing")).toThrow(TodoNotFoundError);
  });
});
