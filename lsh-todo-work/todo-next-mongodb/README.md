# Todo Next MongoDB

A full-stack Todo List app built with Next.js 16 App Router, API Routes, MongoDB, TypeScript, Tailwind CSS, and Jest.

## Features

- List todos from MongoDB
- Create todos through `POST /api/todos`
- Delete todos through `DELETE /api/todos/:id`
- Component tests with Testing Library
- API route tests with mocked data access

## Getting Started

Start MongoDB with Docker:

```bash
docker-compose up -d
```

Create `.env.local` from the example:

```bash
cp .env.local.example .env.local
```

Then run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Scripts

- `npm run db:up` starts MongoDB on `mongodb://127.0.0.1:27017`.
- `npm run db:down` stops MongoDB.
- `npm run dev` starts the local development server.
- `npm run build` creates a production build.
- `npm run start` runs the production server.
- `npm run lint` runs ESLint.
- `npm test` runs Jest tests.

## API

`GET /api/todos`

Returns:

```json
{ "todos": [] }
```

`POST /api/todos`

Request:

```json
{ "title": "Buy milk" }
```

`DELETE /api/todos/:id`

Deletes one todo by MongoDB ObjectId.
