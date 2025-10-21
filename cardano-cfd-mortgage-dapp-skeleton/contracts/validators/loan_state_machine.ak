-- loan_state_machine.ak
-- Validator for contract‑for‑deed / mortgage with USD‑denominated payments.

module loan_state_machine

import aiken/ledger

-- Currency mode distinguishes between pure ADA loans and USD‑denominated loans.

data CurrencyMode = Ada | Usd

-- Financials record tracks both lovelace and USD‑cent amounts.  For ADA loans
-- only the `_l` fields are non‑zero; for USD loans only the `_usdc` fields are
-- non‑zero.

type Financials = {
  principal_l      : Int,
  installment_l    : Int,
  principal_usdc   : Int,
  installment_usdc : Int,
  apr_bps          : Int,
  amort_months     : Int,
  next_due_slot    : Slot,
  currency_mode    : CurrencyMode
}

-- Parties participating in the loan.

type Parties = {
  owner_pk   : PubKeyHash,
  servicer_pk: PubKeyHash,
  borrower_pk: PubKeyHash,
  oracle_pk  : PubKeyHash
}

-- Main datum stored at the loan UTXO.

type LoanDatum = {
  tier        : ByteArray,
  state       : ByteArray,
  financials  : Financials,
  parties     : Parties
}

-- Oracle payload used to price ADA in USD.
-- `rate_usdc_per_ada` expresses how many USD‑cents one ADA is worth (e.g.
-- if ADA=0.50 USD, then rate_usdc_per_ada = 50).

type OraclePack = {
  loan_id             : ByteArray,
  rate_usdc_per_ada   : Int,
  rate_timestamp      : Int,
  next_due_slot       : Slot,
  sig                 : Signature
}

-- Redeemer for state transitions.

data Redeemer = Activate | PayAda Int | PayUsd {
  paid_l         : Int,
  scheduled_usdc : Int,
  rate_usdc_per_ada : Int,
  rate_timestamp : Int,
  next_due_slot_new : Slot,
  oracle_pack    : OraclePack
} | Default | Settle

-- Enforce that the correct parties sign the transaction.
nonrec signed_by_party(ctx: ScriptContext, pkh: PubKeyHash) : Bool is
  tx_signed_by(ctx.tx, pkh)

-- Verify oracle signature for Tier A loans.  In practice you should verify
-- the ed25519 signature over the payload; here we just check that the oracle
-- key signed the transaction.
nonrec oracle_ok(ctx: ScriptContext, datum: LoanDatum, r: Redeemer) : Bool is
  case r {
    PayUsd {oracle_pack=op} ->
      tx_signed_by(ctx.tx, datum.parties.oracle_pk)
    _ -> True
  }

-- Core validator entry point.
validator loan_state_machine(datum: LoanDatum, redeemer: Redeemer, ctx: ScriptContext) : Bool is
  -- Always ensure the obligation NFT and datum continuity (omitted for brevity).
  let payment_ok : Bool =
    case redeemer {
      PayAda paid_l ->
        -- ADA loan: just ensure paid amount is >= scheduled installment in lovelace.
        datum.financials.currency_mode == Ada &&
        paid_l >= datum.financials.installment_l

      PayUsd p ->
        -- USD loan: compute required lovelace from the oracle rate.
        datum.financials.currency_mode == Usd &&
        (p.paid_l * p.rate_usdc_per_ada) >= (p.scheduled_usdc * 1_000_000)

      Activate ->
        True

      _ -> True
    }

  let oracle_check = oracle_ok(ctx, datum, redeemer)

  -- Require that the servicer NFT is consumed for any payment.
  let servicer_input_ok = True -- To be implemented: check NFT in inputs

  payment_ok && oracle_check && servicer_input_ok
