export type TodoFilter = "all" | "active" | "completed";

export type Todo = {
  id: string;
  title: string;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
};

export type TodoStats = {
  total: number;
  active: number;
  completed: number;
};

export type TodoSnapshot = {
  todos: Todo[];
  stats: TodoStats;
};

type TodoUpdate = {
  title?: string;
  completed?: boolean;
};

export class TodoValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "TodoValidationError";
  }
}

export class TodoNotFoundError extends Error {
  constructor(id: string) {
    super(`Todo ${id} was not found`);
    this.name = "TodoNotFoundError";
  }
}

export class TodoStore {
  private todos = new Map<string, Todo>();

  list(filter: TodoFilter = "all"): TodoSnapshot {
    const todos = Array.from(this.todos.values())
      .filter((todo) => {
        if (filter === "active") {
          return !todo.completed;
        }

        if (filter === "completed") {
          return todo.completed;
        }

        return true;
      })
      .sort((first, second) => first.createdAt.localeCompare(second.createdAt));

    return {
      todos,
      stats: this.stats(),
    };
  }

  create(title: string): Todo {
    const normalizedTitle = this.normalizeTitle(title);
    const now = new Date().toISOString();
    const todo: Todo = {
      id: crypto.randomUUID(),
      title: normalizedTitle,
      completed: false,
      createdAt: now,
      updatedAt: now,
    };

    this.todos.set(todo.id, todo);
    return todo;
  }

  update(id: string, update: TodoUpdate): Todo {
    const existing = this.todos.get(id);

    if (!existing) {
      throw new TodoNotFoundError(id);
    }

    const next: Todo = {
      ...existing,
      updatedAt: new Date().toISOString(),
    };

    if (update.title !== undefined) {
      next.title = this.normalizeTitle(update.title);
    }

    if (update.completed !== undefined) {
      next.completed = update.completed;
    }

    this.todos.set(id, next);
    return next;
  }

  delete(id: string): void {
    if (!this.todos.delete(id)) {
      throw new TodoNotFoundError(id);
    }
  }

  reset(seed: Todo[] = []): void {
    this.todos.clear();
    seed.forEach((todo) => {
      this.todos.set(todo.id, todo);
    });
  }

  private stats(): TodoStats {
    const todos = Array.from(this.todos.values());
    const completed = todos.filter((todo) => todo.completed).length;

    return {
      total: todos.length,
      active: todos.length - completed,
      completed,
    };
  }

  private normalizeTitle(title: string): string {
    const normalizedTitle = title.trim();

    if (!normalizedTitle) {
      throw new TodoValidationError("Todo title is required");
    }

    if (normalizedTitle.length > 120) {
      throw new TodoValidationError("Todo title must be 120 characters or less");
    }

    return normalizedTitle;
  }
}

export const todoStore = new TodoStore();

export function parseTodoFilter(value: string | null): TodoFilter {
  if (value === "active" || value === "completed") {
    return value;
  }

  return "all";
}
