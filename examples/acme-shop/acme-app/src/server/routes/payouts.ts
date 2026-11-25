import { Router } from "express";
import { db } from "../db/client";
import { can } from "../auth/roles";

export const payouts = Router();

// Admin console: a Seller's payouts
payouts.get("/sellers/:sellerId/payouts", async (req, res) => {
  if (!can(req.staff.role, "payout.view")) return res.sendStatus(403);
  res.json(await db.payouts.find({ sellerId: req.params.sellerId }));
});

// Retry a failed payout: puts it back in the next run
payouts.post("/payouts/:id/retry", async (req, res) => {
  if (!can(req.staff.role, "payout.retry")) return res.sendStatus(403);
  const p = await db.payouts.get(req.params.id);
  if (p.status !== "failed") return res.status(409).json({ error: "Only failed payouts can be retried" });
  await db.payouts.update(p.id, { status: "pending", failureReason: undefined });
  res.sendStatus(204);
});
