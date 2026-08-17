# Piantor Pro BT Layout - Design Spec

**Date:** 2026-08-17
**Goal:** Port the author's Gergo (QMK) keymap onto a Piantor Pro BT (42-key, ZMK), preserving muscle memory.

> **Design note (history):** An initial version split the Gergo's combined layers into
> five smaller ones (NUM/SYM/NAV/FUN/NUMPAD). In testing that fought muscle memory - e.g.
> holding Backspace no longer gave symbols. The design was **realigned to match the Gergo's
> combined layers** (SYM = SYMB, NUM = NUMB). This document describes the final, shipped layout.

## Source

- Gergo keymap: `~/dev/projects/qmk/qmk_firmware/keyboards/gboards/gergo/keymaps/toshism/keymap.c`
- Target: Piantor Pro BT - 3x6 columnar split + 3 thumbs per side = 42 keys, runs **ZMK** (Keebart `keebart_nrf52840`).

## Hardware constraints

- Gergo alpha block is already 3x6/side -> **alphas + home-row mods map 1:1**.
- Gergo had **4 thumbs/side**; Piantor has **3/side**.
- Gergo inner "middle column" keys (`CLOSE_FRAME`, `TG(GAME)`, mouse buttons, extra inner `BSPC`) have no home -> dropped from base.
- Piantor outer thumbs are reachable (unlike the Gergo), so they became usable layer keys.

## Guiding principle: muscle memory first

Where the author has ingrained habits (which thumb reaches which layer, the numpad grid,
the herbstluftwm desktop-switch chord, the erase keys), the Gergo behavior is preserved exactly.

---

## BASE layer

```
 TAB    Q   W   E    R    T          Y    U    I    O    P    DEL
 ESC*   A   S   D    F    G          H    J    K    L    ;    '
 LSFT   Z   X   C    V    B          N    M    ,    .    /    -
              NUM   BKSP  SUPER   |  ENTER  SPACE  SYM
```

- `ESC*` (left-pinky home-row) = layer-tap: **tap = Esc, hold = NUMPAD** (mirrors Gergo `LT(TEN, Tab)`).
- Home-row mods (positional, unchanged from Gergo): `D = LAlt`, `F = LCtl`, `J = RCtl`, `K = RAlt`.
- `DEL` at top-right (stock-Piantor Backspace position; a proper Delete the Gergo lacked).
- `\` (backslash) is displaced by `DEL` and lives on the SYM layer.
- `LSFT` on left-pinky bottom. Right-hand Shift intentionally omitted for now (see Deferred).

### Thumb cluster (matches Gergo muscle memory)

```
 L-out        L-mid          L-in    |  R-in           R-mid           R-out
 NUM (hold)   BKSP / SYM     SUPER   |  ENTER / NUM    SPACE / SYM     SYM (hold)
 momentary    tap=Bksp,      plain   |  tap=Enter,     tap=Space,      momentary
              hold=SYM       LGUI    |  hold=NUM       hold=SYM
```

- **SYM** reachable from Backspace (L-mid), Space (R-mid), and R-out - like the Gergo, where both `LT(SYMB,BSPC)` and `LT(SYMB,SPC)` reached SYMB.
- **NUM** reachable from Enter (R-in) and L-out - like the Gergo `LT(NUMB,ENT)` / `LT(NUMB,ESC)`.
- **SUPER** (L-in, plain `LGUI`) preserves the **herbstluftwm desktop-switch chord**: hold Super +
  right-hand `U I O` (top) / `M , .` (bottom). Interpreted by hlwm; needs no keyboard-side config.
  None of those six keys collide with a home-row mod.
- Backspace = left thumb, Delete = top-right (erase keys split across hands).

---

## Layers (recombined to match the Gergo)

`.` = transparent (falls through to BASE).

### SYM - hold Backspace / Space / R-out   (= Gergo SYMB)
```
 !    @   {   }   |   .        .   .   .   \   .   .
 #    $   (   )   `   .        +   -   /   *   %   _
 %    ^   [   ]   ~   .        &   =   .   .   .   .
```
Dropped from the Gergo original: the `Alt+1..6` Stumpwm workspace macros.

### NUM - hold Enter / L-out   (= Gergo NUMB: numbers + F-keys + arrows, one layer)
```
 .    1   2   3   4   5        6    7    8    9    0    .
 F1   F2  F3  F4  F5  F6       ←    ↓    ↑    →    Vol- Vol+
 F7   F8  F9  F10 F11 F12      Home PgDn PgUp End  .    .
```
Numbers on top, F-keys on the left hand, arrows/volume on the right - exactly the Gergo `NUMB` split.
(Gergo's bottom-right mouse macros were dropped; Home/End/PgUp/PgDn added in their place.)

### NUMPAD - hold left-pinky (Esc)   (= Gergo TEN + Bluetooth/system keys)
```
 .    .    .    .    .    .          .   7   8   9   .   .      (U I O)
 .    BT0  BT1  BT2  BT3  BT4        0   4   5   6   .   .      (H J K L)
 .    BCLR RGB  RST  BOOT UNLK       .   1   2   3   .   .      (N M , .)
```
- Right hand: the Gergo numpad grid - `7/8/9` on `U/I/O`, `4/5/6` on `J/K/L`, `1/2/3` on `M/,/.`,
  `0` on `H`, `.` on `N`.
- Left hand: Bluetooth + system keys (the Gergo had none - wired board). `BT_SEL 0-4` on `A-G`;
  `BT_CLR`, `RGB_TOG`, `sys_reset`, `bootloader`, `studio_unlock` on `Z-B`.

---

## Layer / activation summary

| Layer  | Activation                              | Gergo equivalent |
|--------|-----------------------------------------|------------------|
| SYM    | Backspace hold, Space hold, R-out hold  | SYMB             |
| NUM    | Enter hold, L-out hold                  | NUMB             |
| NUMPAD | left-pinky (Esc) hold                   | TEN              |

Handy combos that moved onto the NUMPAD layer (hold left-pinky Esc, then):
- `+ V` -> **bootloader** (KEEBART drive for flashing)
- `+ B` -> **studio_unlock** (ZMK Studio)
- `+ A..G` -> **switch Bluetooth profile** 0-4

---

## Deferred / open items

- **GAME layer** - dropped for now; author will likely revisit (WASD-style gaming layout).
- **Right-hand Shift** - only left-pinky Shift exists; left-hand capitals are awkward. Candidate future
  fix: home-row-mod shift, a one-shot shift, or a thumb.
- **nice_view left screen** - the stock ZMK `nice_view` widget devotes its whole middle third to the
  BT-profile picker (five circles), which is wasted space here. Reclaiming it needs a custom status
  widget (copy a `nice_view`-style shield into the repo, edit `widgets/status.c`). Paused mid-decision
  on what to show instead (big layer name / battery % / logo / blank).
- **`Alt+1..6` Stumpwm macros** - dropped from SYM; confirm truly obsolete.

---

## Implementation / flash notes (ZMK)

- Firmware is **ZMK**. Repo: `~/dev/projects/piantor-zmk` (-> `github.com/toshism/piantor-zmk`).
  Needs `boards/arm/piantor_pro_bt/` copied from `github.com/Keebart/zmk-config` (module.yml `board_root: .`);
  without it every build target fails.
- **Build:** push -> GitHub Actions builds the `.uf2`s (not local). `gh run download <id>` fetches artifacts.
  `nice_view-piantor_pro_bt_left-zmk.uf2` is the real firmware; `settings_reset-*` wipes BT bonds.
- **Flash (LEFT/central half only, for keymap changes):**
  1. Enter bootloader via **key combo** (double-tap physical reset was unreliable): hold **left-pinky
     (Esc/NUMPAD) + `V`**.
  2. Board mounts as `/dev/sda` label `KEEBART`; `udisksctl mount -b /dev/sda` -> `/media/tosh/KEEBART`.
  3. `cp` the left `.uf2` onto it; it auto-ejects and reboots. BT bonds survive a normal keymap flash.
- Flashing needs a **USB data cable** (bootloader only shows over USB). The Gergo is often also plugged in -
  make sure combos land on the Piantor.
- **Home-row mods** and **layer-taps** are ZMK `hold-tap` behaviors with positional triggers +
  `tapping-term-ms`/`quick-tap-ms`/`require-prior-idle-ms` tuning to avoid misfires.
