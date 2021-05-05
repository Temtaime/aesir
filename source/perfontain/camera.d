module perfontain.camera;
import std.stdio, std.array, std.algorithm, perfontain, perfontain.misc,
	perfontain.math.matrix, perfontain.signals, perfontain.misc.rc;

abstract class CameraBase : RCounted
{
	@property
	{
		bool cursor()
		{
			return true;
		}

		Vector3 pos()
		{
			return _pos;
		}

		void pos( /*ref */  in Vector3)
		{
		}
	}

	auto planeForZ(float z)
	{
		auto fov = 45;
		auto aspect = float(PE.window._size.x) / PE.window._size.y;

		auto M_PI = 3.1415;
		import std.math;

		float halfAngle = 0.5f * M_PI * fov / 180.0f;
		float f = 1 / cast(float)tan(halfAngle);
		auto base = Vector3(z * aspect / f, z / f, z);

		Vector3[4] p;

		auto dd = Vector3(-0.707107, 0.000000, -0.707107);

		auto sideDir = Vector3(0.000000, 1.000000, 0.000000);
		auto upDir = Vector3(0.707107, 0.000000, -0.707107);

		p[0] = pos + dd * base.z + sideDir * base.x + upDir * base.y;
		p[1] = pos + dd * base.z + sideDir * base.x - upDir * base.y; //Vector3D (  base.x, -base.y, base.z );
		p[2] = pos + dd * base.z - sideDir * base.x - upDir * base.y; //Vector3D ( -base.x, -base.y, base.z );
		p[3] = pos + dd * base.z - sideDir * base.x + upDir * base.y; //Vector3D ( -base.x,  base.y, base.z );

		return p;
	}

	//package:
	void recalcUDir()
	{
		_udir = direction(Vector2(_dir.x, -_dir.z));
	}

	void recalcInversed()
	{
		_inversed = Matrix4(Matrix3(_view).transposed);
	}

	mixin publicProperty!(Matrix4, `view`);
	Matrix4 _inversed;

	//mixin publicProperty!(Vector3, `pos`);

	Vector3 _dir, _pos;
	ubyte _udir;
}

final:

class CameraFPS : CameraBase
{
	this(Vector3 p, Vector3 t)
	{
		_pos = p;
		_dir = t - p;

		_tb = PE.onButton.add(&onButton);
		_tp = PE.onTickDelta.add(&onTick);

		recalcRes;
	}

	@property
	{
		//override bool cursor() { return fixed; }
	}

	immutable moveSpeed = 0.1f, rotateSpeed = 0.3f;

	bool fixed;
package:
	bool onButton(ubyte k, bool st)
	{
		if (fixed)
		{
			return false;
		}

		if (k == MOUSE_LEFT)
		{
			if (st)
			{
				_mp = PE.onMoveDelta.add(&onMove);
			}
			else
			{
				_mp = null;
			}
		}

		return true;
	}

	void onMove(Vector2s d)
	{
		auto pitch = Quaternion.fromAxis(AXIS_Y ^ _dir, d.y * rotateSpeed * TO_RAD);
		auto heading = Quaternion.fromAxis(AXIS_Y, d.x * rotateSpeed * -TO_RAD);

		_dir *= heading * pitch;

		recalcUDir;
		recalcRes;
	}

	void onTick(uint d)
	{
		if (fixed || !_mp)
		{
			return;
		}

		bool f = PEwindow.keys.canFind(SDLK_UP);
		bool b = PEwindow.keys.canFind(SDLK_DOWN);
		bool l = PEwindow.keys.canFind(SDLK_LEFT);
		bool r = PEwindow.keys.canFind(SDLK_RIGHT), u;

		if (f)
		{
			u = true;
			_pos += _dir * d * moveSpeed;
		}

		if (b)
		{
			u = true;
			_pos -= _dir * d * moveSpeed;
		}

		if (l)
		{
			u = true;
			_pos -= _dir ^ AXIS_Y * d * moveSpeed;
		}

		if (r)
		{
			u = true;
			_pos += _dir ^ AXIS_Y * d * moveSpeed;
		}

		if (u)
		{
			recalcRes;
		}
	}

	void recalcRes()
	{
		_view = Matrix4.lookAt(_pos, _dir.normalize);
		recalcInversed;

		//log(`%s %s`, _pos, _dir);
	}

	RC!ConnectionPoint _tp, _mp, _tb;
}

class CameraRO : CameraBase // TODO: NAME ???
{
	this(Vector3 p)
	{
		_t = p;

		_dir = -AXIS_Y * Matrix4.rotate(0, 0, 25 * TO_RAD);
		_dir *= Matrix4.rotate(0, 90 * TO_RAD, 0);

		_wheel = PE.onWheel.add(&onWheel);
		_button = PE.onButton.add(&onButton);

		recalcRes;
	}

	@property
	{
		//override Vector3 pos() { return _t; }
		override void pos(in Vector3 p)
		{
			_t = p;
			recalcRes;
		}
	}

	immutable rotateSpeed = 0.4f;

package:
	enum ZOOM_MAX = 10000;

	bool onButton(ubyte k, bool st)
	{
		if (k == MOUSE_RIGHT)
		{
			if (st)
			{
				_x = PE.window.mpos.x;
				_move = PE.onMove.add(&onMove);
			}
			else
			{
				_move = null;
			}

			return true;
		}

		return false;
	}

	void onMove(Vector2s d)
	{
		_dir *= Matrix4.rotate(0, -(d.x - _x) * rotateSpeed * TO_RAD, 0);
		_x = d.x;

		recalcRes;
		recalcUDir;
	}

	bool onWheel(Vector2s sc)
	{
		_zoom = clamp(_zoom - sc.y * 2, 15, ZOOM_MAX);
		recalcRes;

		return true;
	}

	void recalcRes()
	{
		_view = Matrix4.lookAt(_pos = _t - _dir.normalize * _zoom, _dir);
		recalcInversed;
	}

	RC!ConnectionPoint _move, _wheel, _button;
	Vector3 _t;
	ushort _x;

	float _zoom = 85;
}
