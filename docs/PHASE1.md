# PHASE1.md

Phase 1: Core gunplay + HitRewind + HUD

Tasks added in repo for Phase 1:
- [ ] Improve HitRewind sampling & interpolation (capsule checks)
- [ ] AntiCheat basic rate limiting
- [ ] ServerWeaponHandler: validation, use HitRewind timestamp
- [ ] LocalWeaponClient: verify payload timestamp usage
- [ ] HUDController: show ammo/money/health/round timer
- [ ] WeaponConfig: tune basic weapons (ak47, pistol)
- [ ] Add instructions to test Phase 1 in Roblox Studio via Rojo

Testing:
1. Use Rojo to sync project to Studio
2. Upload placeholder assets and set asset_ids.lua
3. Start Play (Server + Player) and test firing between two clients
4. Observe EVT_PlayerHit and EVT_PlayerKilled events and HUD updates
