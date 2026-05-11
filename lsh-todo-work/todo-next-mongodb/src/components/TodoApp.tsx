"use client";

import { FormEvent, useEffect, useState } from "react";
import type { Todo } from "@/types/todo";

export default function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [title, setTitle] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let isCurrent = true;

    fetch("/api/todos")
      .then(async (response) => {
        const data = (await response.json()) as {
          todos?: Todo[];
          error?: string;
        };

        if (!response.ok) {
          throw new Error(data.error ?? "Failed to load todos");
        }

        return data.todos ?? [];
      })
      .then((nextTodos) => {
        if (isCurrent) {
          setTodos(nextTodos);
        }
      })
      .catch((err) => {
        if (isCurrent) {
          setError(err instanceof Error ? err.message : "Failed to load todos");
        }
      })
      .finally(() => {
        if (isCurrent) {
          setIsLoading(false);
        }
      });

    return () => {
      isCurrent = false;
    };
  }, []);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const nextTitle = title.trim();
    if (!nextTitle) {
      return;
    }

    setIsSaving(true);
    setError("");

    try {
      const response = await fetch("/api/todos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: nextTitle }),
      });
      const data = (await response.json()) as { todo?: Todo; error?: string };

      if (!response.ok || !data.todo) {
        throw new Error(data.error ?? "Failed to add todo");
      }

      setTodos((current) => [data.todo!, ...current]);
      setTitle("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to add todo");
    } finally {
      setIsSaving(false);
    }
  }

  async function handleDelete(id: string) {
    const previousTodos = todos;
    setTodos((current) => current.filter((todo) => todo.id !== id));
    setError("");

    try {
      const response = await fetch(`/api/todos/${id}`, { method: "DELETE" });
      const data = (await response.json()) as { error?: string };

      if (!response.ok) {
        throw new Error(data.error ?? "Failed to delete todo");
      }
    } catch (err) {
      setTodos(previousTodos);
      setError(err instanceof Error ? err.message : "Failed to delete todo");
    }
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col px-6 py-12 sm:py-16">
      <section className="mb-8">
        <p className="text-sm font-medium uppercase tracking-[0.18em] text-teal-700">
          Next.js + MongoDB
        </p>
        <h1 className="mt-3 text-4xl font-semibold text-slate-950 sm:text-5xl">
          Todo List
        </h1>
      </section>

      <form
        className="flex flex-col gap-3 rounded-lg border border-slate-200 bg-white p-4 shadow-sm sm:flex-row"
        onSubmit={handleSubmit}
      >
        <label className="sr-only" htmlFor="todo-title">
          Todo title
        </label>
        <input
          id="todo-title"
          className="min-h-12 flex-1 rounded-md border border-slate-300 px-4 text-base text-slate-950 outline-none transition focus:border-teal-600 focus:ring-2 focus:ring-teal-100"
          value={title}
          onChange={(event) => setTitle(event.target.value)}
          placeholder="Add a new todo"
        />
        <button
          className="min-h-12 rounded-md bg-slate-950 px-5 font-medium text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:bg-slate-400"
          disabled={isSaving || !title.trim()}
          type="submit"
        >
          {isSaving ? "Adding..." : "Add"}
        </button>
      </form>

      {error ? (
        <p className="mt-4 rounded-md border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </p>
      ) : null}

      <section className="mt-8">
        {isLoading ? (
          <p className="text-slate-500">Loading todos...</p>
        ) : todos.length === 0 ? (
          <p className="rounded-lg border border-dashed border-slate-300 bg-white px-5 py-8 text-center text-slate-500">
            No todos yet.
          </p>
        ) : (
          <ul className="divide-y divide-slate-200 rounded-lg border border-slate-200 bg-white shadow-sm">
            {todos.map((todo) => (
              <li
                className="flex items-center justify-between gap-4 px-4 py-4"
                key={todo.id}
              >
                <div>
                  <p className="font-medium text-slate-950">{todo.title}</p>
                  <time
                    className="text-sm text-slate-500"
                    dateTime={todo.createdAt}
                  >
                    {new Intl.DateTimeFormat("en", {
                      dateStyle: "medium",
                      timeStyle: "short",
                    }).format(new Date(todo.createdAt))}
                  </time>
                </div>
                <button
                  aria-label={`Delete ${todo.title}`}
                  className="rounded-md border border-slate-300 px-3 py-2 text-sm font-medium text-slate-700 transition hover:border-red-300 hover:bg-red-50 hover:text-red-700"
                  onClick={() => void handleDelete(todo.id)}
                  type="button"
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
