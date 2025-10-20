-- servicing_nft.ak
-- Minting policy stub for the servicing NFT
-- This NFT is required for posting payments and status updates.

policy servicing_nft : Script
  redeemer: Unit
  context: ScriptContext
is
  True
