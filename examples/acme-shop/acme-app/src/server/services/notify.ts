import { db } from "../db/client";
import { mailer } from "./mailer";

type Template = "seller.suspended" | "payout.paid" | "payout.failed";

export async function notifySeller(sellerId: string, template: Template, data: Record<string, unknown> = {}) {
  const seller = await db.sellers.get(sellerId);
  await mailer.send({ to: seller.email, template, data });
}
