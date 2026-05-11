"use client";

import { FormEvent, useEffect, useState } from "react";

import type { Todo, TodoFilter, TodoSnapshot } from "@/app/lib/todos";

const filters: Array<{ value: TodoFilter; label: string }> = [
  { value: "all", label: "All" },
  { value: "active", label: "Active" },
  { value: "completed", label: "Completed" },
];

async function requestJson<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(path, init);

  if (!response.ok) {
    const payload = (await response.json().catch(() => null)) as
      | { error?: string }
      | null;
    throw new Error(payload?.error ?? "Todo request failed");
  }

  return response.json() as Promise<T>;
}

export default function TodoApp() {
  const [snapshot, setSnapshot] = useState<TodoSnapshot>({
    todos: [],
    stats: { total: 0, active: 0, completed: 0 },
  });
  const [filter, setFilter] = useState<TodoFilter>("all");
  const [newTitle, setNewTitle] = useState("");
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingTitle, setEditingTitle] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  async function refresh() {
    setIsLoading(true);
    setError(null);

    try {
      setSnapshot(await requestJson<TodoSnapshot>(`/api/todos?filter=${filter}`));
    } catch (requestError) {
      setError((requestError as Error).message);
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    let isActive = true;

    requestJson<TodoSnapshot>(`/api/todos?filter=${filter}`)
      .then((nextSnapshot) => {
        if (isActive) {
          setSnapshot(nextSnapshot);
          setError(null);
        }
      })
      .catch((requestError: Error) => {
        if (isActive) {
          setError(requestError.message);
        }
      })
      .finally(() => {
        if (isActive) {
          setIsLoading(false);
        }
      });

    return () => {
      isActive = false;
    };
  }, [filter]);

  async function createTodo(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await requestJson<Todo>("/api/todos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: newTitle }),
      });
      setNewTitle("");
      await refresh();
    } catch (requestError) {
      setError((requestError as Error).message);
    }
  }

  async function updateTodo(id: string, update: Partial<Pick<Todo, "title" | "completed">>) {
    try {
      await requestJson<Todo>(`/api/todos/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(update),
      });
      setEditingId(null);
      await refresh();
    } catch (requestError) {
      setError((requestError as Error).message);
    }
  }

  async function deleteTodo(id: string) {
    const response = await fetch(`/api/todos/${id}`, { method: "DELETE" });

    if (!response.ok) {
      setError("Unable to delete todo");
      return;
    }

    await refresh();
  }

  return (
    <section className="mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-6 px-6 py-10">
      <header className="flex flex-col gap-3">
        <p className="text-sm font-semibold uppercase tracking-normal text-emerald-700">
          Next.js Full-stack Todo
        </p>
        <h1 className="text-3xl font-semibold text-zinc-950">Todo List</h1>
        <div className="grid gap-3 sm:grid-cols-3">
          <Stat label="Total" value={snapshot.stats.total} />
          <Stat label="Active" value={snapshot.stats.active} />
          <Stat label="Completed" value={snapshot.stats.completed} />
        </div>
      </header>

      <form className="flex gap-2" onSubmit={createTodo}>
        <input
          className="min-w-0 flex-1 rounded border border-zinc-300 bg-white px-3 py-2 text-sm text-zinc-950 outline-none focus:border-emerald-600"
          onChange={(event) => setNewTitle(event.target.value)}
          placeholder="Add a todo"
          value={newTitle}
        />
        <button className="rounded bg-emerald-700 px-4 py-2 text-sm font-semibold text-white" type="submit">
          Add
        </button>
      </form>

      <div className="flex flex-wrap gap-2" role="tablist" aria-label="Todo filters">
        {filters.map((item) => (
          <button
            aria-selected={filter === item.value}
            className={`rounded border px-3 py-2 text-sm font-medium ${
              filter === item.value
                ? "border-emerald-700 bg-emerald-700 text-white"
                : "border-zinc-300 bg-white text-zinc-700"
            }`}
            key={item.value}
            onClick={() => setFilter(item.value)}
            role="tab"
            type="button"
          >
            {item.label}
          </button>
        ))}
      </div>

      {error ? <p className="rounded border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p> : null}

      <div className="divide-y divide-zinc-200 rounded border border-zinc-200 bg-white">
        {isLoading ? <p className="p-4 text-sm text-zinc-500">Loading todos...</p> : null}
        {!isLoading && snapshot.todos.length === 0 ? (
          <p className="p-4 text-sm text-zinc-500">No todos in this view.</p>
        ) : null}
        {snapshot.todos.map((todo) => (
          <article className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center" key={todo.id}>
            <label className="flex min-w-0 flex-1 items-center gap-3">
              <input
                checked={todo.completed}
                className="h-4 w-4"
                onChange={(event) => updateTodo(todo.id, { completed: event.target.checked })}
                type="checkbox"
              />
              {editingId === todo.id ? (
                <input
                  className="min-w-0 flex-1 rounded border border-zinc-300 px-2 py-1 text-sm"
                  onChange={(event) => setEditingTitle(event.target.value)}
                  value={editingTitle}
                />
              ) : (
                <span className={`truncate text-sm ${todo.completed ? "text-zinc-400 line-through" : "text-zinc-900"}`}>
                  {todo.title}
                </span>
              )}
            </label>
            <div className="flex gap-2">
              {editingId === todo.id ? (
                <button
                  className="rounded border border-emerald-700 px-3 py-1 text-sm text-emerald-700"
                  onClick={() => updateTodo(todo.id, { title: editingTitle })}
                  type="button"
                >
                  Save
                </button>
              ) : (
                <button
                  className="rounded border border-zinc-300 px-3 py-1 text-sm text-zinc-700"
                  onClick={() => {
                    setEditingId(todo.id);
                    setEditingTitle(todo.title);
                  }}
                  type="button"
                >
                  Edit
                </button>
              )}
              <button
                className="rounded border border-red-300 px-3 py-1 text-sm text-red-700"
                onClick={() => deleteTodo(todo.id)}
                type="button"
              >
                Delete
              </button>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded border border-zinc-200 bg-white p-4">
      <p className="text-sm text-zinc-500">{label}</p>
      <p className="text-2xl font-semibold text-zinc-950">{value}</p>
    </div>
  );
}
