package timer;

@:enum
abstract TweenMethod(String) {
	var Quad = "quad";
	var InQuad = "in-quad";
	var OutQuad = "out-quad";
	var InOutQuad = "in-out-quad";
	var OutInQuad = "out-in-quad";

	var Cubic = "cubic";
	var InCubic = "in-cubic";
	var OutCubic = "out-cubic";
	var InOutcubic = "in-out-cubic";
	var OutIncubic = "out-in-cubic";

	var Linear = "linear";
	var InLinear = "in-linear";
	var OutLinear = "out-linear";
	var InOutLinear = "in-out-linear";
	var OutInLinear = "out-in-linear";

	var Back = "back";
	var InBack = "in-back";
	var OutBack = "out-back";
	var InOutBack = "in-out-back";
	var OutInBack = "out-in-back";
}
