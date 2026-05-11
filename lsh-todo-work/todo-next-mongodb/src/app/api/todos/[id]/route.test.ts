/**
 * @jest-environment node
 */
import { deleteTodo } from "@/lib/todos";
import { DELETE } from "./route";

jest.mock("@/lib/todos", () => ({
  deleteTodo: jest.fn(),
}));

const mockedDeleteTodo = jest.mocked(deleteTodo);

describe("/api/todos/[id]", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("deletes a todo", async () => {
    mockedDeleteTodo.mockResolvedValue(true);

    const response = await DELETE(new Request("http://localhost"), {
      params: Promise.resolve({ id: "507f1f77bcf86cd799439011" }),
    });
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.success).toBe(true);
    expect(mockedDeleteTodo).toHaveBeenCalledWith("507f1f77bcf86cd799439011");
  });

  it("returns 404 when todo does not exist", async () => {
    mockedDeleteTodo.mockResolvedValue(false);

    const response = await DELETE(new Request("http://localhost"), {
      params: Promise.resolve({ id: "507f1f77bcf86cd799439011" }),
    });
    const body = await response.json();

    expect(response.status).toBe(404);
    expect(body.error).toBe("Todo not found");
  });
});
