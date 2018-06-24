module rocl.status.item;

import
		std.meta,
		std.algorithm,

		perfontain,

		rocl.status,
		rocl.network,
		rocl.controls,

		utils.logger;


enum
{
	ITEM_INVENTORY,
	ITEM_STORAGE,
	ITEM_SHOP,
	ITEM_TRADING,
}

final class Item : RCounted
{
	this(ref in PkItemBuy p)
	{
		id = p.id;

		type = p.type;
		source = ITEM_SHOP;

		price = min(p.price, p.discountPrice);
	}

	this(ref in Pk0a09 p)
	{
		foreach(s; AliasSeq!(`id`, `type`, `amount`, `flags`, `attr`, `refine`, `cards`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}

		source = ITEM_TRADING;
	}

	this(ref in PkEquipItem p)
	{
		amount = 1;

		foreach(s; AliasSeq!(`equip`, `equip2`, `refine`, `expireTime`, `bound`, `look`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}

		createFrom(p);
	}

	this(ref in Pk0a0a p)
	{
		foreach(s; AliasSeq!(`amount`, `refine`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}

		createFrom(p);
	}

	this(ref in PkStackableItem p)
	{
		foreach(s; AliasSeq!(`amount`, `equip`, `expireTime`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}

		createFrom(p);
	}

	this(ref in Pk0a37 p)
	{
		foreach(s; AliasSeq!(`amount`, `equip`, `refine`, `expireTime`, `bound`, `look`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}

		createFrom(p);
	}

	~this()
	{
		onRemove(this);
	}

	const clone()
	{
		return new Item(this);
	}

	const drop()
	{
		ROnet.dropItem(idx, amount);
	}

	void reamount(ushort n)
	{
		assert(n);

		amount = n;
		onCountChanged(this);
	}

	const action()
	{
		if(equip)
		{
			if(equip2)
			{
				ROnet.unequip(idx);
			}
			else
			{
				ROnet.equip(idx, cast(ushort)equip);
			}
		}
		else
		{
			ROnet.useItem(idx, ROent.self.bl); // TODO: ARROWS
		}
	}

	void doEquip(uint loc)
	{
		if(loc)
		{
			equip2 = loc;
			onEquip(this);
		}
		else
		{
			onUnequip(this);
			equip2 = 0;
		}
	}

	const data()
	{
		return ROdb.itemOf(id);
	}

	ubyte tab() const
	{
		static immutable arr =
		[
			[ IT_HEALING, IT_USABLE, IT_CASH ],
			[ IT_ARMOR, IT_WEAPON, IT_PETARMOR, ],
		];

		auto n = cast(byte)arr.countUntil!(a => a.canFind(type));
		return n < 0 ? 2 : n;
	}

	uint
			equip,
			equip2,
			expireTime,

			price;

	short
			id,
			idx,
			amount,
			trading,

			bound,
			look;

	short[4] cards;

	byte
			type,
			attr,
			flags,
			refine,
			source;

	Signal!(void, Item)
							onEquip,
							onRemove,
							onUnequip,
							onCountChanged;
private:
	this(in Item m)
	{
		assert(!m.price);
		assert(!m.equip2);
		assert(!m.trading);

		foreach(s; AliasSeq!(`amount`, `equip`, `refine`, `expireTime`, `price`, `bound`, `look`, `attr`, `source`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))m.` ~ s ~ `;`);
		}

		createFrom(m);
	}

	void createFrom(T)(ref in T p)
	{
		foreach(s; AliasSeq!(`id`, `idx`, `type`, `flags`, `cards`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}
	}
}
