# Card Game Rulebook *(名称未定)*

---

## 1. Game Flow

A **game** consists of multiple **rounds**. Each round plays out in five phases in order.

### Setup (before the game begins)
- Flip a coin to determine who is **Player 1 (1P)** and **Player 2 (2P)**.
- All players draw **5 cards** as their starting hand.

### Each Round

| Phase | Name | What Happens |
|-------|------|--------------|
| 1 | **Pre-Battle Resolution** (先行结算) | Certain skills/effects trigger. 1P resolves first. |
| 2 | **Coin Grant** | All players receive **9 coins**. 1P receives first. |
| 3 | **Card Draw** | All players draw **3 cards**. 1P draws first. |
| 4 | **Action Phase** | Players take actions by playing cards (see below). |
| 5 | **Post-Battle Resolution** (后行结算) | Certain skills/effects trigger. 1P resolves first. |

### End of Round
- The player who **manually ends their turn first** becomes **1P next round**.

---

## 2. Action Phase

Playing a card counts as **one action**. Dodging (playing a Miss card) does **not** count as an action.

A player's turn in the action phase ends when either:
- They **manually end their turn** (voluntary), or
- They **cannot act** — no coins left, or no playable cards (automatic).

### Action Cost Escalation
Starting from a player's **3rd action** in a round, card costs increase:
- 3rd action: +1 coin
- 4th action: +2 coins
- 5th action: +3 coins, and so on.

### Other Actions
- **Switch character:** Spend **1 coin** to swap the active character. Counts as one action.
- **Convert a card:** Discard any card from hand to gain **1 coin**. (Does not count as an action.)

---

## 3. Characters

Each player brings **2 characters** into a match.

### Character Tags
Characters belong to one of four tags for classification: `Standard` / `DX` / `FES` / `White`

### Bond (羁绊)
Some characters share a **bond attribute**. Fielding two characters who share the same bond grants a bonus effect.

### Skills
Each character has **2 skills**, which can be **passive** or **active**.

### Active Character (出战角色)
- At the start of the action phase, choose one of your characters as the **active character**.
- At the end of the action phase, the active character returns to the back.
- Rules for the active character:
  1. Cards played are considered played **by the active character**.
  2. Damage received reduces the **active character's HP**.
  3. Only the **active character's skills** are in effect.

---

## 4. Cards & Hand

- The **cost** of a card is shown in its **top-left corner**. Playing it deducts that many coins.
- The **hand limit** is **9 cards**. You cannot draw or gain cards while at the limit.

### Card Types
| Type | Description |
|------|-------------|
| **Note** | Attack cards with an attribute (Tap/Hold/Slide/Touch/Break). Used to **assign** the opponent. |
| **Miss** | Dodge cards with an attribute. Used to **evade** an incoming Note of the same attribute. Playing a Miss does not count as an action. |
| **Equipment / Field cards** | Special persistent cards. Their use count resets in Phase 1 each round. |

---

## 5. States & Attributes

### States
Both of a player's characters share a single **state**, cycling randomly each round.

The five states are: `Tap` | `Hold` | `Slide` | `Touch` | `Break`

- The **state bar** sits between your two characters. You can see your **current state** and the **next two rounds'** states.
- You can only see the opponent's **current state** and their **next round's** state.

### Assigning (指定)
When a player plays a **Note card**:
- If the **Note's attribute matches the opponent's current state**, the opponent is **assigned** (指定).
- When assigned, the opponent can only **dodge with a Miss card of the same attribute**.

### Outcomes
| Outcome | Condition |
|---------|-----------|
| **Assign Success** (指定成功) | Opponent did not play a matching Miss. The Note deals damage. |
| **Assign Fail — Evaded** (指定失败) | Opponent played a matching Miss card. No damage. |
| **Assign Fail — Wrong attribute** (指定失败) | The Note's attribute did not match the opponent's state. |

---

## 6. Combo (连击)

- Each **successful assign** grants the attacker **+1 Combo stack**.
- Each Combo stack adds **+4 damage** to successful assigns (max **+16**, i.e., 4 stacks).
- A **failed assign** resets the active character's Combo stacks to **0**.
- Each character tracks Combo **independently**. When a character goes to the back, their stacks are **preserved but inactive** — they do not transfer to the front character and do not disappear.

---

## 7. Special Damage

| Type | Description |
|------|-------------|
| **True Damage** (真实伤害) | Ignores all defensive effects. Has no attribute. |

---

## 8. Break Note

When a **Break Note** is played:
- There is a **50% chance** it is judged as a **Great P** (大P).
- On a Great P: **+2 damage**.

---

## 9. Win Conditions

| Condition | Result |
|-----------|--------|
| Both of one player's characters are defeated | The **other player wins**. |
| One player forfeits | The **other player wins**. |
| Both players run out of cards and neither has won | **Draw**. |
