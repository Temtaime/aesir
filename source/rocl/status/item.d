module rocl.status.item;

import
		std.meta,
		std.algorithm,

		perfontain,

		rocl.status,
		rocl.network,
		rocl.controls,

		tt.logger;


enum
{
	ITEM_INVENTORY,
	ITEM_STORAGE,
	ITEM_SHOP,
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

		byte n = cast(byte)arr.countUntil!(a => a.canFind(type));
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

			card,
			card2,
			card3,
			card4,

			bound,
			look;

	byte
			type,
			flags,
			refine,
			source;

	Signal!(void, Item)
							onEquip,
							onRemove,
							onUnequip,
							onCountChanged;
private:
	void createFrom(T)(ref in T p)
	{
		foreach(s; AliasSeq!(`id`, `idx`, `type`, `flags`))
		{
			mixin(s ~ `= cast(typeof(` ~ s ~ `))p.` ~ s ~ `;`);
		}

		card = p.cards.c1;
		card2 = p.cards.c2;
		card3 = p.cards.c3;
		card4 = p.cards.c4;
	}
}
