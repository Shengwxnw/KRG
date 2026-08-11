# AGENTS.md

A turn-based two-player card battle demo in **Godot 4.6**. No build system — open and run in the Godot editor (F5). No tests, linter, or CI. Resolution fixed at 1920×1200, window not resizable. All UI text is Simplified Chinese.

## Run Commands

- **Editor:** Open project in Godot 4.6, press F5
- **CLI:** `godot --path <project-dir> res://Scenes/game.tscn`

## Architecture

### Autoloads (Global Singletons)

| Autoload | Script | Role |
|---|---|---|
| `GameManager` | `Scripts/game_manager.gd` | Mutable state: `hp`, `shield`, `coins` per player. Emits `coin_changed`, `damage_dealt`, `shield_changed`. |
| `CoinFlyManager` | `Scripts/coin_fly_manager.gd` | Visual-only: animates coin fly from center to coin bar. |
| `SignalBus` | `Scripts/signal_bus.gd` | Global signals: `card_clicked`, `close_side_bar`. Var `is_side_bar_open`. |
| `InputManager` | `Scripts/input_manager.gd` | `_input()` for keyboard controls, `_unhandled_input()` for sidebar/hand-area mouse clicks. Delegates to TurnManager by group lookup. |

`TurnManager` is **NOT an autoload** — it is a child node of the `game` scene, referenced as `$turn_manager`. It registers itself in the `"turn_manager"` group so autoloads can find it via `get_tree().get_first_node_in_group("turn_manager")`.

### TurnManager Coroutine Loop

`Scripts/turn_manager.gd` drives the game via a `while true` coroutine using `await` on its own signals:

```
_phase_round_start → _phase_deal_coins (×2 per player) → _phase_deal_cards
  → _phase_pre_settle → _phase_actions (×2 per player, looping)
  → _phase_post_settle → _phase_round_end → _phase_check_game_over
  → _phase_swap_first_player → repeat
```

Constants: `COINS_PER_TURN = 9`, `CARDS_PER_TURN = 3`, `ACTIONS_PER_TURN = 2`.

### Signal Handshake Pattern (Critical)

`game.gd` (`Scripts/game.gd`) connects to TurnManager's phase signals, runs UI animations, then **re-emits `ready_to_*` signals** back to TurnManager to advance:

| TurnManager emits | game.gd does | Then emits back |
|---|---|---|
| `turn_started` | Phase banner animation | `turn_manager.ready_to_start` |
| `coins_granted` | CoinFly animation | `turn_manager.ready_to_deal_coins` |
| `cards_drawn` | Phase banner | `turn_manager.ready_to_deal_cards` |
| `pre_settle_started` | Phase banner | `turn_manager.ready_to_start` (reused) |
| `action_started` | Phase banner | *(none — TurnManager awaits `action_confirmed` from `notify_action_done`)* |
| `post_settle_started` | Phase banner | `turn_manager.ready_to_end` |
| `turn_ended` | Phase banner | `turn_manager.ready_to_end` |

Every new phase you add to TurnManager must follow this pattern — `await ready_to_X` in TurnManager, emit `ready_to_X` from game.gd after UI work.

### Input Actions (`input_manager.gd`)

Keyboard keys handled in `_input()`:

| Key | Action | Effect |
|---|---|---|
| Enter | `ui_accept` | `tm.notify_action_done(current_acting_player)` |
| Esc | `ui_cancel` | `tm.notify_end_turn(current_acting_player)` |
| D | `deal_damage` (custom) | Debug: deals 1-10 random damage to opponent, then `notify_action_done` |

Mouse clicks handled in `_unhandled_input()` (fires only when no Control consumes the event first):

- Click left 3/4 of screen when sidebar is open → `SignalBus.close_side_bar`
- Click upper half when hand area is open (sidebar closed) → `HandArea.close()`

`HandArea` registers itself with `InputManager` via `register_open_hand()` / `unregister_open_hand()` so `_unhandled_input` knows which hand area to close.

### Card & Sidebar Flow

`Card` (`Scripts/card.gd`) emits `SignalBus.card_clicked(self)` on click → `SideBar` (`Scripts/side_bar.gd`) opens the detail panel. Clicking outside the sidebar or in the upper half of the hand area closes it via `SignalBus.close_side_bar`.

Card data: `CardData` (`Data/Cards/CardData.gd`, extends `Resource`) with enum `CardType { ATTACK, DEFENSE, BUFF, SUMMON }`. Test deck via `CardData.make_test_deck()`.

### P2 Layout Flip

`Scenes/player.tscn` (script: `player.gd`) has a `side` int. When `side == 2` (P2), `setup_layout()` inverts Y-coordinates. Do not hard-code P2 positions elsewhere.

## Key Patterns

- **Signal-driven:** Components communicate via signals; never cross system boundaries with direct calls
- **Tween for all animation:** Use `create_tween()` — avoid `_process` polling
- **GDScript typing:** Parameters typed; return types on public methods; dictionaries inferred
- **Resources over scenes:** Cards are `.tres` files in `Data/Cards/`

## Known Gaps

- No actual card-play execution pipeline — `HandArea.card_played` signal exists but is never connected; there is no `CardEffectSystem` or `HandManager` script yet
- Summoned unit combat is not implemented
- `BattleLog` scene exists but is never populated
- Field/Armor squares are visual placeholders
- `HandManager` (the scene child, not a script) — `setup()` is never called; deck init path is incomplete
- No save/load, no networking
