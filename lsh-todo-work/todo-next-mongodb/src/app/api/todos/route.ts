import { NextResponse } from "next/server";
import { createTodo, listTodos } from "@/lib/todos";

export async function GET() {
  try {
    const todos = await listTodos();
    return NextResponse.json({ todos });
  } catch {
    return NextResponse.json(
      { error: "Failed to fetch todos" },
      { status: 500 },
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as { title?: unknown };
    const title = typeof body.title === "string" ? body.title.trim() : "";

    if (!title) {
      return NextResponse.json(
        { error: "Todo title is required" },
        { status: 400 },
      );
    }

    const todo = await createTodo(title);
    return NextResponse.json({ todo }, { status: 201 });
  } catch {
    return NextResponse.json(
      { error: "Failed to create todo" },
      { status: 500 },
    );
  }
}
