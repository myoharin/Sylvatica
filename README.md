# Toy Notes
| pseudoname | description                                       |
| ---------- | :------------------------------------------------ |
| `toy`      | Ingame Entities / Objects                         |
| `block`    | Coded Entities / Stageset                         |
| `doll`     | Player Character                                  |
| `plush`    | Creatures with creature ai                        |
| `sticker`  | Additional modules to decorate a toy's capability |

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
| 2     |
| 3     | real layer: where                                              |
    