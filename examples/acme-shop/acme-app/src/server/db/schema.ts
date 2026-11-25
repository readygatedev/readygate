export type SellerStatus = "active" | "suspended";

export interface Seller {
  id: string;
  name: string;
  email: string;
  status: SellerStatus;
  createdAt: Date;
}

export type PayoutStatus = "pending" | "processing" | "paid" | "failed";

export interface Payout {
  id: string;
  sellerId: string;
  amountCents: number;
  currency: "USD";
  status: PayoutStatus;
  scheduledFor: Date;        // next Monday 06:00 UTC when created
  paidAt?: Date;
  failureReason?: string;
}

export interface AuditEntry {
  id: string;
  actorId: string;           // Staff user id
  action: string;            // e.g. "seller.suspend"
  targetType: "seller" | "payout";
  targetId: string;
  at: Date;
}
