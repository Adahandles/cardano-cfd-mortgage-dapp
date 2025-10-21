#!/bin/bash
set -e

for branch in $(git for-each-ref --format '%(refname:short)' refs/heads/); do
  echo "Switching to $branch..."
  git checkout "$branch"
  cat > .LICENSE_COMMERCIAL.txt <<'EOF'
Proprietary License – DeuOS / Cardano-CFD-Mortgage dApp
Copyright (c) 2025 DeuOS, LLC. All rights reserved.

This software and associated documentation files are proprietary and confidential.
No part of this software may be reproduced, distributed, modified, or reverse-engineered
without express written permission from DeuOS, LLC.

Use of this software is granted only under a valid written agreement.
Unauthorized use, distribution, or modification may result in legal action.
EOF

  echo "This repository is protected under the DeuOS Proprietary License. See .LICENSE_COMMERCIAL.txt for the full terms." > LICENSE
  git add LICENSE .LICENSE_COMMERCIAL.txt
  git commit -m "Apply DeuOS proprietary license"
  git push origin "$branch"
done
