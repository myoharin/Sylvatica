class_name DollRagdollComponent
extends RigidBody2D

@export var animator: DollActiveRagdollAnimator
@export_enum("Head:0", "Torso:1", "Feet:2") var component_type = 0



enum RagdollComponentType {
    HEAD = 0,
    TORSO = 1,
    FEET = 2
}

# this class reports any physical contact to the RagdollAnimator and distributes the force proper.

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    # Loop through all contacts
    for i in range(state.get_contact_count()):
        # The current loop index 'i' is the contact index
        var contact_pos = state.get_contact_local_position(i)
        var collider = state.get_contact_collider_object(i)
        var contact_impulse = state.get_contact_impulse(i)
        
        # print("Contact ", i, " at: ", contact_pos, " with: ", collider)

        # Report it.
        animator.report_ragdoll_component_contact(
            component_type,
            contact_impulse
        )
    
