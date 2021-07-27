module perfontain.math;

import std.math, std.algorithm, perfontain.math.matrix;

auto unproject(ushort x, ushort y, float z, in Matrix4 vp, Vector2s viewport)
{
	auto v = Vector3(x, y, z) * 2;

	v.x /= viewport.x;
	v.y /= viewport.y;

	v -= Vector3(1);
	return v * vp.inversed;
}

auto project(Vector3 v, in Matrix4 vp, Vector2s viewport)
{
	v *= vp;

	v.y *= -1;
	v += Vector3(1);

	v.x *= viewport.x;
	v.y *= viewport.y;

	return Vector2s(v.xy / 2);
}

auto project(Vector3 v, Vector2s viewport)
{
	v.y *= -1;
	v += Vector3(1);

	v.x *= viewport.x;
	v.y *= viewport.y;

	return v / 2;
}

float rayTriangleDistance(in Vector3 rayPos, in Vector3 rayDir, in Vector3 v1, in Vector3 v2, in Vector3 v3)
{
	// compute vectors along two edges of the triangle
	auto edge1 = v2 - v1;
	auto edge2 = v3 - v1;

	// compute the determinant
	auto directionCrossEdge2 = rayDir ^ edge2;

	float det = directionCrossEdge2 * edge1;

	// if the ray and triangle are parallel, there is no collision
	if (valueEqual(det, 0))
		return -1;

	float inverseDet = 1 / det;

	// calculate the U parameter of the intersection point
	auto distanceVector = rayPos - v1;

	float triangleU = directionCrossEdge2 * distanceVector;
	triangleU *= inverseDet;

	// mke sure the U is inside the triangle
	if (triangleU < 0 || triangleU > 1)
		return -1;

	// calculate the V parameter of the intersection point
	auto distanceCrossEdge1 = distanceVector ^ edge1;

	float triangleV = rayDir * distanceCrossEdge1;
	triangleV *= inverseDet;

	// make sure the V is inside the triangle
	if (triangleV < 0 || triangleU + triangleV > 1)
		return -1;

	// get the distance to the face from our ray origin
	float rayDistance = distanceCrossEdge1 * edge2;
	rayDistance *= inverseDet;

	// is the triangle behind us?
	return rayDistance < 0 ? -1 : rayDistance;
}

auto planeIntersection(in Vector3 p1, in Vector3 p2, in Vector3 p3, in Vector3 x, in Vector3 dir)
{
	Matrix4 m1, m2;

	m1[0] = Vector4(1, p1);
	m1[1] = Vector4(1, p2);
	m1[2] = Vector4(1, p3);
	m1[3] = Vector4(1, x);

	m2[0] = Vector4(1, p1);
	m2[1] = Vector4(1, p2);
	m2[2] = Vector4(1, p3);
	m2[3] = Vector4(0, dir);

	return -m1.det / m2.det;
}

auto triangleArea(in Vector3 a, in Vector3 b, in Vector3 c)
{
	Matrix3 m;

	m[0] = 1.Vector3;
	m[1] = b - a;
	m[2] = c - a;

	return m.det / 2;
}

auto calcNormal(in Vector3 a, in Vector3 b, in Vector3 c)
{
	return (b - c) ^ (a - c);
}

auto angleTo(in Vector3 a, in Vector3 b)
{
	return acos(a * b / (a.length * b.length));
}

bool arePointsOnOneLine(ref Vector3 a, ref Vector3 b, ref Vector3 c)
{
	return valueEqual(calcNormal(a, b, c).length, 0);
}
