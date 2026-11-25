export type StaffRole = "admin" | "support";

type Action =
  | "seller.view"
  | "seller.suspend"
  | "payout.view"
  | "payout.retry";

const permissions: Record<StaffRole, Action[]> = {
  admin: ["seller.view", "seller.suspend", "payout.view", "payout.retry"],
  support: ["seller.view", "payout.view", "payout.retry"],
};

export function can(role: StaffRole, action: Action): boolean {
  return permissions[role].includes(action);
}
