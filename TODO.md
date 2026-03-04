## TODO

- [ ] block properties: friction. (0-1), bounce (0+) - can be stored as meta data or singleton source?
- [ ] add default properties if non are found
- [ ] `StaticBodyBlock`
- [ ] `RigidBodyBlock`
- [ ] Test gravity for doll

- [ ] Doll: `AnimationHandler`


- [ ] Once doll is done, extract input handler as 1 class: `InputHandler` so it creature AI can use it instead. Need a name for creatures which can move with its own ai which is not doll

  

# Notes: Proactive Change in geometry state: rolling / flipping
- initiating rolling only depends on hard fall with minor horizontal velocity threshold, dependent on gravity direction
- flipping only requires turning state, and can be stationary, but flip direction is dependant on redirection
- momentum redirection would be fun - where momentum direction is decided after the criteria for it been fulfilled
- `get_redirection()` and `redirection_frame_count`: which process frame after the criteria is fullfiled to apply geometry change AND momentum change
