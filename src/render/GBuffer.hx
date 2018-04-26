package render;

import love.graphics.Canvas;

typedef GBuffer = {
	layers: Array<Canvas>,
	depth: Canvas,
	out1: Canvas,
	out2: Canvas
}
