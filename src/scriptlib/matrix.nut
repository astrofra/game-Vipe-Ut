/*
	nEngine	SQUIRREL binding API.
	Copyright 2005~2008 Emmanuel Julien.
*/

class		Matrix3
{
	constructor(...)
	{
		local	vargc = vargv.len();
		assert((vargc == 0) || (vargc == 3) || (vargc == 9));

		if	(vargc == 3)
		{
			for (local i = 0; i < 3; ++i)
				SetRow(i, vargv[i]);
		}
		else	if	(vargc == 9)
		{
			m00 = vargv[0];	m10 = vargv[1];	m20 = vargv[2];
			m01 = vargv[3];	m11 = vargv[4];	m21 = vargv[5];
			m02 = vargv[6];	m12 = vargv[7];	m22 = vargv[8];
		}
	}

	// Set the 'nth' row of this matrix from a vector.
	function	SetRow(nth, v)
	{
		assert((nth >= 0) && (nth <= 2));
		switch	(nth)
		{
			case 0:		m00 = v.x; m10 = v.y; m20 = v.z;	break;
			case 1:		m01 = v.x; m11 = v.y; m21 = v.z;	break;
			case 2:		m02 = v.x; m12 = v.y; m22 = v.z;	break;
		}
	}

	// Returns the 'nth' row of this matrix as a vector.
	function	GetRow(nth)
	{
		assert((nth >= 0) && (nth <= 2));
		switch	(nth)
		{
			case 0:		return Vector(m00, m10, m20);		break;
			case 1:		return Vector(m01, m11, m21);		break;
			case 2:		return Vector(m02, m12, m22);		break;
		}
	}

	// Returns the 'nth' column of this matrix as a vector.
	function	GetColumn(nth)
	{
		assert((nth >= 0) && (nth <= 2));
		switch	(nth)
		{
			case 0:		return Vector(m00, m01, m02);		break;
			case 1:		return Vector(m10, m11, m12);		break;
			case 2:		return Vector(m20, m21, m22);		break;
		}
	}

	function	_mul(b)
	{
		return Matrix3
						(
							m00 * b.m00 + m01 * b.m10 + m02 * b.m20,
							m10 * b.m00 + m11 * b.m10 + m12 * b.m20,
							m20 * b.m00 + m21 * b.m10 + m22 * b.m20,
							m00 * b.m01 + m01 * b.m11 + m02 * b.m21,
							m10 * b.m01 + m11 * b.m11 + m12 * b.m21,
							m20 * b.m01 + m21 * b.m11 + m22 * b.m21,
							m00 * b.m02 + m01 * b.m12 + m02 * b.m22,
							m10 * b.m02 + m11 * b.m12 + m12 * b.m22,
							m20 * b.m02 + m21 * b.m12 + m22 * b.m22
						);
	}

	m00 = 1.0; m10 = 0.0; m20 = 0.0;
	m01 = 0.0; m11 = 1.0; m21 = 0.0;
	m02 = 0.0; m12 = 0.0; m22 = 1.0;
}

// Returns a rotation matrix around the X axis.
function	RotationMatrixX(a)
{
	return Matrix3(
						1.0, 0.0, 0.0,
						0.0, cos(a), sin(a),
						0.0, -sin(a), cos(a)
					);
}
// Returns a rotation matrix around the Y axis.
function	RotationMatrixY(a)
{
	return Matrix3(
						cos(a), 0.0, -sin(a),
						0.0, 1.0, 0.0,
						sin(a), 0.0, cos(a)
					);
}
// Returns a rotation matrix around the Z axis.
function	RotationMatrixZ(a)
{
	return Matrix3(
						cos(a), sin(a), 0.0,
						-sin(a), cos(a), 0.0,
						0.0, 0.0, 1.0
					);
}

class Matrix4
{
	constructor(...)
	{
		local	vargc = vargv.len();
		assert((vargc == 0) || (vargc == 4) || (vargc == 16));

		if	(vargc == 4)
		{
			for (local i = 0; i < 4; ++i)
				SetRow(i, vargv[i]);
		}
		else	if	(vargc == 16)
		{
			m00 = vargv[0];	m10 = vargv[1];	m20 = vargv[2]; m30 = vargv[3];
			m01 = vargv[4];	m11 = vargv[5];	m21 = vargv[6]; m31 = vargv[7];
			m02 = vargv[8];	m12 = vargv[9];	m22 = vargv[10]; m32 = vargv[11];
			m03 = vargv[12]; m13 = vargv[13]; m23 = vargv[14]; m33 = vargv[15];
		}
	}

	// Set the 'nth' row of this matrix from a vector.
	function	SetRow(nth, v)
	{
		assert((nth >= 0) && (nth <= 3));
		switch	(nth)
		{
			case 0:		m00 = v.x; m10 = v.y; m20 = v.z;	break;
			case 1:		m01 = v.x; m11 = v.y; m21 = v.z;	break;
			case 2:		m02 = v.x; m12 = v.y; m22 = v.z;	break;
			case 3:		m03 = v.x; m13 = v.y; m23 = v.z;	break;
		}
	}

	// Returns the 'nth' row of this matrix as a vector.
	function	GetRow(nth)
	{
		assert((nth >= 0) && (nth <= 3));
		switch	(nth)
		{
			case 0:		return Vector(m00, m10, m20);		break;
			case 1:		return Vector(m01, m11, m21);		break;
			case 2:		return Vector(m02, m12, m22);		break;
			case 3:		return Vector(m03, m13, m23);		break;
		}
	}

	// Returns the 'nth' column of this matrix as a vector.
	function	GetColumn(nth)
	{
		assert((nth >= 0) && (nth <= 3));
		switch	(nth)
		{
			case 0:		return Vector(m00, m01, m02);		break;
			case 1:		return Vector(m10, m11, m12);		break;
			case 2:		return Vector(m20, m21, m22);		break;
			case 3:		return Vector(m30, m31, m32);		break;
		}
	}

	// Matrix3 from matrix4.
	function	AsMatrix3()
	{
		return Matrix3	(
							m00, m10, m20,
							m01, m11, m21,
							m02, m12, m22
						);
	}
	// Matrix3 from matrix4.
	function	AsRotationScale()
	{
		return Matrix4	(
							m00, m10, m20, 0.0,
							m01, m11, m21, 0.0,
							m02, m12, m22, 0.0,
							0.0, 0.0, 0.0, 1.0
						);
	}

	function	_mul(b)
	{
		return Matrix4
						(
							m00 * b.m00 + m01 * b.m10 + m02 * b.m20 + m03 * b.m30,
							m10 * b.m00 + m11 * b.m10 + m12 * b.m20 + m13 * b.m30,
							m20 * b.m00 + m21 * b.m10 + m22 * b.m20 + m23 * b.m30,
							m30 * b.m00 + m31 * b.m10 + m32 * b.m20 + m33 * b.m30,
							m00 * b.m01 + m01 * b.m11 + m02 * b.m21 + m03 * b.m31,
							m10 * b.m01 + m11 * b.m11 + m12 * b.m21 + m13 * b.m31,
							m20 * b.m01 + m21 * b.m11 + m22 * b.m21 + m23 * b.m31,
							m30 * b.m01 + m31 * b.m11 + m32 * b.m21 + m33 * b.m31,
							m00 * b.m02 + m01 * b.m12 + m02 * b.m22 + m03 * b.m32,
							m10 * b.m02 + m11 * b.m12 + m12 * b.m22 + m13 * b.m32,
							m20 * b.m02 + m21 * b.m12 + m22 * b.m22 + m23 * b.m32,
							m30 * b.m02 + m31 * b.m12 + m32 * b.m22 + m33 * b.m32,
							m00 * b.m03 + m01 * b.m13 + m02 * b.m23 + m03 * b.m33,
							m10 * b.m03 + m11 * b.m13 + m12 * b.m23 + m13 * b.m33,
							m20 * b.m03 + m21 * b.m13 + m22 * b.m23 + m23 * b.m33,
							m30 * b.m03 + m31 * b.m13 + m32 * b.m23 + m33 * b.m33
						);
	}

	m00 = 1.0; m10 = 0.0; m20 = 0.0; m30 = 0.0;
	m01 = 0.0; m11 = 1.0; m21 = 0.0; m31 = 0.0;
	m02 = 0.0; m12 = 0.0; m22 = 1.0; m32 = 0.0;
	m03 = 0.0; m13 = 0.0; m23 = 0.0; m33 = 1.0;
}

// Offset matrix.
function	OffsetMatrix(o)
{
	local	m = Matrix4();
	m.SetRow(3, o);
	return m;
}
