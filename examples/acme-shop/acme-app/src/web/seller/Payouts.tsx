import { useMyPayouts } from "../hooks";

const label = { pending: "Pending", processing: "Processing", paid: "Paid", failed: "Failed" } as const;

export function Payouts() {
  const payouts = useMyPayouts();
  const next = payouts.find((p) => p.status === "pending");

  return (
    <section>
      <h1>Payouts</h1>
      {next && <p>Next payout: ${(next.amountCents / 100).toFixed(2)} on {next.scheduledFor.toLocaleDateString()}</p>}
      <ul>
        {payouts.map((p) => (
          <li key={p.id}>${(p.amountCents / 100).toFixed(2)} · {label[p.status]}</li>
        ))}
      </ul>
    </section>
  );
}
