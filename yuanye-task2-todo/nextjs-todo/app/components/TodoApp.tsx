"use client";

import { useEffect, useMemo, useState } from "react";
import type { FormEvent } from "react";
import type { Todo } from "@/lib/todos/types";

type ApiError = {
  error?: string;
};

export function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [title, setTitle] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const remainingCount = useMemo(
    () => todos.filter((todo) => !todo.completed).length,
    [todos],
  );

  useEffect(() => {
    let active = true;

    async function loadTodos() {
      setError(null);
      try {
        const response = await fetch("/api/todos", { cache: "no-store" });
        const data = await parseJson<{ todos: Todo[] }>(response);

        if (active) {
          setTodos(data.todos);
        }
      } catch (loadError) {
        if (active) {
          setError(getErrorMessage(loadError));
        }
      } finally {
        if (active) {
          setIsLoading(false);
        }
      }
    }

    loadTodos();

    return () => {
      active = false;
    };
  }, []);

  async function handleCreate(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const nextTitle = title.trim();
    if (!nextTitle) {
      return;
    }

    setIsSaving(true);
    setError(null);

    try {
      const response = await fetch("/api/todos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: nextTitle }),
      });
      const data = await parseJson<{ todo: Todo }>(response);

      setTodos((current) => [data.todo, ...current]);
      setTitle("");
    } catch (createError) {
      setError(getErrorMessage(createError));
    } finally {
      setIsSaving(false);
    }
  }

  async function toggleTodo(todo: Todo) {
    const nextCompleted = !todo.completed;
    const previous = todos;

    setTodos((current) =>
      current.map((item) =>
        item.id === todo.id ? { ...item, completed: nextCompleted } : item,
      ),
    );
    setError(null);

    try {
      const response = await fetch(`/api/todos/${todo.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ completed: nextCompleted }),
      });
      const data = await parseJson<{ todo: Todo }>(response);

      setTodos((current) =>
        current.map((item) => (item.id === todo.id ? data.todo : item)),
      );
    } catch (updateError) {
      setTodos(previous);
      setError(getErrorMessage(updateError));
    }
  }

  async function removeTodo(todo: Todo) {
    const previous = todos;

    setTodos((current) => current.filter((item) => item.id !== todo.id));
    setError(null);

    try {
      const response = await fetch(`/api/todos/${todo.id}`, {
        method: "DELETE",
      });
      await parseJson<{ ok: true }>(response);
    } catch (deleteError) {
      setTodos(previous);
      setError(getErrorMessage(deleteError));
    }
  }

  return (
    <main className="min-h-screen bg-[#f7f7f2] px-4 py-8 text-[#202124] sm:px-6 lg:px-8">
      <section className="mx-auto flex w-full max-w-3xl flex-col gap-6">
        <header className="flex flex-col gap-3 border-b border-[#d8d2c4] pb-5 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-sm font-medium uppercase text-[#6d675d]">
              Next.js App Router
            </p>
            <h1 className="mt-2 text-4xl font-semibold tracking-normal text-[#1f2a2e]">
              Todo List
            </h1>
          </div>
          <div className="text-sm text-[#565b5f]">
            {remainingCount} open / {todos.length} total
          </div>
        </header>

        <form
          onSubmit={handleCreate}
          className="flex flex-col gap-3 sm:flex-row"
        >
          <input
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            className="min-h-12 flex-1 rounded-md border border-[#c9c2b4] bg-white px-4 text-base outline-none transition focus:border-[#31685f] focus:ring-2 focus:ring-[#31685f]/20"
            placeholder="Add a todo"
            maxLength={160}
            disabled={isSaving}
          />
          <button
            type="submit"
            disabled={isSaving || !title.trim()}
            className="min-h-12 rounded-md bg-[#31685f] px-5 text-sm font-semibold text-white transition hover:bg-[#28564f] disabled:cursor-not-allowed disabled:bg-[#9ba7a2]"
          >
            {isSaving ? "Adding" : "Add"}
          </button>
        </form>

        {error ? (
          <div className="rounded-md border border-[#c65948] bg-[#fff7f5] px-4 py-3 text-sm text-[#8c2f23]">
            {error}
          </div>
        ) : null}

        <div className="overflow-hidden rounded-md border border-[#d8d2c4] bg-white">
          {isLoading ? (
            <div className="px-4 py-8 text-center text-sm text-[#6d675d]">
              Loading todos...
            </div>
          ) : todos.length === 0 ? (
            <div className="px-4 py-8 text-center text-sm text-[#6d675d]">
              No todos yet.
            </div>
          ) : (
            <ul className="divide-y divide-[#e4ded1]">
              {todos.map((todo) => (
                <li
                  key={todo.id}
                  className="flex min-h-16 items-center gap-3 px-4 py-3"
                >
                  <input
                    type="checkbox"
                    checked={todo.completed}
                    onChange={() => toggleTodo(todo)}
                    className="h-5 w-5 rounded border-[#9e978a] text-[#31685f] accent-[#31685f]"
                    aria-label={`Mark ${todo.title} ${
                      todo.completed ? "incomplete" : "complete"
                    }`}
                  />
                  <span
                    className={`flex-1 text-base ${
                      todo.completed
                        ? "text-[#7d817e] line-through"
                        : "text-[#202124]"
                    }`}
                  >
                    {todo.title}
                  </span>
                  <button
                    type="button"
                    onClick={() => removeTodo(todo)}
                    className="rounded-md border border-[#d3c9bd] px-3 py-2 text-sm font-medium text-[#8c2f23] transition hover:border-[#c65948] hover:bg-[#fff7f5]"
                  >
                    Delete
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
      </section>
    </main>
  );
}

async function parseJson<T>(response: Response): Promise<T> {
  const data = (await response.json()) as T & ApiError;

  if (!response.ok) {
    throw new Error(data.error ?? "Request failed.");
  }

  return data;
}

function getErrorMessage(error: unknown) {
  return error instanceof Error ? error.message : "Unexpected error.";
}
