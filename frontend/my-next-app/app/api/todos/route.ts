import { NextResponse } from "next/server";

import {
  parseTodoFilter,
  todoStore,
  TodoValidationError,
} from "@/app/lib/todos";

export function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  return NextResponse.json(todoStore.list(parseTodoFilter(searchParams.get("filter"))));
}

export async function POST(request: Request) {
  const payload = await request.json().catch(() => null);

  if (!payload || typeof payload.title !== "string") {
    return NextResponse.json({ error: "Todo title is required" }, { status: 400 });
  }

  try {
    return NextResponse.json(todoStore.create(payload.title), { status: 201 });
  } catch (error) {
    if (error instanceof TodoValidationError) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    throw error;
  }
}
