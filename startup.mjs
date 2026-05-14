import { readFileSync } from "fs";
import pg from "pg";

const { Client } = pg;

const url = process.env.DATABASE_URL;
if (!url) {
  console.error("[MIGRATE] DATABASE_URL not set");
  process.exit(1);
}

const client = new Client({ connectionString: url });

try {
  await client.connect();
  const sql = readFileSync("/app/migrations/0000_tiresome_mathemanic.sql", "utf8");
  // drizzle-kit generates --> statement-breakpoint as statement separator
  const statements = sql.split("--> statement-breakpoint").map(s => s.trim()).filter(Boolean);
  for (const stmt of statements) {
    try {
      await client.query(stmt);
    } catch (err) {
      if (err.code === "42P07" || err.code === "42710") {
        // already exists — skip
      } else {
        console.warn("[MIGRATE] stmt warning:", err.message);
      }
    }
  }
  console.log("[MIGRATE] Schema applied.");
} catch (err) {
  console.error("[MIGRATE] Fatal error:", err.message);
  process.exit(1);
} finally {
  await client.end();
}
