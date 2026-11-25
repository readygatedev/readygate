import { db } from "../db/client";
import { bank } from "../services/bank";
import { notifySeller } from "../services/notify";

// Scheduled weekly: Monday 06:00 UTC
export async function runPayouts(now = new Date()) {
  const due = await db.payouts.find({ status: "pending", scheduledFor: { lte: now } });

  for (const payout of due) {
    await db.payouts.update(payout.id, { status: "processing" });
    try {
      await bank.transfer(payout.sellerId, payout.amountCents, payout.currency);
      await db.payouts.update(payout.id, { status: "paid", paidAt: new Date() });
      await notifySeller(payout.sellerId, "payout.paid", { amountCents: payout.amountCents });
    } catch (err) {
      await db.payouts.update(payout.id, { status: "failed", failureReason: String(err) });
      await notifySeller(payout.sellerId, "payout.failed");
    }
  }
}
