import express from 'express';
import bodyParser from 'body-parser';
import nacl from 'tweetnacl';

const ORACLE_SK = Buffer.from(process.env.ORACLE_SK!, 'hex');
const ORACLE_PK = Buffer.from(process.env.ORACLE_PK!, 'hex');

const app = express();
app.use(bodyParser.json());

// Return a price quote for a given loan.
app.get('/api/oracle/quote', (req, res) => {
  const { loanId } = req.query;
  // You should fetch the current ADA/USD price from a reliable source.
  const rate_usdc_per_ada = 50; // Example: 1 ADA = $0.50 => 50 USD-cents per ADA
  const rate_timestamp = Math.floor(Date.now() / 1000);
  const next_due_slot = rate_timestamp + 30 * 24 * 60 * 60; // placeholder: +30 days

  const payload = Buffer.concat([
    Buffer.from(loanId as string, 'utf-8'),
    Buffer.from(rate_usdc_per_ada.toString()),
    Buffer.from(rate_timestamp.toString()),
  ]);

  const sig = nacl.sign.detached(payload, ORACLE_SK);

  res.json({
    rate_usdc_per_ada,
    rate_timestamp,
    next_due_slot,
    sig: Buffer.from(sig).toString('hex'),
  });
});

app.listen(3001, () => {
  console.log('Oracle server running on port 3001');
});
