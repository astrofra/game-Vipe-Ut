/*
	nEngine	SQUIRREL binding API.
	Copyright 2005~2008 Emmanuel Julien.
*/


class 	Vector
{
	x = 0.0
	y = 0.0
	z = 0.0
	w = 1.0

	function	Set(_x = 0.0, _y = 0.0, _z = 0.0)
	{	x = _x; y = _y; z = _z;	}

	function	AddReal(k)		{	return Vector(x + k, y + k, z + k)		}
	function	SubReal(k)		{	return Vector(x - k, y - k, z - k)		}
	function	MulReal(k)		{	return Vector(x * k, y * k, z * k)		}
	function	DivReal(k)		{	local i = 1.0 / k; return Vector(x * i, y * i, z * i)		}
	function	Scale(k)		{	return Vector(x * k, y * k, z * k)		}

	function	Dot(b)			{	return x * b.x + y * b.y + z * b.z	}
	function	Cross(b)		{	return Vector(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x)	}
	function	Len2()			{	return x * x + y * y + z * z	}
	function	Len()
	{
		local	l = Len2()
		return l ? sqrt(l) : 0.0
	}

	function    Dist(b)         {	return (b - this).Len()	}

	function	Max(b)			{	return Vector(x > b.x ? x : b.x, y > b.y ? y : b.y, z > b.z ? z : b.z)	}
	function	Min(b)			{	return Vector(x < b.x ? x : b.x, y < b.y ? y : b.y, z < b.z ? z : b.z)	}

	function	Lerp(k, b)
	{
		local	ik = 1.0 - k
		return Vector(x * k + b.x * ik, y * k + b.y * ik, z * k + b.z * ik, w * k + b.w * ik)
	}

	function	AngleWithVector(b)
	{	return acos(Dot(b))	}

	function	Normalize(length = 1.0)
	{
		local	k = Len()
		k = (k < 0.000001) ? 0.0 : length / k
		return Vector(x * k, y * k, z * k)
	}

	function	ApplyMatrix(m)
	{
		return Vector	(
							x * m.m00 + y * m.m01 + z * m.m02 + m.m03,
							x * m.m10 + y * m.m11 + z * m.m12 + m.m13,
							x * m.m20 + y * m.m21 + z * m.m22 + m.m23
						)
	}
	function	ApplyRotationMatrix(m)
	{
		return Vector	(
							x * m.m00 + y * m.m01 + z * m.m02,
							x * m.m10 + y * m.m11 + z * m.m12,
							x * m.m20 + y * m.m21 + z * m.m22
						)
	}

	function	Reverse()		{	return Vector(-x, -y, -z)	}

	function	_add(v)
	{	return Vector(x + v.x, y + v.y, z + v.z)	}
	function	_sub(v)
	{	return Vector(x - v.x, y - v.y, z - v.z)	}
	function	_mul(v)
	{	return Vector(x * v.x, y * v.y, z * v.z)	}
	function	_div(v)
	{	return Vector(x / v.x, y / v.y, z / v.z)	}
	function	_unm(v)
	{	return Vector(-x, -y, -z)	}

	function	Clamp(min, max)
	{	return Vector(::Clamp(x, min, max), ::Clamp(y, min, max), ::Clamp(z, min, max))	}
	function	Clamp3d(vmin, vmax)
	{	return Vector(::Clamp(x, vmin.x, vmax.x), ::Clamp(y, vmin.y, vmax.y), ::Clamp(z, vmin.z, vmax.z))	}
	function	ClampMagnitude(mag)
	{
		local 	l = Len2()
		if	(l < (mag * mag))
			return this
		if	(l < 0.000001)
			return this
		l = sqrt(l)
		return this.MulReal(mag / l)
	}

	function	Randomize(a, b)
	{	return Vector(Rand(a, b), Rand(a, b), Rand(a, b))	}

	function	ToRGBHex()
	{	return ((x.tointeger() & 255) << 24) + ((y.tointeger() & 255) << 16) + ((z.tointeger() & 255) << 8) + (w.tointeger() & 255)	}

	function	Print()
	{	::print("X = " + x + ", Y = " + y + ", Z = " + z + ".\n")	}

	constructor(_x = 0.0, _y = 0.0, _z = 0.0, _w = 1.0)
	{
		x = _x
		y = _y
		z = _z
		w = _w
	}
}
