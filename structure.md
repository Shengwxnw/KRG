# Card Game Demo - Node Structure

## game.tscn (Main Scene)

```
game (Node)
├── phase_banner (CanvasLayer - phase_banner.tscn)
├── overlay (Panel)
├── UI (CanvasLayer)
│   ├── Neutral (Node)
│   │   ├── coin_holder (Panel - coin_holder.tscn)
│   │   ├── time_display (Control - time_display.tscn)
│   │   ├── Buttons (Node)
│   │   │   ├── top_left_button (Panel)
│   │   │   │   └── TEST (Button)
│   │   │   ├── settings_button (Panel)
│   │   │   ├── end_turn_button (Panel)
│   │   │   └── log_button (Panel)
│   │   └── battle_log (Control - battle_log.tscn)
│   ├── PlayerP1 (Node - player.tscn, side=false)
│   ├── PlayerP2 (Node - player.tscn, side=true)
│   ├── hp_bar_p1 (Control - hp_bar.tscn)
│   └── hp_bar_p2 (Control - hp_bar.tscn)
├── turn_manager (Node - turn_manager.gd)
└── card_effect_system (Node - card_effect_system.gd)
```

## hp_bar.tscn

```
hp_bar (Control)
├── bg (Panel) - dark background
├── hurt (Panel) - red damage indicator
├── hp (Panel) - green health fill
├── hp_label (Label) - "10/10"
├── shield_label (Label) - "🛡X"
└── damage_container (Node2D) - floating damage numbers
```

## player.tscn

```
Player (Node)
├── Chara1 (Node - chara.tscn)
├── Chara2 (Node - chara.tscn)
├── Armor (Node)
│   ├── square (Control - field.tscn)
│   └── square2 (Control - field.tscn)
├── Field (Node)
│   ├── square (Control - field.tscn)
│   └── square3 (Control - field.tscn)
└── Deck (Node)
	├── Control (Card)
	├── Control2 (Card)
	├── Control3 (Card)
	└── Control4 (Card)
```

## Scene Hierarchy Summary

| Level | Nodes |
|-------|-------|
| 0 | game |
| 1 | phase_banner, overlay, UI, turn_manager, card_effect_system |
| 2 | UI/Neutral, UI/PlayerP1, UI/PlayerP2, UI/hp_bar_p1, UI/hp_bar_p2 |
| 3 | Neutral/coin_holder, Neutral/time_display, Neutral/Buttons, Neutral/battle_log |
| 4 | Buttons/top_left_button, Buttons/settings_button, Buttons/end_turn_button, Buttons/log_button |

## Script Components

| Script | File | Purpose |
|--------|------|---------|
| game.gd | Scripts/game.gd | Main controller, connects signals, handles input |
| turn_manager.gd | Scripts/turn_manager.gd | Turn phases, action tracking |
| card_effect_system.gd | Scripts/card_effect_system.gd | Card effect execution |
| overlay.gd | Scripts/overlay.gd | Screen fade effects |
| hp_bar.gd | Scripts/hp_bar.gd | HP display with animations |
| player.gd | Scripts/player.gd | Player layout (flips content for P2) |

## Autoloads (Singletons)

- **GameManager** - Global game state (HP, coins, shield)
- **CoinFlyManager** - Animated coin flying effect
