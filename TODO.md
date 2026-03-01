## TODO
- [ ] Doll Code
- [ ] Doll: Movement Walking
- [ ] Doll: Movement Rolling
- [ ] Doll: Movement Jumping and derivitaives
- [ ] Doll: Movement Clinging / wall jump
- [ ] Doll: Movement moveent around block properties
- [ ] Doll: Reactive change in geometry state
- [ ] Doll: isolate the `MoventController` into modules: 
  - [x] `GravityHandler`
  - [ ] `MovementController` which handles movement inputs and try movement input and geometry
  - [ ] `RagDollController` which can be enabled to turn the thing into a ragdoll
  
- [ ] Doll: Controls + Proactive change in geometry state
- [ ] Doll: Instant variants of trigger

- [ ] Doll: `InputHandler`**

- [ ] block properties: friction. (0-1), bounce (0+) - can be stored as meta data or singleton source?
- [ ] add default properties if non are found
- [ ] `StaticBodyBlock`
- [ ] `RigidBodyBlock`
- [ ] Test gravity for doll

- [ ] Doll: `AnimationHandler`


- [ ] Once doll is done, extract input handler as 1 class: `InputHandler` so it creature AI can use it instead. Need a name for creatures which can move with its own ai which is not doll

  
# Notes: Reactive Change in geometry state

- static blocks and static moving blocks can have an implied force
- force applied on character body will result impulse
- strong enough impulse can force a change in state

- Doll should remain standing as much as possible
- static blocks can crush character into a crouch -> sit -> crawl
- flips and rolls mandates player input
- ragdoll can be turned into rolls with hardLands

- 8 factorial possibily for all the change in state

# Notes: Proactive Change in geometry state: rolling / flipping
- initiating rolling only depends on hard fall with minor horizontal velocity threshold, dependent on gravity direction
- flipping only requires turning state, and can be stationary, but flip direction is dependant on redirection
- momentum redirection would be fun - where momentum direction is decided after the criteria for it been fulfilled
- `get_redirection()` and `redirection_frame_count`: which process frame after the criteria is fullfiled to apply geometry change AND momentum change

## Finished
- [ ] implemented gravity acceleration
- [ ] implemengted gravity 