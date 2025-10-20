import express from 'express';

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Example attestation endpoint
app.post('/attest', (req, res) => {
  // TODO: verify attestation payload and sign
  res.json({ payloadHash: '', signature: '', tierImpact: null });
});

app.listen(port, () => {
  console.log(`Oracle service listening on port ${port}`);
});
