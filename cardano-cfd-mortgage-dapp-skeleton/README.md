# Cardano CFD/Mortgage dApp

This repository contains the initial scaffolding for a Cardano dApp that tokenizes contracts for deed and mortgages. It includes:

- **contracts/** – Aiken smart contracts for obligation reference NFTs and a loan state machine. These are stubs you should extend.
- **shared/** – JSON schemas for loan datums and evidence packs. Keep your on‑chain data structures in sync with these schemas.
- **oracle/** – Express server stub for attestation endpoints. Replace with your oracle implementation that signs attestations and maintains a priority registry.
- **indexer/** – Stub for an Ogmios/Kupo based indexer and a Postgres schema. Extend this for off‑chain data services.
- **scripts/** – Helper shell scripts for building contracts and deploying to testnet.

> **Note**: The implementation is intentionally minimal; use this as a starting point for your full implementation as described in the design documents.
