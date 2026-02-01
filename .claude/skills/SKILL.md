---
name: samurai-game-patterns
description: Coding patterns and conventions for the Space Shooter (shmup) Godot 4 project
version: 1.0.0
source: local-git-analysis
analyzed_commits: 2
analyzed_files: 67
---

# Samurai Game - Development Patterns

## Project Identity

Godot 4.x vertical space shooter (shmup). Viewport 320x480. GDScript only. 67 scripts, 22 scenes. Procedural rendering preferred over sprites.

## Architecture Patterns

### File Organization

```
scripts/
├── game.gd              # Central controller (~940 lines, orchestrates everything)
├── background_scroller.gd
├── main.gd
├── enemies/             # Enemy types: enemy_base.gd (base class) + variants
│   ├── boss/            # Boss controllers and attack patterns
│   └── wave_spawner.gd  # Wave management + formation system
├── effects/             # Visual effects (explosion, trails, popups)
├── environment/         # Obstacle and environment objects
├── items/               # Collectibles (gem, power_item)
├── player/              # Player ship + components (bomb, hitbox, shield)
├── projectiles/         # Bullet system (bullet, patterns, emitters)
├── shared/              # Cross-cutting (constants, buff_system, drop_table)
├── systems/             # Game systems (fever, graze, rank, score, trophy, etc.)
├── ui/                  # All UI (hud, menus, popups, weapon icons)
└── weapons/             # Weapon manager, registry, effects, orbital
```

### Central Controller Pattern (game.gd)

Game.gd is the hub: it owns all node references, connects all signals, and mediates all communication. Systems don't talk to each other directly - they emit signals that game.gd handles.

```gdscript
# Signal flow: subsystem -> game.gd -> other subsystem
weapon_manager.weapon_bullet_fired -> game._on_player_bullet_fired
wave_spawner.spawn_enemy           -> game._on_spawn_enemy
enemy.enemy_killed                 -> game._on_enemy_killed
player.player_died                 -> game._on_player_died
fever_system.fever_started         -> game._on_fever_started
```

### Data Registry Pattern (weapon_registry.gd)

Pure data definitions as `const` dictionaries. No logic, no state. Static helper functions for lookups.

```gdscript
const WEAPONS = { "front_laser": { display_name: "Front Laser", ... } }
const EVOLUTIONS = { "mega_laser": { display_name: "Mega Laser", ... } }
static func get_weapon(id: String) -> Dictionary: ...
static func get_damage_at_level(id: String, level: int) -> int: ...
```

### UIColors Autoload Pattern

Centralized color palette and font sizes in `scripts/ui/ui_colors.gd` (autoloaded as `UIColors`).

```gdscript
# Colors - ALWAYS use UIColors constants, never hardcode
label.add_theme_color_override("font_color", UIColors.CYAN)
style.bg_color = UIColors.PANEL_BG
style.border_color = UIColors.PANEL_BORDER

# Font size tiers (standardized for 320x480 viewport)
# FONT_TITLE=16, FONT_HERO=14, FONT_HEADING=12, FONT_BODY=10, FONT_SMALL=8, FONT_TINY=7
label.add_theme_font_size_override("font_size", UIColors.FONT_BODY)
```

### Collision Layer Convention

| Layer | Bit | Usage |
|-------|-----|-------|
| Player | 1 | Player ship body |
| Enemy | 2 | Enemy hitboxes and bodies |
| PlayerBullet | 4 | Player projectiles |
| EnemyBullet | 8 | Enemy projectiles |

### Group Convention

| Group | Purpose |
|-------|---------|
| `"game"` | Game controller node (for difficulty queries) |
| `"enemy_hitbox"` | Enemy damage areas |
| `"enemy_body"` | Enemy collision bodies |
| `"player_bullet"` | Player projectiles (for bomb cancel) |

## Rendering Patterns

### CRITICAL: Procedural Drawing Over Sprites

**NEVER** use sprite sheets as direct textures (they are multi-frame). Use `_draw()` procedural rendering or confirmed single-frame images.

```gdscript
# Pattern: procedural _draw() for game objects
func _draw():
    draw_circle(Vector2.ZERO, radius, color)
    draw_rect(Rect2(-w/2, -h/2, w, h), color)

func _process(delta):
    # Trigger redraw each frame for animated objects
    queue_redraw()
```

Used for: bullets, items (power_item, gem), meteors, weapon icons, explosions, homing missiles.

### Weapon Icon Drawing (weapon_icon_draw.gd)

Dedicated Control script with `setup(id, color, evolved)` and `_draw()` override. Each weapon has a unique 16x16 procedural icon.

## UI Patterns

### Menu Animation Pattern

All menus use fade animations with `TWEEN_PAUSE_PROCESS` (game tree is paused during menus):

```gdscript
var _is_animating: bool = false  # Guard against double-triggers

func show_menu():
    if _is_animating: return
    _is_animating = true
    # ... setup ...
    var tween = create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(node, "modulate:a", 1.0, 0.25)
    tween.tween_callback(func():
        _is_animating = false
        first_button.grab_focus()  # Always set focus for keyboard nav
    )
```

### Keyboard Focus Chain

All menus must support keyboard/gamepad navigation:

```gdscript
func _setup_focus_chain():
    for i in range(buttons.size()):
        var btn = buttons[i]
        var prev = buttons[i - 1 if i > 0 else buttons.size() - 1]
        var next = buttons[i + 1 if i < buttons.size() - 1 else 0]
        btn.focus_neighbor_top = prev.get_path()
        btn.focus_neighbor_bottom = next.get_path()
```

### Scene Transition Pattern

Fade-to-black before scene changes, with `_transitioning` guard:

```gdscript
var _transitioning: bool = false

func _transition_to_scene(scene_path: String):
    if _transitioning: return
    _transitioning = true
    var fade_rect = ColorRect.new()
    fade_rect.color = Color(0, 0, 0, 0)
    fade_rect.z_index = 200
    add_child(fade_rect)
    var tween = create_tween()
    tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
    tween.tween_callback(func():
        get_tree().change_scene_to_file(scene_path)
    )
```

### Layout Rules

- **NEVER** manipulate `position` on nodes inside VBoxContainer/HBoxContainer (breaks managed layout)
- **NEVER** use `scale` tweens on managed layout children
- Use `SIZE_EXPAND_FILL` for dynamic content, `SIZE_SHRINK_CENTER` only for intentionally centered fixed-width elements
- Use `modulate.a` for fade animations (safe in managed layouts)
- Minimum readable font size: `FONT_TINY = 7` (never use 4, 5, or 6)

## Safety Patterns

### Instance Validity

**ALWAYS** check `is_instance_valid()` before accessing nodes that could be freed:

```gdscript
if is_instance_valid(player):
    player.apply_damage(1)

for child in container.get_children():
    if is_instance_valid(child):
        child.queue_free()
```

### Immediate Tree Removal

Use `remove_child()` + `queue_free()` when the node must be gone from the tree immediately (not deferred):

```gdscript
# Pattern for cleanup that needs to take effect this frame
if child.get_parent():
    child.get_parent().remove_child(child)
child.queue_free()
```

### Reset Pattern

Every system must be fully resetable for game restart:

```gdscript
func reset():
    score = 0
    combo = 0
    is_active = false
    # Clear all dynamic state
```

Game.gd `start_game()` calls reset on every subsystem.

## Enemy Patterns

### Enemy Base Class

All enemies extend `enemy_base.gd`. Override behavior via states and `_process`:

```gdscript
enum State { ENTERING, ACTIVE, ATTACKING, TELEGRAPH, DYING }
var state: State = State.ENTERING
```

### Telegraph Pattern

Enemies telegraph attacks before executing them:

```gdscript
var is_telegraphing: bool = false
var telegraph_timer: float = 0.0

# In _process:
if is_telegraphing:
    telegraph_timer -= delta
    queue_redraw()  # Update visual indicator
    if telegraph_timer <= 0:
        is_telegraphing = false
        _execute_attack()
```

Visual telegraphs: overbright sprite flash, directional arrows via `_draw()`, dashed lines.

## Audio Patterns

### Bus Layout

3 buses: Master, Music, SFX. All AudioStreamPlayer nodes must specify bus.

### Music Crossfade

Two music players (`bg_music`, `bg_music_alt`) for crossfading:

```gdscript
func _crossfade_music(track):
    # Load into inactive player, fade volumes over 1.5s
```

### SFX Polyphony + Pitch Variation

```gdscript
sfx_shoot.max_polyphony = 4
sfx_shoot.pitch_scale = randf_range(0.9, 1.1)  # Organic feel
```

## Wave System Patterns

### Burst Spawning

Enemies spawn in bursts (2-5) with short intervals (0.3s), separated by longer pauses (0.8-2.0s).

### Wave Flavors

```gdscript
enum WaveFlavor { NORMAL, RUSH, SWARM, ELITE }
# NORMAL: standard, RUSH: fast bursts, SWARM: many weak, ELITE: few strong
```

### Formation Spawning

Predefined enemy formations (V-shape, line, escort, pincer) with wave-scaling probability.

## Commit Convention

```
<type>: <description>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## Context Management

**CRITICAL**: The file `context.md` at project root is the source of truth. Read before any action. Update after any change.

## Agent Team

The project uses a multi-agent development team (see CLAUDE.md). Individual agents handle specific domains (gameplay, UI, systems, design, QA, PM, writing). Orchestrator commands (`/team`, `/sprint`, `/backlog`) coordinate work across agents.
