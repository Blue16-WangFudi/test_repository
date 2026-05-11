import mysql from "mysql2/promise";
import type { TodoAction } from "@/lib/todos/types";

type PoolCache = {
  pool: mysql.Pool | null;
  initialized: Promise<void> | null;
};

declare global {
  var mysqlPoolCache: PoolCache | undefined;
}

const cached = globalThis.mysqlPoolCache ?? { pool: null, initialized: null };

if (!globalThis.mysqlPoolCache) {
  globalThis.mysqlPoolCache = cached;
}

function getPool() {
  if (cached.pool) {
    return cached.pool;
  }

  const uri = process.env.MYSQL_URL;
  if (!uri) {
    throw new Error("MYSQL_URL is not configured.");
  }

  cached.pool = mysql.createPool(uri);
  return cached.pool;
}

async function ensureOperationLogTable() {
  const pool = getPool();

  cached.initialized ??= pool.query(`
    CREATE TABLE IF NOT EXISTS todo_operation_logs (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
      todo_id VARCHAR(64) NOT NULL,
      action VARCHAR(24) NOT NULL,
      payload JSON NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `).then(() => undefined);

  return cached.initialized;
}

export async function recordTodoOperation(
  todoId: string,
  action: TodoAction,
  payload: Record<string, unknown>,
) {
  await ensureOperationLogTable();
  await getPool().execute(
    "INSERT INTO todo_operation_logs (todo_id, action, payload) VALUES (?, ?, CAST(? AS JSON))",
    [todoId, action, JSON.stringify(payload)],
  );
}
