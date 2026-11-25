import { db } from "../db/client";
import type { AuditEntry } from "../db/schema";

export async function record(entry: Omit<AuditEntry, "id" | "at">) {
  await db.audit.insert({ ...entry, at: new Date() });
}
