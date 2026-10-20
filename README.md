# Harika MM2 Halloween Hub

Mobile-first purple neon Lua UI prototype for Android/Delta testing.

## Current status
- Custom purple neon panel with touch drag, minimize/expand, start/stop, rescan, and session counters.
- Candy detector checks common MM2 pickup names and `CoinID = "Candy"`.
- Experimental movement uses the character Humanoid's normal `MoveTo`; it does **not** teleport, disable collisions, spoof touches, or load remote Lua code.
- **Not verified in a live MM2 server or Delta.** The Halloween event's current pickup structure may differ. The counter is a local estimate, not a server-confirmed candy total.

## Raw script
`https://raw.githubusercontent.com/mm2vault/Harika-MM2-Halloween-Hub.lua/main/HarikaMM2HalloweenHub.lua`

## Testing
1. Test in a private/low-risk session first.
2. Open the hub and tap **RESCAN** while a round with candy is active.
3. If it finds zero targets, record the live pickup's name, attributes, and parent/container names; the detector needs adapting.
4. If targets are found but the character cannot path to them, the movement logic needs a map-aware pathing pass.

No guarantee of compatibility with current MM2, Delta, or future event updates.
