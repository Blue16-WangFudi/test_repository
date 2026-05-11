import type { CreateTodoInput, UpdateTodoInput } from "./types";

const MAX_TITLE_LENGTH = 160;

export function parseCreateTodoInput(input: unknown): CreateTodoInput {
  if (!isRecord(input) || typeof input.title !== "string") {
    throw new Error("Todo title is required.");
  }

  const title = input.title.trim();
  if (!title) {
    throw new Error("Todo title cannot be empty.");
  }

  if (title.length > MAX_TITLE_LENGTH) {
    throw new Error(`Todo title cannot exceed ${MAX_TITLE_LENGTH} characters.`);
  }

  return { title };
}

export function parseUpdateTodoInput(input: unknown): UpdateTodoInput {
  if (!isRecord(input) || typeof input.completed !== "boolean") {
    throw new Error("Todo completed status must be a boolean.");
  }

  return { completed: input.completed };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
