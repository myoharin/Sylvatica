# Toy Notes
| pseudoname | description                                       |
| ---------- | :------------------------------------------------ |
| `toy`      | Ingame Entities / Objects                         |
| `toy.block`    | Coded interactable Entities / Stageset                         |
| `toy.doll`     | Player Character                                  |
| `toy.plush`    | Creatures with creature ai                        |
| `toy.sticker`  | ??? |
|``||
|||
|||

# Layer Mask Planning
| object types   | layer | mask  |
| -------------- | :---- | :---- |
| ragdoll        | 1     | 1     |
| animation body |       |       |
| character body |       | 2     |
| blocks         | 1,2,3 | 1,2,3 |
| plants         |       | 1,2,3 |

| Layer | description                                                    |
| :---- | :------------------------------------------------------------- |
| 1     | ragdoll layer: meant for messy use cases and react to stageste |
| 2     | character layers: where core hitbox stays
| 3     | real layer: where                                              |
    