import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import TodoApp from "./TodoApp";

const fetchMock = jest.fn();

beforeEach(() => {
  fetchMock.mockReset();
  global.fetch = fetchMock;
});

describe("TodoApp", () => {
  it("loads and renders todos", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        todos: [
          {
            id: "1",
            title: "Read API docs",
            createdAt: "2026-05-08T12:00:00.000Z",
          },
        ],
      }),
    });

    render(<TodoApp />);

    expect(await screen.findByText("Read API docs")).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledWith("/api/todos");
  });

  it("adds a todo", async () => {
    const user = userEvent.setup();
    fetchMock
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({ todos: [] }),
      })
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          todo: {
            id: "2",
            title: "Create component test",
            createdAt: "2026-05-08T12:10:00.000Z",
          },
        }),
      });

    render(<TodoApp />);

    await screen.findByText("No todos yet.");
    await user.type(screen.getByLabelText("Todo title"), "Create component test");
    await user.click(screen.getByRole("button", { name: "Add" }));

    expect(await screen.findByText("Create component test")).toBeInTheDocument();
    expect(fetchMock).toHaveBeenLastCalledWith("/api/todos", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: "Create component test" }),
    });
  });

  it("deletes a todo", async () => {
    const user = userEvent.setup();
    fetchMock
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          todos: [
            {
              id: "3",
              title: "Remove me",
              createdAt: "2026-05-08T12:20:00.000Z",
            },
          ],
        }),
      })
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true }),
      });

    render(<TodoApp />);

    expect(await screen.findByText("Remove me")).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Delete Remove me" }));

    await waitFor(() => {
      expect(screen.queryByText("Remove me")).not.toBeInTheDocument();
    });
    expect(fetchMock).toHaveBeenLastCalledWith("/api/todos/3", {
      method: "DELETE",
    });
  });
});
