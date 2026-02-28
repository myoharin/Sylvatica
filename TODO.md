## TODO
- [ ] Doll Code
- [ ] Doll: Movement Walking
- [ ] Doll: Movement Rolling
- [ ] Doll: Movement Jumping and derivitaives
- [ ] Doll: Movement Clinging
- [ ] Doll: Movement moveent around block properties
- [ ] Doll: Reactive change in geometry state

- [ ] block properties: friction. (0-1), bounce (0+)
- [ ] static block
- [ ] moving block
- [ ]
- [ ] Test gravity for doll
  
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
- flipping is facing direction dependant, and requires turning state
- momentum redirection would be fun - where momentum direction is decided after the criteria for it been fulfilled

## Finished
- [ ] implemented gravity acceleration
- [ ] implemengted gravity 