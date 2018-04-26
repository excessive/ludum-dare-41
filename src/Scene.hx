class Scene {
	public var root = new SceneNode();
	var entities: Array<Entity> = [];

	public function new() {
		root.name = "Root";
	}

	public inline function get_entities(): Array<Entity> {
		entities = SceneNode.flatten_tree(root);
		return entities;
	}

	public inline function get_visible_entities(): Array<Entity> {
		return get_entities();
	}

	function update_parents(base: SceneNode) {
		for (child in base.children) {
			child.parent = base;
			update_parents(child);
		}
	}

	public function add(node: SceneNode) {
		root.children.push(node);

		if (node.parent == null) {
			node.parent = root;
		}
		for (child in node.children) {
			update_parents(node);
		}
	}

	public function remove(node: SceneNode) {
		if (node.parent != null) {
			node.parent.children.remove(node);
		}
	}
}
