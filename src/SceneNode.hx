import components.*;

class SceneNode {
	public var parent:   Null<SceneNode>  = null;
	public var children: Array<SceneNode> = [];
	public var name: String;

	// hide from the editor (for generated entities where it will not be useful)
	public var hidden: Bool = false;

	private static var g_id: Int = 0;

	private var data: Entity = {
		id: g_id++,
		transform: new Transform(),
		last_tx: new Transform(),
		item: null,
		collidable: null,
		drawable: null,
		physics: null,
		player: null,
		material: null,
		trigger: null
	};

	// read-only
	public var id(get, never): Int;
	public inline function get_id() { return data.id; }

	public var item(get, set): Item;
	public inline function get_item() { return data.item; }
	public inline function set_item(item: Item) { data.item = item; return item; }

	// redirect all data to entity fields for convenience. these get compiled out.
	// this makes usage a little nicer and saves a lot of allocations when flattening
	public var transform(get, never):  Transform;
	public inline function get_transform() { return data.transform; }
	// public inline function set_transform(tx: Transform) { data.transform = tx; return tx; }

	public var last_tx(get, never):  Transform;
	public inline function get_last_tx() { return data.last_tx; }
	// public inline function set_last_tx(tx: Transform) { data.last_tx = tx; return tx; }

	public var collidable(get, set): Null<Collidable>;
	public inline function get_collidable() { return data.collidable; }
	public inline function set_collidable(coll: Null<Collidable>) { data.collidable = coll; return coll; }

	public var drawable(get, set): Null<Drawable>;
	public inline function get_drawable() { return data.drawable; }
	public inline function set_drawable(draw: Null<Drawable>) { data.drawable = draw; return draw; }

	public var material(get, set): Null<Material>;
	public inline function get_material() { return data.material; }
	public inline function set_material(mat: Null<Material>) { data.material = mat; return mat; }

	public var physics(get, set): Null<Physics>;
	public inline function get_physics() { return data.physics; }
	public inline function set_physics(phys: Null<Physics>) { data.physics = phys; return phys; }

	public var player(get, set): Null<Player>;
	public inline function get_player() { return data.player; }
	public inline function set_player(tx: Player) { data.player = tx; return tx; }

	public var trigger(get, set): Null<Trigger>;
	public inline function get_trigger() { return data.trigger; }
	public inline function set_trigger(tr: Trigger) { data.trigger = tr; return tr; }

	public inline function new() {
		name = '<unnamed ${data.id}>';
	}

	public static function flatten_tree(root: SceneNode, ?ents: Array<Entity>) {
		var entities = ents != null? ents : [];
		for (node in root.children) {
			entities.push(node.data);
			flatten_tree(node, entities);
		}
		return entities;
	}
}
