# EnemyX V1.1 Test Matrix
────────────────────────────
CORE
[ ] startup
[ ] shutdown
[ ] restart
[ ] dependency absence
[ ] initialization failure recovery

NPC
[ ] spawn
[ ] delete
[ ] health
[ ] armor
[ ] weapons
[ ] ammo
[ ] death
[ ] cleanup
[ ] duplicate prevention

BEHAVIORS
[ ] guard
[ ] patrol
[ ] chase
[ ] investigate
[ ] target acquisition
[ ] behavior transitions

ZONES
[ ] enter
[ ] leave
[ ] spawn
[ ] despawn
[ ] limits
[ ] overlapping zones

ADMIN
[ ] authentication
[ ] NPC CRUD
[ ] group CRUD
[ ] zone CRUD
[ ] config reload
[ ] debug
[ ] unauthorized access

FRAMEWORKS
[ ] Standalone
[ ] ESX
[ ] QBCore
[ ] Qbox
[ ] vRP
[ ] ND

SECURITY
[ ] event spoofing
[ ] NUI spoofing
[ ] permission bypass
[ ] malformed payloads
[ ] rate limiting
[ ] invalid models
[ ] invalid weapons
[ ] coordinate abuse
[ ] entity-count abuse

PERFORMANCE
[ ] 10 NPC
[ ] 25 NPC
[ ] 50 NPC
[ ] 100 NPC
[ ] sustained load
[ ] cleanup under load