import { NextResponse } from "next/server";

import {
  todoStore,
  TodoNotFoundError,
  TodoValidationError,
} from "@/app/lib/todos";

type TodoRouteContext = {
  params: Promise<{ id: string }> | { id: string };
};

async function readId(context: TodoRouteContext) {
  const params = await context.params;
  return params.id;
}

export async function PUT(request: Request, context: TodoRouteContext) {
  const payload = await request.json().catch(() => null);
  const update: { title?: string; completed?: boolean } = {};

  if (payload && typeof payload.title === "string") {
    update.title = payload.title;
  }

  if (payload && typeof payload.completed === "boolean") {
    update.completed = payload.completed;
  }

  try {
    return NextResponse.json(todoStore.update(await readId(context), update));
  } catch (error) {
    if (error instanceof TodoNotFoundError) {
      return NextResponse.json({ error: error.message }, { status: 404 });
    }

    if (error instanceof TodoValidationError) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    throw error;
  }
}

export async function DELETE(_request: Request, context: TodoRouteContext) {
  try {
    todoStore.delete(await readId(context));
    return new NextResponse(null, { status: 204 });
  } catch (error) {
    if (error instanceof TodoNotFoundError) {
      return NextResponse.json({ error: error.message }, { status: 404 });
    }

    throw error;
  }
}
