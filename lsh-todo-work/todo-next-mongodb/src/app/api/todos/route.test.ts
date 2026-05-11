/**
 * @jest-environment node
 */
import { createTodo, listTodos } from "@/lib/todos";
import { GET, POST } from "./route";

jest.mock("@/lib/todos", () => ({
  createTodo: jest.fn(),
  listTodos: jest.fn(),
}));

const mockedCreateTodo = jest.mocked(createTodo);
const mockedListTodos = jest.mocked(listTodos);

describe("/api/todos", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("returns todos", async () => {
    mockedListTodos.mockResolvedValue([
      {
        id: "507f1f77bcf86cd799439011",
        title: "Write tests",
        createdAt: "2026-05-08T12:00:00.000Z",
      },
    ]);

    const response = await GET();
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.todos).toHaveLength(1);
    expect(body.todos[0].title).toBe("Write tests");
  });

  it("creates a todo", async () => {
    mockedCreateTodo.mockResolvedValue({
      id: "507f1f77bcf86cd799439012",
      title: "Ship app",
      createdAt: "2026-05-08T12:05:00.000Z",
    });

    const request = new Request("http://localhost/api/todos", {
      method: "POST",
      body: JSON.stringify({ title: "  Ship app  " }),
    });
    const response = await POST(request);
    const body = await response.json();

    expect(response.status).toBe(201);
    expect(mockedCreateTodo).toHaveBeenCalledWith("Ship app");
    expect(body.todo.title).toBe("Ship app");
  });

  it("rejects an empty title", async () => {
    const request = new Request("http://localhost/api/todos", {
      method: "POST",
      body: JSON.stringify({ title: " " }),
    });
    const response = await POST(request);
    const body = await response.json();

    expect(response.status).toBe(400);
    expect(body.error).toBe("Todo title is required");
    expect(mockedCreateTodo).not.toHaveBeenCalled();
  });
});
