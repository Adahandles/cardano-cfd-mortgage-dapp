-- Cardano CFD/Mortgage loan state machine validator
-- Defines loan states, datum, actions, and transition rules.

data LoanState = Draft | Active | Delinquent | Default | Takeback | Settled

type Datum = {
  state: LoanState,
  ownerPkh: PubKeyHash,
  borrowerPkh: PubKeyHash,
  servicerPkh: PubKeyHash,
  tier: String
}

data Action =
    Activate
  | MakePayment
  | MarkDelinquent
  | Cure
  | TakebackAction
  | Settle
  | Assign PubKeyHash
  | UpgradeTier String
  let
    info : TxInfo = ctx.tx_info
    ownerSigned : Bool = tx_signed_by info datum.ownerPkh
    borrowerSigned : Bool = tx_signed_by info datum.borrowerPkh
    servicerSigned : Bool = tx_signed_by info datum.servicerPkh
  in
    match (datum.state, redeemer) with
      (Draft, Activate) ->
        ownerSigned && borrowerSigned
      (Active, MakePayment) ->
        -- Borrower and servicer sign when a payment is posted
        borrowerSigned && servicerSigned
      (Active, MarkDelinquent) ->
        -- Servicer marks a loan delinquent
        servicerSigned
      (Delinquent, Cure) ->
        -- Borrower cures delinquency with servicer
        borrowerSigned && servicerSigned
      (Default, TakebackAction) ->
        -- Servicer enforces takeback/default
        servicerSigned
      (Active, Settle) ->
        -- All parties sign payoff and settlement
        ownerSigned && borrowerSigned && servicerSigned
      (state, Assign newOwner) ->
        -- Assignment requires owner and servicer signatures
        ownerSigned && servicerSigned
      (state, UpgradeTier newTier) ->
        -- Upgrading tier requires owner and servicer signatures
        ownerSigned && servicerSigned
      _ ->
        -- Reject any other state/action combinations
        False
