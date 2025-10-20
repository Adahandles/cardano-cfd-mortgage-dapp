-- obligation_token.ak
-- Minting policy stub for the obligation reference NFT
-- This CIP‑68 asset serves as the unique identifier for each loan.

policy obligation_token : Script
  redeemer: Unit
  context: ScriptContext
is
  -- Always succeed for now; real logic should restrict minting
  True
