# Next.js Todo List

Todo List built with Next.js App Router, TypeScript, MongoDB todo storage, MySQL operation logs, API Route Handlers, and Vitest tests.

## Features

- Add todos
- Delete todos
- Toggle completed status
- Persist todos in MongoDB
- Record create, update, and delete operations in MySQL

## Project Structure

```text
app/
  api/todos/route.ts        # GET and POST todos
  api/todos/[id]/route.ts   # PATCH and DELETE a todo
  components/TodoApp.tsx    # Client UI
  page.tsx                  # App Router page
lib/
  db/                       # MongoDB and MySQL connections
  models/                   # Mongoose models
  todos/                    # Todo types, validation, service logic
tests/                      # Vitest unit tests
```

## Environment Variables

Create `.env.local`:

```bash
MONGODB_URI="mongodb://127.0.0.1:27017/nextjs_todo"
MYSQL_URL="mysql://user:password@127.0.0.1:3306/nextjs_todo_logs"
```

The MySQL database must exist before running the app. The app creates the `todo_operation_logs` table automatically.

## Run

```bash
npm run dev
```

Open `http://localhost:3000`.

## Test

```bash
npm run test
```

## Build

```bash
npm run build
```

## Other Commands

```bash
npm run lint
npm run start
```
