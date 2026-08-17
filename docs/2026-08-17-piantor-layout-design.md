# Piantor Pro BT Layout - Design Spec

**Date:** 2026-08-17
**Goal:** Port the author's Gergo (QMK) keymap onto a Piantor Pro BT (42-key, ZMK), de-tangling content to fit fewer keys while preserving muscle memory.

## Source

- Gergo keymap: `~/dev/projects/qmk/qmk_firmware/keyboards/gboards/gergo/keymaps/toshism/keymap.c`
- Target: Piantor Pro BT - 3x6 columnar split + 3 thumbs per side = 42 keys, runs **ZMK**.

## Hardware constraints driving the port

- Gergo alpha block is already 3x6/side -> **alphas + home-row mods map 1:1**.
- Gergo had **4 thumbs/side**; Piantor has **3/side** -> one thumb per side had to be dropped/repurposed.
- Gergo inner "middle column" keys (`CLOSE_FRAME`, `TG(GAME)`, mouse `BTN1/BTN2`, extra inner `BSPC`) have **no physical home** -> dropped from base.
- On the Piantor the **outer thumbs are reachable** (they weren't on the Gergo), so they became first-class layer keys.

## Design principles applied

- **Cross-hand layers:** every layer is held with one hand and typed with the other (matches how the Gergo felt).
- **Muscle memory first:** where the author has ingrained habits (numpad grid, desktop-switch chord, erase keys), the Gergo behavior is preserved exactly.
- **Hot keys stay plain:** Space is a plain key (no layer-tap) to avoid hold-latency / misfire on the most-used key.

---

## BASE layer

```
 TAB    Q   W   E    R    T          Y    U    I    O    P    DEL
 ESC*   A   S   D    F    G          H    J    K    L    ;    '
 LSFT   Z   X   C    V    B          N    M    ,    .    /    -
              NUM   BKSP  SUPER   |  ENTER  SPACE  SYM
```

- `ESC*` (left-pinky home-row) = layer-tap: **tap = Esc, hold = NUMPAD** (mirrors Gergo `LT(TEN, Tab)`).
- Home-row mods (unchanged from Gergo): `D = LAlt`, `F = LCtl`, `J = RCtl`, `K = RAlt`.
- `DEL` at top-right (stock-Piantor position for backspace; author wanted a proper Delete there - something missing on the Gergo).
- `\` (backslash) was displaced by `DEL`; it now lives on the SYM layer.
- `LSFT` on left-pinky bottom row (Gergo position). Right-hand Shift intentionally omitted for now (see Deferred).

### Thumb cluster

```
 L-out        L-mid            L-in        |  R-in            R-mid    R-out
 NUM (hold)   BKSP / NAV       SUPER       |  ENTER / FUN     SPACE    SYM (hold)
 momentary    tap=Bksp,hold=   plain LGUI  |  tap=Enter,      plain    momentary
              NAV layer                    |  hold=FUN layer
```

- `SUPER` (L-in, plain `LGUI`) preserves the **herbstluftwm desktop-switch chord**: hold Super + right-hand `U I O` (top) / `M , .` (bottom) = `Super+{U,I,O,M,comma,dot}`, interpreted by hlwm. No keyboard-side config needed - relies on base QWERTY + Super on a thumb. None of those six keys collide with a home-row mod.
- Backspace = left thumb (L-mid). Delete = top-right. Erase keys split across hands.

---

## Layers

`.` = transparent (falls through to BASE). Each layer names its activation key.

### NUM - hold `L-out` (left outer thumb)
Number row, faithful to Gergo (1-5 left, 6-0 right).
```
 `    1   2   3   4   5        6   7   8   9   0   =
 .    .   .   .   .   .        .   .   .   .   -   .
 .    .   .   .   .   .        .   .   .   .   .   .
```

### SYM - hold `R-out` (right outer thumb)
Symbols from Gergo SYMB. `\` relocated here (displaced from base by DEL).
```
 !    @   {   }   |   .        .   .   .   \   .   .
 #    $   (   )   `   .        +   -   /   *   %   _
 %    ^   [   ]   ~   .        &   =   .   .   .   .
```
- **Dropped:** Gergo SYMB's `Alt+1..6` (Stumpwm workspace macros) on the top-right row. Assumed obsolete; re-add if still used.

### NAV - hold `L-mid` (the Backspace thumb)
Arrows on the right home row, exactly like Gergo (`H J K L` = left/down/up/right).
```
 .    .   .   .   .   .        .    PgUp Home End   .   DEL
 .    .   .   .   .   .        <-   v    ^    ->    .   .
 .    .   .   .   .   .        .    PgDn .    .     .   .
```

### FUN - hold `R-in` (the Enter thumb)
F-keys on the left hand (Gergo placement), media/volume on the right.
```
 F1   F2  F3  F4  F5  .        .    .     .     .     .    .
 F6   F7  F8  F9  F10 .        .    Mute  Vol-  Vol+  Play .
 F11  F12 .   .   .   .        .    .     .     .     .    .
```

### NUMPAD - hold `ESC` (left-pinky layer-tap)
Right-hand 3x3 calculator grid under index/middle/ring - the author's ingrained Gergo numpad.
```
 .    .   .   .   .   .        .    7   8   9   .   .      (U  I  O)
 .    .   .   .   .   .        0    4   5   6   .   .      (H  J  K  L)
 .    .   .   .   .   .        .    1   2   3   .   .      (N  M  ,  .)
```
- `7/8/9` on `U/I/O`, `4/5/6` on `J/K/L`, `1/2/3` on `M/,/.`.
- `0` on `H`, `.` on `N` (inner index column). Trial placement - easy to swap.

---

## Layer / activation summary

| Layer  | Activation            | Typed with | Cross-hand |
|--------|-----------------------|------------|------------|
| NUM    | L-out thumb (hold)    | both hands | -          |
| SYM    | R-out thumb (hold)    | both hands | -          |
| NAV    | L-mid thumb (Bksp hold) | right hand | yes      |
| FUN    | R-in thumb (Enter hold) | left hand  | yes      |
| NUMPAD | left-pinky (Esc hold)   | right hand | yes      |

---

## Deferred / open items

- **GAME layer** - dropped for now; author will likely revisit. Was a WASD-style gaming layout toggled by a Gergo inner key. Will need a combo or a spot on another layer to reach it.
- **Right-hand Shift** - only left-pinky Shift exists, so left-hand capitals are awkward. Left as-is per author; candidate future fix: home-row-mod shift on `;`, a one-shot shift, or a thumb.
- **SYM `Alt+1..6` macros** - dropped; confirm they're truly obsolete.
- **Space thumb hold** - currently unused (Space is plain). Available to host another layer later if wanted.
- **`0`/`.` numpad placement** (`H`/`N`) - trial; may swap.
- **Home-row mod / layer-tap tuning** - see implementation notes.

---

## Implementation notes (for the ZMK build)

- Target firmware is **ZMK** (not QMK). This design becomes a `zmk-config` repo: `config/piantor.keymap` + `config/piantor.conf` + `build.yaml`. Confirm the exact ZMK **board/shield** for the Piantor Pro BT before building.
- **Home-row mods** (`D/F/J/K`) and **layer-taps** (Esc, Bksp, Enter) are `hold-tap` behaviors in ZMK. They need tuning to avoid misfires during fast typing:
  - Set a sensible `tapping-term-ms` (~180-220).
  - Consider `flavor = "balanced"` or `"tap-preferred"`; for home-row mods, positional hold-tap (`hold-trigger-key-positions`) strongly reduces same-hand misfires.
- **Momentary layers** (NUM on L-out, SYM on R-out) = `&mo`.
- The **desktop-switch chord** needs nothing special in ZMK - it's plain `Super` (a thumb `&kp LGUI`) + base QWERTY, interpreted by herbstluftwm.
- Verify `0`/`.` and media keycodes render correctly on Linux/hlwm.

## Next step

Proceed to an implementation plan (writing-plans): bootstrap the zmk-config, encode BASE + 5 layers, tune hold-taps, build, flash, and validate the muscle-memory items (numpad grid, desktop chord, erase keys).
