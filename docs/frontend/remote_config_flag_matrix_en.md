# Remote Config Flags (Dev/Offline)

- login_variant: string (A|B)
  - Default (offline): A
  - Behavior: selects login UI variant; in offline mode fetch is skipped and cached/default returned deterministically.

Notes
- In offline (USE_EMULATOR=true), fetch is skipped in ExperimentService and local cached/default is used.
- Add future flags here with their defaults and UI impact summary.
