import { useSeller, usePayouts, useStaff } from "../hooks";

export function SellerDetail({ sellerId }: { sellerId: string }) {
  const seller = useSeller(sellerId);
  const payouts = usePayouts(sellerId);
  const staff = useStaff();

  return (
    <div>
      <h1>{seller.name}</h1>
      <span className="badge">{seller.status === "active" ? "Active" : "Suspended"}</span>
      {staff.role === "admin" && seller.status === "active" && (
        <button onClick={() => seller.suspend()}>Suspend seller</button>
      )}

      <h2>Payouts</h2>
      <table>
        <thead><tr><th>Amount</th><th>Status</th><th>Scheduled</th><th /></tr></thead>
        <tbody>
          {payouts.map((p) => (
            <tr key={p.id}>
              <td>${(p.amountCents / 100).toFixed(2)}</td>
              <td>{p.status}</td>
              <td>{p.scheduledFor.toLocaleDateString()}</td>
              <td>{p.status === "failed" && <button onClick={() => p.retry()}>Retry</button>}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
