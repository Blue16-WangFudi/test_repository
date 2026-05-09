import { createTodo, listTodos } from "@/lib/todos/service";
import { parseCreateTodoInput } from "@/lib/todos/validation";

export const runtime = "nodejs";

export async function GET() {
  try {
    const todos = await listTodos();
    return Response.json({ todos });
  } catch (error) {
    return Response.json(
      { error: getErrorMessage(error) },
      { status: 500 },
    );
  }
}

export async function POST(request: Request) {
  try {
    const input = parseCreateTodoInput(await request.json());
    const todo = await createTodo(input);
    return Response.json({ todo }, { status: 201 });
  } catch (error) {
    const message = getErrorMessage(error);
    const status = message.includes("configured") ? 500 : 400;

    return Response.json({ error: message }, { status });
  }
}

function getErrorMessage(error: unknown) {
  return error instanceof Error ? error.message : "Unexpected server error.";
}
