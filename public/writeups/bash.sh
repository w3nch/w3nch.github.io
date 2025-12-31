#!/usr/bin/env bash

set -e

BASE="content/writeups"

mkdir -p \
  $BASE/htb \
  $BASE/thm \
  $BASE/picoctf \
  $BASE/letsdefend \
  $BASE/btlo \
  $BASE/cyberdefenders \
  $BASE/echoctf

cat > $BASE/htb/_index.md <<'EOF'
---
title: "Hack The Box"
description: "Hack The Box machine and challenge writeups"
---

Writeups for **Hack The Box** machines and challenges.

Focus areas:

- Enumeration methodology
- Web exploitation
- Privilege escalation
- Post-exploitation analysis

Each writeup emphasizes **process, mistakes, and takeaways** rather than just the final flag.
EOF

cat > $BASE/thm/_index.md <<'EOF'
---
title: "TryHackMe"
description: "TryHackMe room writeups and notes"
---

This section contains **TryHackMe** room writeups and notes.

Content here is focused on:

- Learning-oriented walkthroughs
- Fundamental security concepts
- Tool usage and methodology
- Reinforcing basics through repetition
EOF

cat > $BASE/picoctf/_index.md <<'EOF'
---
title: "PicoCTF"
description: "PicoCTF challenge writeups"
---

Writeups for **PicoCTF** challenges.

Typically short and focused, covering:

- Cryptography
- Reverse engineering
- Web exploitation
- Forensics and scripting challenges

Solutions prioritize clarity and reproducibility.
EOF

cat > $BASE/letsdefend/_index.md <<'EOF'
---
title: "LetsDefend"
description: "Blue-team and SOC-focused writeups"
---

This section contains **LetsDefend** writeups and notes.

Focus areas include:

- SOC analyst workflows
- Alert analysis
- Incident response
- Log and SIEM investigation

Writeups are approached from a **defensive and analytical perspective**.
EOF

cat > $BASE/btlo/_index.md <<'EOF'
---
title: "Blue Team Labs Online (BTLO)"
description: "Blue Team Labs Online writeups"
---

Writeups for **Blue Team Labs Online (BTLO)** challenges.

Focus areas:

- Log analysis
- Endpoint forensics
- Detection engineering
- Threat hunting techniques

Emphasis is on **blue-team thinking and investigation flow**.
EOF

cat > $BASE/cyberdefenders/_index.md <<'EOF'
---
title: "CyberDefenders"
description: "CyberDefenders lab writeups"
---

This section contains writeups for **CyberDefenders** labs.

Topics commonly include:

- Digital forensics
- Network traffic analysis
- Malware analysis
- Incident response scenarios

Each writeup documents tools used, decisions made, and lessons learned.
EOF

cat > $BASE/echoctf/_index.md <<'EOF'
---
title: "EchoCTF"
description: "EchoCTF lab writeups"
---

Writeups for **EchoCTF** labs and challenges.

Focus areas:

- Red-team style labs
- Network exploitation
- Active Directory attacks
- Post-exploitation techniques

Writeups emphasize practical attack paths and realistic lab environments.
EOF

echo "[+] Writeups sections created successfully."
