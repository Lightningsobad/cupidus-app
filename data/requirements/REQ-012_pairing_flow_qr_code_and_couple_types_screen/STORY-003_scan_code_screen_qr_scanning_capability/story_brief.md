# Story Brief: STORY-003 Scan-Code Screen QR Scanning Capability

- Actor: user who has received a partner's pairing code/QR (invitee).
- Capability: wire the join-code screen's existing "Scan QR" affordance to a
  real device-camera QR scan that feeds into the same pairing capability as
  manual code entry.
- Business value: faster pairing when both partners are physically together,
  matching the create-code side's new QR display (STORY-002).
- Key business rules: a scanned code must produce an identical pairing
  outcome to a typed code — QR scanning is an additional input method, not a
  new pairing mechanism; camera permission is requested at scan time, not
  earlier.
- Key edge/failure case: camera permission denied/unavailable, or an
  invalid/expired scanned code — both must degrade honestly with a working
  fallback to the existing manual entry UI, never a dead end or fabricated
  success.
- Existing system entry/discoverability seed: existing screen and existing
  "Scan QR" icon/label; only the behavior behind it is new.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ1 (exact scan
  mechanism) partially unresolved — see "Open Question Impact".
- Complexity and why: complex — camera-permission handling, live QR
  decoding, and multiple failure/fallback states across a security-sensitive
  device capability. Lane: shared.
- Dependencies: NONE.
