import { deleteTodo, updateTodo } from "@/lib/todos/service";
import { parseUpdateTodoInput } from "@/lib/todos/validation";

export const runtime = "nodejs";

export async function PATCH(
  request: Request,
  context: RouteContext<"/api/todos/[id]">,
) {
  try {
    const { id } = await context.params;
    const input = parseUpdateTodoInput(await request.json());
    const todo = await updateTodo(id, input);

    if (!todo) {
      return Response.json({ error: "Todo not found." }, { status: 404 });
    }

    return Response.json({ todo });
  } catch (error) {
    return Response.json(
      { error: getErrorMessage(error) },
      { status: 400 },
    );
  }
}

export async function DELETE(
  _request: Request,
  context: RouteContext<"/api/todos/[id]">,
) {
  try {
    const { id } = await context.params;
    const deleted = await deleteTodo(id);

    if (!deleted) {
      return Response.json({ error: "Todo not found." }, { status: 404 });
    }

    return Response.json({ ok: true });
  } catch (error) {
    return Response.json(
      { error: getErrorMessage(error) },
      { status: 500 },
    );
  }
}

function getErrorMessage(error: unknown) {
  return error instanceof Error ? error.message : "Unexpected server error.";
}
