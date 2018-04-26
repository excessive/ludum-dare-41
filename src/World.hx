import math.Vec3;
import math.Mat4;
import math.Bounds;
import math.Triangle;
import math.Octree;

class World {
	static var tri_octree: Octree<Triangle>;
	static var octree_looseness = 1.0;
	public static var world_size(default, null): Float = 512;

	public static inline function convert(t: lua.Table<Int, Dynamic>) {
		var tris = [];
		lua.PairTools.ipairsEach(t, function(i, v) {
			var v0 = new Vec3(v[1].position[1], v[1].position[2], v[1].position[3]);
			var v1 = new Vec3(v[2].position[1], v[2].position[2], v[2].position[3]);
			var v2 = new Vec3(v[3].position[1], v[3].position[2], v[3].position[3]);
			var t: Triangle = new Triangle(v0, v1, v2, new Vec3());
			t.vn = t.normal();
			tris.push(t);
		});
		return tris;
	}

	public static function init(level: Main.LevelEntry, index: Int) {
		tri_octree = new Octree(world_size, new Vec3(0, 0, 0), 2.0, octree_looseness);

		var root = new SceneNode();
		root.name = "Map";
		root.hidden = true;

		var name = level.map;

		root.children.push(Stage.load('assets/maps/$name.json', level.name, index));

		var map_model = iqm.Iqm.load('assets/models/$name.iqm', true);
		root.name = "Map";
		root.transform.is_static = true;
		root.transform.update();

		root.drawable = [ map_model.mesh ];
		root.material = {
			color: new Vec3(1.0, 1.0, 1.0),
			roughness: 1.0,
			metalness: 0.0,
			emission: 0.0,
			triplanar: true,
			vampire: false
		};
		var tris = convert(map_model.triangles);
		add_triangles(tris, new Mat4());

		return root;
	}

	public static function get_triangles(min: Vec3, max: Vec3): Array<Triangle> {
		var tris = tri_octree.get_colliding(Bounds.from_extents(min, max));

		for (tri in tris) {
			Debug.triangle(tri, 1, 0, 1);
		}

		return tris;
	}

	public static function add_triangles(tris: Array<Triangle>, xform: Mat4) {
		for (t in tris) {
			var xt = new Triangle(
				xform * t.v0,
				xform * t.v1,
				xform * t.v2,
				xform * t.vn
			);
			var min = xt.min();
			var max = xt.max();
			tri_octree.add(xt, Bounds.from_extents(min, max));
		}
	}
}
