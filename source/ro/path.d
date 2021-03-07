module ro.path;
import std.math, std.array, std.algorithm, std.exception,
	perfontain.math.matrix, ro.map.gat, utile.except;

enum
{
	MAX_HEAP = 150,
	MAX_WALKPATH = 32
}

struct PathFinder
{
	auto search(in Vector2s p, in Vector2s t)
	{
		int i, j;
		int e, f, len;

		auto res = searchLong(p, t, Cell.Walkable);
		if (res.length)
			return res;

		res ~= p;
		i = cast(short)calcIndex(p);

		_arr[i].p = p;
		_arr[i].cost = cast(short)calcCost(i, t);

		_heap[0] = 0;
		pushPath(i);

		short rp;
		size -= Vector2s(1);

		while (true)
		{
			// clean up variables
			e = 0;
			f = 0;

			ubyte[4] dc;
			rp = cast(short)popPath;

			// no path found
			if (rp < 0)
				return null;

			auto x = _arr[rp].p.x;
			auto y = _arr[rp].p.y;
			auto dist = cast(short)(_arr[rp].dist + 10);
			auto cost = _arr[rp].cost;

			if (x == t.x && y == t.y)
				break;

			if (y < size.y && typeOf(x, y + 1) & Cell.Walkable)
			{
				dc[0] = (y >= t.y ? 20 : 0);
				f |= 1;
				e += addPath(Vector2s(x, y + 1), dist, rp, cast(short)(cost + dc[0]));
			}

			if (x > 0 && typeOf(x - 1, y) & Cell.Walkable)
			{
				dc[1] = (x <= t.x ? 20 : 0);
				f |= 2;
				e += addPath(Vector2s(x - 1, y), dist, rp, cast(short)(cost + dc[1]));
			}

			if (y > 0 && typeOf(x, y - 1) & Cell.Walkable)
			{
				dc[2] = (y <= t.y ? 20 : 0);
				f |= 4;
				e += addPath(Vector2s(x, y - 1), dist, rp, cast(short)(cost + dc[2]));
			}

			if (x < size.x && typeOf(x + 1, y) & Cell.Walkable)
			{
				dc[3] = (x >= t.x ? 20 : 0);
				f |= 8;
				e += addPath(Vector2s(x + 1, y), dist, rp, cast(short)(cost + dc[3]));
			}

			// diagonals
			if ((f & (2 + 1)) == 2 + 1 && typeOf(x - 1, y + 1) & Cell.Walkable)
				e += addPath(Vector2s(x - 1, y + 1), cast(short)(dist + 4), rp,
						cast(short)(cost + dc[1] + dc[0] - 6));

			if ((f & (2 + 4)) == 2 + 4 && typeOf(x - 1, y - 1) & Cell.Walkable)
				e += addPath(Vector2s(x - 1, y - 1), cast(short)(dist + 4), rp,
						cast(short)(cost + dc[1] + dc[2] - 6));

			if ((f & (8 + 4)) == 8 + 4 && typeOf(x + 1, y - 1) & Cell.Walkable)
				e += addPath(Vector2s(x + 1, y - 1), cast(short)(dist + 4), rp,
						cast(short)(cost + dc[3] + dc[2] - 6));

			if ((f & (8 + 1)) == 8 + 1 && typeOf(x + 1, y + 1) & Cell.Walkable)
				e += addPath(Vector2s(x + 1, y + 1), cast(short)(dist + 4), rp,
						cast(short)(cost + dc[3] + dc[0] - 6));

			_arr[rp].flag = true;

			// too much... ending
			if (e || _heap[0] >= MAX_HEAP - 5)
				return null;
		}

		// reorganize Path
		for (len = 0, i = rp; len < 100 && i != calcIndex(p); i = _arr[i].before, len++)
		{
		}

		for (i = rp, j = len - 1; j >= 0; i = _arr[i].before, j--)
			res ~= _arr[i].p;

		res[1 .. $].reverse();
		return res; // len+1;
	}

	Vector2s size;
	ubyte delegate(uint, uint) typeOf;
private:
	auto searchLong(Vector2s p, in Vector2s t, ubyte type)
	{
		Vector2s[] res;

		auto d = Vector2s(clamp(t.x - p.x, -1, 1), clamp(t.y - p.y, -1, 1));

		res ~= p;

		while (res.length < MAX_WALKPATH)
		{
			p += d;
			res ~= p;

			if (p.x == t.x)
				d.x = 0;
			if (p.y == t.y)
				d.y = 0;

			if (!d.x && !d.y)
				return res;

			if (!(typeOf(p.x, p.y) & type))
				break;
		}

		return null;
	}

	void pushPath(uint idx)
	{
		auto h = _heap[0]++;

		for (auto i = (h - 1) / 2; h > 0 && _arr[idx].cost < _arr[_heap[i + 1]].cost;
				i = (h - 1) / 2)
		{
			_heap[h + 1] = _heap[i + 1];
			h = i;
		}

		_heap[h + 1] = idx;
	}

	void updatePath(uint idx)
	{
		uint h;
		for (; h < _heap.front && _heap[h + 1] != idx; ++h)
		{
		}

		h != _heap.front || throwError(`error updating path`);
		auto cost = _arr[idx].cost;

		for (auto i = (h - 1) / 2; h > 0 && cost < _arr[_heap[i + 1]].cost; i = (h - 1) / 2)
		{
			_heap[h + 1] = _heap[i + 1];
			h = i;
		}

		_heap[h + 1] = idx;
	}

	int popPath()
	{
		if (_heap.front <= 0)
			return -1;

		auto ret = _heap[1], last = _heap[_heap.front--];

		auto cost = _arr[last].cost;
		uint k = 2, h;

		for (; k < _heap.front; k = k * 2 + 2)
		{
			if (_arr[_heap[k + 1]].cost > _arr[_heap[k]].cost)
				k--;

			_heap[h + 1] = _heap[k + 1];
			h = k;
		}

		if (k == _heap.front)
		{
			_heap[h + 1] = _heap[k];
			h = k - 1;
		}

		for (auto i = (h - 1) / 2; h > 0 && _arr[_heap[i + 1]].cost > cost; i = (h - 1) / 2)
		{
			_heap[h + 1] = _heap[i + 1];
			h = i;
		}

		_heap[h + 1] = last;
		return ret;
	}

	bool addPath(in Vector2s p, short dist, short before, short cost)
	{
		auto i = calcIndex(p);

		if (_arr[i].p == p)
		{
			if (_arr[i].dist > dist)
			{
				_arr[i].dist = dist;
				_arr[i].before = before;
				_arr[i].cost = cost;

				if (_arr[i].flag)
					pushPath(i);
				else
					updatePath(i);

				_arr[i].flag = false;
			}

			return false;
		}

		if (_arr[i].p.x || _arr[i].p.y)
			return true;

		_arr[i].p = p;
		_arr[i].dist = dist;
		_arr[i].before = before;
		_arr[i].cost = cost;
		_arr[i].flag = false;

		pushPath(i);
		return false;
	}

	static calcIndex(in Vector2s p)
	{
		return (p.x + p.y * MAX_WALKPATH) & (MAX_WALKPATH * MAX_WALKPATH - 1);
	}

	auto calcCost(uint idx, Vector2s p)
	{
		p -= _arr[idx].p;
		return (int(p.x).abs + int(p.y).abs) * 10 + _arr[idx].dist;
	}

	struct S
	{
		Vector2s p;
		short dist, cost, before;
		bool flag;
	}

	S[MAX_WALKPATH * MAX_WALKPATH] _arr;
	int[MAX_HEAP] _heap;
}
