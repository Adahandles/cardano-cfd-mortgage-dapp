import { Data, TxBuilder, Address, PaymentKeyHash } from "@lucid/cardano";
import { RedeemerUsd } from "./types";

interface OracleQuote {
  rate_usdc_per_ada: number;
  rate_timestamp: number;
  next_due_slot: number;
  sig: string;
}

async function fetchOracleQuote(loanId: string): Promise<OracleQuote> {
  const res = await fetch(`/api/oracle/quote?loanId=${loanId}`);
  return await res.json();
}

export async function payInstallmentUsd(
  loanUtxo: UTxO,
  servicingNftUtxo: UTxO,
  scheduledUsdC: bigint,
  borrowerSkh: PaymentKeyHash,
  oraclePkh: PaymentKeyHash
) {
  const quote = await fetchOracleQuote(loanUtxo.txHash);

  // Compute minimum lovelace required (floor division)
  const minLovelace = (scheduledUsdC * 1_000_000n) / BigInt(quote.rate_usdc_per_ada);

  const redeemer: RedeemerUsd = {
    kind: "PayUsd",
    paid_l: minLovelace,
    scheduled_usdc: scheduledUsdC,
    rate_usdc_per_ada: quote.rate_usdc_per_ada,
    rate_timestamp: quote.rate_timestamp,
    next_due_slot_new: quote.next_due_slot,
    oracle_pack: {
      loan_id: loanUtxo.txHash,
      rate_usdc_per_ada: quote.rate_usdc_per_ada,
      rate_timestamp: quote.rate_timestamp,
      next_due_slot: quote.next_due_slot,
      sig: quote.sig,
    },
  };

  // Build transaction that consumes the loan UTXO and servicing NFT UTXO, pays
  // minLovelace to the loan state machine address with updated datum, and
  // returns change to borrower.
  // ... (use Lucid’s TxBuilder to construct and sign)
}
