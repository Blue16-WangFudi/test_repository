export type Todo = {
  id: string;
  title: string;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
};

export type TodoAction = "create" | "update" | "delete";

export type CreateTodoInput = {
  title: string;
};

export type UpdateTodoInput = {
  completed: boolean;
};
