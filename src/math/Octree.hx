package math;

typedef Entry<T> = {
	data: T,
	bounds: Bounds
}

typedef HitFn<T> = Ray -> Array<Entry<T>> -> Bool;

class Node<T> {
	/** Bounding box that represents this node **/
	var bounds: Bounds;

	/** Bounds of potential children to this node. These are actual size (with looseness taken into account), not base size **/
	var childBounds: Array<Bounds>;

	/** Size of this node **/
	var size: Vec3;

	/** Objects in this node **/
	var objects: Array<Entry<T>> = [];

	/** Child nodes **/
	var children: Array<Node<T>> = [];

	/** Length of this node, if it has a looseness of 1.0 **/
	public var baseLength: Float;

	/** Minimum size for a node in this octree **/
	var minSize: Float;

	/** Looseness value for this node **/
	var looseness: Float;

	// Center of this node
	public var center: Vec3;

	// Actual length of sides, taking the looseness value into account
	var adjLength: Float;

	// If there are already numObjectsAllowed in a node, we split it into children
	// A generally good number seems to be something around 8-15
	var numObjectsAllowed = 8;

	/** Constructor.
	 * @param baseLength Length of this node, not taking looseness into account
	 * @param minSize Minimum size of nodes in this octree
	 * @param looseness Multiplier for baseLengthVal to get the actual size
	 * @param center Centre position of this node
	**/
	public function new(baseLength: Float, minSize: Float, looseness: Float, center: Vec3) {
		this.set_values(baseLength, minSize, looseness, center);
	}

	/** Set values for this node.
	 * @param baseLength Length of this node, not taking looseness into account
	 * @param minSize Minimum size of nodes in this octree
	 * @param looseness Multiplier for baseLengthVal to get the actual size
	 * @param center Centre position of this node
	**/
	inline function set_values(baseLength: Float, minSize: Float, looseness: Float, center: Vec3) {
		this.baseLength = baseLength;
		this.minSize = minSize;
		this.looseness = looseness;
		this.center = center;
		this.adjLength = this.looseness * this.baseLength;
		this.size = new Vec3(this.adjLength, this.adjLength, this.adjLength);
		this.bounds = new Bounds(this.center, this.size);
		var quarter           = this.baseLength / 4;
		var childActualLength = (this.baseLength / 2) * this.looseness;
		var childActualSize   = new Vec3(childActualLength, childActualLength, childActualLength);
		this.childBounds = [
			new Bounds(this.center + new Vec3(-quarter,  quarter, -quarter), childActualSize),
			new Bounds(this.center + new Vec3( quarter,  quarter, -quarter), childActualSize),
			new Bounds(this.center + new Vec3(-quarter,  quarter,  quarter), childActualSize),
			new Bounds(this.center + new Vec3( quarter,  quarter,  quarter), childActualSize),
			new Bounds(this.center + new Vec3(-quarter, -quarter, -quarter), childActualSize),
			new Bounds(this.center + new Vec3( quarter, -quarter, -quarter), childActualSize),
			new Bounds(this.center + new Vec3(-quarter, -quarter,  quarter), childActualSize),
			new Bounds(this.center + new Vec3( quarter, -quarter,  quarter), childActualSize)
		];
	}

	/** Add an object.
	* @param obj Object to add
	* @param objBounds 3D bounding box around the object
	* @return boolean True if the object fits entirely within this node
	**/
	public function add(obj, objBounds) {
		if (!Intersect.encapsulate_aabb(this.bounds, objBounds)) {
			return false;
		}

		// We know it fits at this level if we've got this far
		// Just add if few objects are here, or children would be below min size
		if (this.objects.length < this.numObjectsAllowed || this.baseLength / 2 < this.minSize) {
			this.objects.push({
				data: obj,
				bounds: objBounds
			});
		}
		// Fits at this level, but we can go deeper. Would it fit there?
		else {
			var best_fit_child = -1;

			// Create the 8 children
			if (this.children.length == 0) {
				this.split();

				if (this.children.length == 0) {
					trace("Child creation failed for an unknown reason. Early exit.");
					return false;
				}

				// Now that we have the new children, see if this node's existing objects would fit there
				var i = this.objects.length-1;
				while (i >= 0) {
					var object = this.objects[i];
					// Find which child the object is closest to based on where the
					// object's center is located in relation to the octree's center.
					best_fit_child = this.best_fit_child(object.bounds);

					// Does it fit?
					if (Intersect.encapsulate_aabb(this.children[best_fit_child].bounds, object.bounds)) {
						this.children[best_fit_child].add(object.data, object.bounds); // Go a level deeper
						this.objects.splice(i, 1); // Remove from here
					}

					i -= 1;
				}
			}

			// Now handle the new object we're adding now
			best_fit_child = this.best_fit_child(objBounds);

			if (Intersect.encapsulate_aabb(this.children[best_fit_child].bounds, objBounds)) {
				this.children[best_fit_child].add(obj, objBounds);
			}
			else {
				this.objects.push({
					data: obj,
					bounds: objBounds
				});
			}
		}

		return true;
	}

	/** Remove an object. Makes the assumption that the object only exists once in the tree.
	 * @param obj Object to remove
	 * @return boolean True if the object was removed successfully
	**/
	public function remove(obj) {
		var removed = false;

		for (i in 0...this.objects.length) {
			var object = this.objects[i];
			if (object.data == obj) {
				this.objects.splice(i, 1);
				removed = true;
				break;
			}
		}

		if (!removed) {
			for (child in this.children) {
				removed = child.remove(obj);
				if (removed) {
					break;
				}
			}
		}

		if (removed) {
			// Check if we should merge nodes now that we've removed an item
			if (this.should_merge()) {
				this.merge();
			}
		}

		return removed;
	}

	/** Check if the specified bounds intersect with anything in the tree. See also: get_colliding.
	 * @param checkBounds Bounds to check
	 * @return boolean True if there was a collision
	**/
	public function is_colliding(checkBounds) {
		// Are the input bounds at least partially in this node?
		if (!Intersect.aabb_aabb(this.bounds, checkBounds)) {
			return false;
		}

		// Check against any objects in this node
		for (object in this.objects) {
			if (Intersect.aabb_aabb(object.bounds, checkBounds)) {
				return true;
			}
		}

		// Check children
		for (child in this.children) {
			if (child.is_colliding(checkBounds)) {
				return true;
			}
		}

		return false;
	}

	/** Returns an array of objects that intersect with the specified bounds, if any. Otherwise returns an empty array. See also: is_colliding.
	 * @param checkBounds Bounds to check. Passing by ref as it improve performance with structs
	 * @param results List results
	 * @return table Objects that intersect with the specified bounds
	**/
	public function get_colliding(checkBounds: Bounds, results: Array<T>) {
		// trace(this.children.length, this.objects.length);

		// Are the input bounds at least partially in this node?
		if (!Intersect.aabb_aabb(this.bounds, checkBounds)) {
			return;
		}

		// Check against any objects in this node
		for (object in this.objects) {
			if (Intersect.aabb_aabb(object.bounds, checkBounds)) {
				results.push(object.data);
			}
		}

		// Check children
		for (child in this.children) {
			child.get_colliding(checkBounds, results);
		}
	}

	/** Returns an array of objects that intersect with the specified frustum, if any. Otherwise returns an empty array. See also: is_colliding.
	 * @param checkFrustum Frustum to check. Passing by ref as it improve performance with structs
	 * @param results List results
	**/
	public function get_colliding_frustum(checkFrustum: Frustum, results: Array<T>) {
		// Are the input bounds at least partially in this node?
		if (!Intersect.aabb_frustum(this.bounds, checkFrustum)) {
			return;
		}

		// Check against any objects in this node
		for (object in this.objects) {
			if (Intersect.aabb_frustum(object.bounds, checkFrustum)) {
				results.push(object.data);
			}
		}

		// Check children
		for (child in this.children) {
			child.get_colliding_frustum(checkFrustum, results);
		}
	}

	/** Cast a ray through the node and its children
	 * @param ray Ray with a position and a direction
	 * @param func Function to execute on any objects within child nodes
	 * @param depth (used internally)
	 * @return boolean True if an intersect is detected
	 **/
	public function cast_ray(ray, func: HitFn<T>, depth: Int) {
		if (Intersect.ray_aabb(ray, this.bounds) != null) {
			if (this.objects.length > 0) {
				if (func(ray, this.objects)) {
					return true;
				}
			}

			for (child in this.children) {
				if (child.cast_ray(ray, func, depth + 1)) {
					return true;
				}
			}
		}

		return false;
	}

	/** Set the 8 children of this octree.
	 * @param childOctrees The 8 new child nodes
	**/
	public function set_children(childOctrees: Array<Node<T>>) {
		if (childOctrees.length != 8) {
			trace("Child octree array must be length 8. Was length: " + Std.string(childOctrees.length));
			return;
		}

		this.children = childOctrees;
	}

	/** We can shrink the octree if:
	 * - This node is >= double minLength in length
	 * - All objects in the root node are within one octant
	 * - This node doesn't have children, or does but 7/8 children are empty
	 * We can also shrink it if there are no objects left at all!
	 * @param minLength Minimum dimensions of a node in this octree
	 * @return table The new root, or the existing one if we didn't shrink
	**/
	public function shrink_if_possible(minLength: Float): Node<T> {
		if (this.baseLength < 2 * minLength) {
			return this;
		}

		if (this.objects.length == 0 && this.children.length == 0) {
			return this;
		}

		// Check objects in root
		var bestFit = 0;

		for (i in 0...this.objects.length) {
			var object = this.objects[i];
			var newBestFit = this.best_fit_child(object.bounds);

			if (i == 0 || newBestFit == bestFit) {
				// In same octant as the other(s). Does it fit completely inside that octant?
				if (Intersect.encapsulate_aabb(this.childBounds[newBestFit], object.bounds)) {
					if (bestFit < 1) {
						bestFit = newBestFit;
					}
				}
				else {
					// Nope, so we can't reduce. Otherwise we continue
					return this;
				}
			}
			else {
				return this; // Can't reduce - objects fit in different octants
			}
		}

		// Check objects in children if there are any
		if (this.children.length > 0) {
			var childHadContent = false;

			for (i in 0...this.children.length) {
				var child = this.children[i];
				if (child.has_any_objects()) {
					if (childHadContent) {
						return this; // Can't shrink - another child had content already
					}

					if (bestFit > 0 && bestFit != i) {
						return this; // Can't reduce - objects in root are in a different octant to objects in child
					}

					childHadContent = true;
					bestFit = i;
				}
			}
		}

		// Can reduce
		if (this.children.length == 0) {
			// We don't have any children, so just shrink this node to the new size
			// We already know that everything will still fit in it
			this.set_values(this.baseLength / 2, this.minSize, this.looseness, this.childBounds[bestFit].center);
			return this;
		}

		// We have children. Use the appropriate child as the new root node
		return this.children[bestFit];
	}

	/** Splits the octree into eight children. **/
	function split() {
		if (this.children.length > 0) {
			return;
		}

		var quarter   = this.baseLength / 4;
		var newLength = this.baseLength / 2;

		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3(-quarter,  quarter, -quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3( quarter,  quarter, -quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3(-quarter,  quarter,  quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3( quarter,  quarter,  quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3(-quarter, -quarter, -quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3( quarter, -quarter, -quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3(-quarter, -quarter,  quarter)));
		this.children.push(new Node(newLength, this.minSize, this.looseness, this.center + new Vec3( quarter, -quarter,  quarter)));
	}

	/** Merge all children into this node - the opposite of Split.
	 * Note: We only have to check one level down since a merge will never happen if the children already have children,
	 * since THAT won't happen unless there are already too many objects to merge.
	**/
	function merge() {
		for (child in this.children) {
			for (object in child.objects) {
				this.objects.push(object);
			}
		}

		// Remove the child nodes (and the objects in them - they've been added elsewhere now)
		this.children = [];
	}

	/** Find which child node this object would be most likely to fit in.
	 * @param objBounds The object's bounds
	 * @return number One of the eight child octants
	**/
	inline function best_fit_child(objBounds: Bounds) {
		return (objBounds.center.x <= this.center.x ? 0 : 1)
			+   (objBounds.center.y >= this.center.y ? 0 : 4)
			+   (objBounds.center.z <= this.center.z ? 0 : 2)
		;
	}

	/** Checks if there are few enough objects in this node and its children that the children should all be merged into this.
	 * @return boolean True there are less or the same abount of objects in this and its children than numObjectsAllowed
	**/
	function should_merge() {
		var totalObjects = this.objects.length;

		for (child in this.children) {
			if (child.children.length > 0) {
				// If any of the *children* have children, there are definitely too many to merge,
				// or the child would have been merged already
				return false;
			}

			totalObjects = totalObjects + child.objects.length;
		}

		return totalObjects <= this.numObjectsAllowed;
	}

	/** Checks if this node or anything below it has something in it.
	 * @return boolean True if this node or any of its children, grandchildren etc have something in the
	**/
	function has_any_objects() {
		if (this.objects.length > 0) {
			return true;
		}

		for (child in this.children) {
			if (child.has_any_objects()) {
				return true;
			}
		}

		return false;
	}
}

class Octree<T> {
	/** The total amount of objects currently in the tree **/
	var count: Int;
	/** Size that the octree was on creation **/
	var initialSize: Float;
	/** Minimum side length that a node can be - essentially an alternative to having a max depth **/
	var minSize: Float;
	/** Should be a value between 1 and 2. A multiplier for the base size of a node.
	 * 1.0 is a "normal" octree, while values > 1 have overlap **/
	var looseness: Float;

	/** Root node of the octree **/
	var rootNode: Node<T>;

	/** Constructor for the bounds octree.
	 * @param initialWorldSize Size of the sides of the initial node, in metres. The octree will never shrink smaller than this
	 * @param initialWorldPos Position of the centre of the initial node
	 * @param minNodeSize Nodes will stop splitting if the new nodes would be smaller than this (metres)
	 * @param looseness Clamped between 1 and 2. Values > 1 let nodes overlap
	**/
	public function new(initialWorldSize: Float, initialWorldPos: Vec3, minNodeSize: Float = 1.0, looseness: Float = 1.0) {
		if (minNodeSize > initialWorldSize) {
			trace("Minimum node size must be at least as big as the initial world size. Was: " + Std.string(minNodeSize) + " Adjusted to: " + Std.string(initialWorldSize));
			minNodeSize = initialWorldSize;
		}
		this.count = 0;
		this.initialSize = initialWorldSize;
		this.minSize = minNodeSize;
		this.looseness = Utils.clamp(looseness, 1, 2);
		this.rootNode = new Node(this.initialSize, this.minSize, this.looseness, initialWorldPos.copy());
	}

	/** Used when growing the octree. Works out where the old root node would fit inside a new, larger root node.
	 * @param xDir X direction of growth. 1 or -1
	 * @param yDir Y direction of growth. 1 or -1
	 * @param zDir Z direction of growth. 1 or -1
	 * @return Octant where the root node should be
	**/
	function get_root_pos_index(xDir: Float, yDir: Float, zDir: Float): Int {
		var result = (xDir > 0) ? 1 : 0;
		if (yDir < 0) return result + 4;
		if (zDir > 0) return result + 2;
		return result;
	}

	/** Add an object.
	 * @param obj Object to add
	 * @param objBounds 3D bounding box around the object
	 */
	public function add(obj: T, objBounds: Bounds) {
		// Add object or expand the octree until it can be added
		var count = 0; // Safety check against infinite/excessive growth

		while (!this.rootNode.add(obj, objBounds)) {
			count += 1;
			this.grow(objBounds.center - this.rootNode.center);

			if (count > 20) {
				trace("Aborted Add operation as it seemed to be going on forever (" + Std.string(count - 1) + ") attempts at growing the octree.");
				return;
			}

			this.count += 1;
		}
	}

	/** Remove an object. Makes the assumption that the object only exists once in the tree.
	 * @param obj Object to remove
	 * @return bool True if the object was removed successfully
	**/
	public function remove(obj: T) {
		var removed = this.rootNode.remove(obj);

		// See if we can shrink the octree down now that we've removed the item
		if (removed) {
			this.count -= 1;
			this.shrink();
		}

		return removed;
	}

	/** Check if the specified bounds intersect with anything in the tree. See also: get_colliding.
	 * @param checkBounds bounds to check
	 * @return bool True if there was a collision
	**/
	public function is_colliding(checkBounds): Bool {
		return this.rootNode.is_colliding(checkBounds);
	}

	/** Returns an array of objects that intersect with the specified bounds, if any. Otherwise returns an empty array. See also: is_colliding.
	 * @param checkBounds bounds to check
	 * @return table Objects that intersect with the specified bounds
	**/
	public function get_colliding(checkBounds): Array<T> {
		var results = [];
		this.rootNode.get_colliding(checkBounds, results);
		return results;
	}

	public function get_colliding_frustum(checkFrustum: Frustum): Array<T> {
		var results = [];
		this.rootNode.get_colliding_frustum(checkFrustum, results);
		return results;
	}

	/** Cast a ray through the node and its children
	 * @param ray Ray with a position and a direction
	 * @param func Function to execute on any objects within child nodes
	 * @return boolean True if an intersect detected
	**/
	public function cast_ray(ray, func) {
		return this.rootNode.cast_ray(ray, func, 1);
	}

	/** Grow the octree to fit in all objects.
	 * @param direction Direction to grow
	**/
	function grow(direction: Vec3) {
		var xDirection: Float = direction.x >= 0 ? 1 : -1;
		var yDirection: Float = direction.y >= 0 ? 1 : -1;
		var zDirection: Float = direction.z >= 0 ? 1 : -1;

		var oldRoot   = this.rootNode;
		var half      = this.rootNode.baseLength / 2;
		var newLength = this.rootNode.baseLength * 2;
		var newCenter = this.rootNode.center + new Vec3(xDirection * half, yDirection * half, zDirection * half);

		// Create a new, bigger octree root node
		this.rootNode = new Node(newLength, this.minSize, this.looseness, newCenter);

		// Create 7 new octree children to go with the old root as children of the new root
		var rootPos  = get_root_pos_index(xDirection, yDirection, zDirection);
		var children = [];

		for (i in 0...8) {
			if (i == rootPos) {
				children[i] = oldRoot;
			}
			else {
				xDirection  = i % 2 == 0 ? -1 : 1;
				yDirection  = i > 3 ? -1 : 1;
				zDirection = (i < 2 || (i > 3 && i < 6)) ? -1 : 1;
				children[i] = new Node(
					this.rootNode.baseLength,
					this.minSize,
					this.looseness,
					newCenter + new Vec3(xDirection * half, yDirection * half, zDirection * half)
				);
			}
		}

		// Attach the new children to the new root node
		this.rootNode.set_children(children);
	}

	/** Shrink the octree if possible, else leave it the same. **/
	function shrink() {
		this.rootNode = this.rootNode.shrink_if_possible(this.initialSize);
	}
}
