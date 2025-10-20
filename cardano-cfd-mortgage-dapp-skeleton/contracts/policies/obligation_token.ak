-- obligation_token.ak
-- Minting policy for the obligation reference NFT.
-- Only allows minting or burning when the transaction is signed by the originator.

policy obligation_token (originatorPkh: PubKeyHash) : Script
  redeemer : Unit
  context  : ScriptContext
is
  tx_signed_by(context.tx, originatorPkh)
