import components.*;

typedef Entity = {
	var id: Int;
	var transform:  Transform;
	var item:       Item;
	var last_tx:    Transform;
	var collidable: Collidable;
	var drawable:   Drawable;
	var material:   Material;
	var physics:    Physics;
	var player:     Player;
	var trigger:    Trigger;
}
