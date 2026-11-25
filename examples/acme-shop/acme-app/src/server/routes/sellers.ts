import { Router } from "express";
import { db } from "../db/client";
import { can } from "../auth/roles";
import { record } from "../services/auditLog";
import { notifySeller } from "../services/notify";

export const sellers = Router();

sellers.get("/:id", async (req, res) => {
  if (!can(req.staff.role, "seller.view")) return res.sendStatus(403);
  res.json(await db.sellers.get(req.params.id));
});

sellers.post("/:id/suspend", async (req, res) => {
  if (!can(req.staff.role, "seller.suspend")) return res.sendStatus(403);
  await db.sellers.update(req.params.id, { status: "suspended" });
  await record({ actorId: req.staff.id, action: "seller.suspend", targetType: "seller", targetId: req.params.id });
  await notifySeller(req.params.id, "seller.suspended");
  res.sendStatus(204);
});
