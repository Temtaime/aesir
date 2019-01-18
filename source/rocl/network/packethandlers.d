module rocl.network.packethandlers;

/*
Vector2s[3] getPos(ubyte[6] p)
{
	Vector2s[3] ret;

	ret[0].x = (p[0] & 0xFF) << 2 | p[1] >> 6;
	ret[0].y = (p[1] & 0x3F) << 4 | p[2] >> 4;

	ret[1].x = (p[2] & 0x0F) << 6 | p[3] >> 2;
	ret[1].y = (p[3] & 0x03) << 8 | p[4] >> 0;

	ret[2].x = (p[5] & 0xF0) >> 4;
	ret[2].y = (p[5] & 0x0F) >> 0;

	return ret;
}
*/

mixin template PacketHandlers()
{
	/// ====================================== OUTCOMING ======================================
	void toChat(string s)
	{
		s = format(`%s : %s`, ROent.self.name, s);

		send!Pk00f3(s ~ '\0');
	}

	void createChar(string name, ubyte color, ubyte style)
	{
		auto slot = ushort.max
								.iota
								.filter!(a => !st.chars.canFind!(b => b.slot == a))
								.front;

		send!Pk0a39(name, slot, color, style, 0, 0, st.gender);
	}

	void setHotkey(uint idx, in PkHotkey h)
	{
		send!Pk02ba(cast(ushort)idx, h);
	}

	void pickUp(uint id)
	{
		send!Pk0964(id);
	}

	void dropItem(ushort idx, ushort cnt)
	{
		send!Pk093b(idx, cnt);
	}

	void useItem(ushort idx, uint bl)
	{
		send!Pk0439(idx, bl);
	}

	void unequip(ushort idx)
	{
		send!Pk00ab(idx);
	}

	void equip(ushort idx, ushort pos)
	{
		send!Pk00a9(idx, pos);
	}

	void statsUp(ushort id)
	{
		send!Pk00bb(id, 1);
	}

	void upSkill(ushort id)
	{
		send!Pk0112(id);
	}

	void useSkill(ubyte lvl, ushort id, uint bl)
	{
		send!Pk0815(lvl, id, bl);
	}

	void useSkill(ubyte lvl, ushort id, Vector2s p)
	{
		send!Pk0817(lvl, id, p.x, p.y);
	}

	void storeGet(ushort idx, ushort cnt)
	{
		send!Pk088c(idx, cnt);
	}

	void storePut(ushort idx, ushort cnt)
	{
		send!Pk08aa(idx, cnt);
	}

	void storeClose()
	{
		send!Pk0193;
	}

	void shopBuy(PkToBuy[] arr)
	{
		send!Pk00c8(arr);
	}

	void shopSell(PkToSell[] arr)
	{
		send!Pk00c9(arr);
	}

	void shopType(uint s, ubyte t)
	{
		send!Pk00c5(s, t);
	}

	void talkNpc(uint bl)
	{
		send!Pk0090(bl, 1);
	}

	void attackMob(uint bl)
	{
		send!Pk0437(bl, 7);
	}

	void moveTo(RoPos p)
	{
		send!Pk08a8(p);
	}

	void npcNext(uint npc)
	{
		send!Pk00b9(npc);
	}

	void npcSelect(uint npc, int idx) // TODO: TYPES
	{
		send!Pk00b8(npc, idx);
	}

	void npcClose(uint npc)
	{
		send!Pk0146(npc);
	}

	// TRADING
	void requestTrade(uint bl)
	{
		send!Pk00e4(bl);
	}

	void replyTrade(ubyte r)
	{
		send!Pk00e6(r);
	}

	void tradeItem(ushort idx, uint cnt)
	{
		send!Pk00e8(idx, cnt);
	}

	void tradeAction(byte act)
	{
		final switch(act)
		{
		case -1:
			send!Pk00ed;
			break;
		case 0:
			send!Pk00eb;
			break;
		case 1:
			send!Pk00ef;
		}
	}

	private
	{
		void onTradeItem(Pk0a09 p)
		{
			if(p.id)
			{
				RO.gui.trading.itemsDst.add(new Item(p));
			}
			else
			{
				RO.gui.trading.zeny(p.amount);
			}
		}

		void onTradeAdd(Pk00ea p)
		{
			if(!p.index)
			{
				return; // TODO: ZENY CHECK
			}

			if(auto e = RO.status.items.getIdx(p.index))
			{
				if(auto t = e.trading)
				{
					e.trading = 0;

					if(p.result) // TODO LOG
					{}
					else
					{
						auto d = cast(short)(e.amount - t);

						{
							auto c = e.clone;

							c.amount = t;
							c.source = ITEM_TRADING;

							RO.gui.trading.itemsSrc.add(c);
						}

						if(d)
						{
							e.reamount(d);
							e.trading = 0;
						}
						else
						{
							RO.status.items.remove(e);
						}
					}
				}
			}
		}

		void onTradeLock(Pk00ec p)
		{
			RO.gui.trading.lock(!p.who);
		}

		void onTradeCancel(Pk00ee p)
		{
			RO.gui.removeTrading;
		}

		void onTradeDone(Pk00f0 p)
		{
			RO.gui.removeTrading;
		}

		void onTradeReply(Pk01f5 p)
		{
			if(p.result == 3)
			{
				RO.gui.createTrading;
			}
		}

		void onTradeRequested(Pk01f4 p)
		{
			auto e = new WinInfo(format(MSG_DEAL_REQUEST, p.nick.charsToString, p.baselvl), true);

			e.ok.onClick =
			{
				replyTrade(3);
				e.deattach;
			};

			e.cancel.onClick =
			{
				replyTrade(4);
				e.deattach;
			};
		}
	}

	/// ====================================== INCOMING ======================================
	void onLoginOk(Pk0ac4 p)
	{
		foreach(ref s; p.servers)
		{
			auto addr = new InternetAddress(s.ip.bswap, s.port);
			auto name = s.name.charsToString;

			connect(addr);
			_flags |= M_ACC_ID;

			st.accountId = p.accountId;
			st.authCode = p.authCode;
			st.gender = !!p.gender;

			send!Pk0065(st.accountId, st.authCode, p.loginId, CLIENT_TYPE, st.gender);
		}
	}

	void onCharCreated(Pk006d p)
	{
		RO.gui.creation.onDone(p.data);
	}

	void onCreationError(Pk006e p)
	{
		RO.gui.creation.onError(p.code);
	}

	/// ====================================== NPC SHOP ======================================
	void onShopType(Pk00c4 p)
	{
		RO.gui.createShop(p.shopId);
	}

	void onItemsBuy(Pk00c6 p)
	{
		RO.gui.shop.make(p.items);
	}

	void onItemsSell(Pk00c7 p)
	{
		RO.gui.shop.make(p.items);
	}

	void onBuyResult(Pk00ca p)
	{
		RO.gui.removeShop;
	}

	void onSellResult(Pk00cb p)
	{
		RO.gui.removeShop;
	}

	/// ====================================== KAFRA ======================================
	void onKafraItems(Pk0995 p)
	{
		RO.gui.createStore;

		foreach(ref v; p.items)
		{
			RO.gui.store.items.add(new Item(v));
		}
	}

	void onKafraItem(Pk0a0a p)
	{
		RO.gui.store.items.add(new Item(p));
	}

	void onKafraEquipItems(Pk0a10 p)
	{
		RO.gui.createStore;

		foreach(ref v; p.items)
		{
			RO.gui.store.items.add(new Item(v));
		}
	}

	void onKafraRemoved(Pk00f6 p)
	{
		if(auto e = RO.gui.store.items.getIdx(p.index))
		{
			if(p.amount == e.amount)
			{
				RO.gui.store.items.remove(e);
			}
			else
			{
				e.reamount(cast(ushort)(e.amount - p.amount));
			}
		}
	}

	void onKafraClose(Pk00f8 p)
	{
		RO.gui.removeStore;
	}

	void onEffect(Pk01f3 p)
	{
		RO.effects.add(p.effectId, ROent.self.ent.pos2);
	}

	void onItemDrop(Pk084b p)
	{
		RO.items.add(p);
	}

	void onItemDelete(Pk07fa p)
	{
		if(auto e = RO.status.items.getIdx(p.index))
		{
			if(p.amount == e.amount)
			{
				RO.status.items.remove(e);
			}
			else
			{
				e.reamount(cast(ushort)(e.amount - p.amount));
			}
		}
	}

	void onItemDropAck(Pk00af p)
	{
		if(p.amount)
		{
			if(auto e = RO.status.items.getIdx(p.index))
			{
				if(p.amount == e.amount)
				{
					RO.status.items.remove(e);
				}
				else
				{
					e.reamount(cast(ushort)(e.amount - p.amount));
				}
			}
		}
	}

	void onItemRemove(Pk00a1 p)
	{
		RO.items.remove(p.id);
	}

	void onCasting(Pk07fb p)
	{
		alias F = (a)
		{
			a.ent.info.doCast(p.delaytime, p.srcId != p.dstId);
			a.ent.info.msg(ROdb.skill(p.skillId) ~ ` !!`);
		};

		ROent.doActor(p.srcId, a => F(a));
	}

	void onPartyHp(Pk080e p)
	{
		alias F = (a)
		{
			a.ent.info.hp = p.hp;
			a.ent.info.maxHp = p.maxHp;
		};

		ROent.doActor(p.accountId, a => F(a));
	}

	void onLongParChange(Pk00b1 p)
	{
		auto v = p.value;

		switch(p.varId)
		{
		case SP_JOBEXP:			RO.status.jexp.value = v; break;
		case SP_NEXTJOBEXP:		RO.status.jnextExp.value = v; break;

		case SP_BASEEXP:		RO.status.bexp.value = v; break;
		case SP_NEXTBASEEXP:	RO.status.bnextExp.value = v; break;

		case SP_ZENY:			RO.gui.inv.zeny = v; break;

		default:
			p.varId.logger;
		}
	}

	void onParChange(Pk00b0 p)
	{
		auto i = cast(int)p.value;
		auto v = cast(short)p.value;

		Actor s = ROent.self;

		switch(p.varId)
		{
		case SP_WEIGHT:		RO.gui.inv.weight = i; break;
		case SP_MAXWEIGHT:	RO.gui.inv.maxWeight = i; break;

		case SP_JOBLEVEL:	RO.status.jlvl.value = v; break;
		case SP_BASELEVEL:	RO.status.blvl.value = v; break;

		case SP_HP:
			s.ent.info.hp = i;
			RO.status.hp.value = i;
			break;

		case SP_SP:
			s.ent.info.sp = i;
			RO.status.sp.value = i;
			break;

		case SP_MAXHP:
			s.ent.info.maxHp = i;
			RO.status.maxHp.value = i;
			break;

		case SP_MAXSP:
			s.ent.info.maxSp = i;
			RO.status.maxSp.value = i;
			break;

		case SP_ATK1:		RO.status.bonuses[RO_ATK].base = v; break;
		case SP_ATK2:		RO.status.bonuses[RO_ATK].base2 = v; break;

		case SP_MATK1:		RO.status.bonuses[RO_MATK].base = v; break;
		case SP_MATK2:		RO.status.bonuses[RO_MATK].base2 = v; break;

		case SP_HIT:		RO.status.bonuses[RO_HIT].base = v; break;
		case SP_CRITICAL:	RO.status.bonuses[RO_CRIT].base = v; break;

		case SP_DEF1:		RO.status.bonuses[RO_DEF].base = v; break;
		case SP_DEF2:		RO.status.bonuses[RO_DEF].base2 = v; break;

		case SP_MDEF1:		RO.status.bonuses[RO_MDEF].base = v; break;
		case SP_MDEF2:		RO.status.bonuses[RO_MDEF].base2 = v; break;

		case SP_FLEE1:		RO.status.bonuses[RO_FLEE].base = v; break;
		case SP_FLEE2:		RO.status.bonuses[RO_FLEE].base2 = v; break;

		case SP_ASPD:		RO.status.bonuses[RO_ASPD].base = v; break;

		default:
		}
	}

	void onHotkeys(Pk0a00 p)
	{
		foreach(i, ref e; p.hotkeys[].enumerate.filter!(a => !!a.value.id))
		{
			RO.gui.hotkeys.add(e, Vector2s(i % 9, i / 9));
		}
	}

	void onSpriteChange(Pk01d7 p)
	{
		ROent.doActor(p.id, a => a.changeLook(p.type, cast(ushort)p.value));
	}

	void onPickUp(Pk0a37 p)
	{
		if(!p.result)
		{
			if(auto e = RO.status.items.getIdx(p.idx))
			{
				e.reamount(cast(ushort)(e.amount + p.amount));
			}
			else
			{
				RO.status.items.add(new Item(p));
			}
		}
	}

	void onItemUsed(Pk01c8 p)
	{
		if(p.result && p.id == ROent.self.bl)
		{
			if(auto e = RO.status.items.getIdx(p.index))
			{
				if(p.amount)
				{
					e.reamount(p.amount);
				}
				else
				{
					RO.status.items.remove(e);
				}
			}
		}
	}

	void onEquip(Pk0999 p)
	{
		if(!p.result)
		{
			if(auto e = RO.status.items.getIdx(p.index))
			{
				e.doEquip(p.equipLocation);
			}
		}
	}

	void onUnequip(Pk099a p)
	{
		if(!p.result)
		{
			if(auto e = RO.status.items.getIdx(p.index))
			{
				e.doEquip(0);
			}
		}
	}

	void onStatsNeed(Pk00be p)
	{
		if(p.statusId >= SP_USTR && p.statusId <= SP_ULUK)
		{
			RO.status.stats[p.statusId - SP_USTR].needs = p.value;
		}
	}

	void onStatChange(Pk0141 p)
	{
		if(p.statusId >= SP_STR && p.statusId <= SP_LUK)
		{
			with(RO.status.stats[p.statusId - SP_STR])
			{
				base = cast(ubyte)p.baseStatus;
				bonus = cast(ubyte)p.plusStatus;
			}
		}
	}

	void onStatsChange(Pk00bd p)
	{
		with(RO.status)
		{
			stats[RO_STR].needs = p.needStr;
			stats[RO_AGI].needs = p.needAgi;
			stats[RO_VIT].needs = p.needVit;
			stats[RO_INT].needs = p.needInt;
			stats[RO_DEX].needs = p.needDex;
			stats[RO_LUK].needs = p.needLuk;
		}
	}

	void onCharList(Pk006b p)
	{
		ROres.load(`amatsu`);

		foreach_reverse(i, ref c; p.chars)
		{
			auto e = ROent.createChar(&c, cast(uint)i, st.gender);

			e.fix(Vector2s(259 + i * 2, 190).PosDir);
		}

		st.chars = p.chars;

		if(p.chars.length)
		{
			RO.action.charSelect(0);
		}
		else
		{
			RO.gui.createCreation;
		}
	}

	void onMapInfoNew(Pk0ac5 p)
	{
		mapLogin(p.data);
	}

	void onMapInfo(Pk0071 p)
	{
		mapLogin(p.data);
	}

	void mapLogin(PkMapLoginData p) // TODO: MOVE
	{
		connect(new InternetAddress(p.ip.bswap, p.port));
		uint tick = PE.tick;

		version(AE_ENCRYPTED_NET)
		{
			auto arr = tick.toByte;
			arr[0] = cast(ubyte)~(arr[1] ^ 0xEB);
		}

		send!Pk0923(st.accountId, st.curChar.charId, st.authCode, tick, st.gender);
	}

	void onMapStart(Pk0283 p)
	{
		version(AE_ENCRYPTED_NET)
		{
			_flags |= M_ENC_KEY;
		}
	}

	void onWalking(Pk09fd p)
	{
		auto v = ActorInfo(p);
		v.vpos = p.walkData.toVec.to;

		ROent.appear(v);
	}

	void onAppear(Pk09ff p)
	{
		auto v = ActorInfo(p);
		v.vpos = p.position.toVec.pos;

		ROent.appear(v);
	}

	void onSpawn(Pk09fe p)
	{
		auto v = ActorInfo(p);
		v.vpos = p.position.toVec.pos;

		ROent.appear(v);
	}

	void onMove(Pk0086 p)
	{
		ROent.doActor(p.id, a => a.move(p.walkData.toVec[0..2]));
	}

	void onMoveSelf(Pk0087 p)
	{
		ROent.self.move(p.walkData.toVec[0..2]);
	}

	void onVanish(Pk0080 p)
	{
		ROent.remove(p.id);
	}

	void onItems(Pk0991 p)
	{
		foreach(ref r; p.items)
		{
			RO.status.items.add(new Item(r));
		}
	}

	void onEqupItems(Pk0a0d p)
	{
		foreach(ref r; p.items)
		{
			RO.status.items.add(new Item(r));
		}
	}

	void onSkills(Pk010f p)
	{
		foreach(ref r; p.skills)
		{
			auto s = RO.status.skillOf(r.skillId);
			auto u = s ? s : new Skill;

			if(!s)
			{
				RO.status.skills ~= u;

				u.name = r.skillName[].toStr.toLower;
				u.id = r.skillId;
				u.type = cast(ubyte)r.type;

				RO.gui.skills.add(u);
			}

			u.sp = r.spCost;
			u.lvl = cast(ubyte)r.level;
			u.range = cast(ubyte)r.attackRange;
			u.upgradable = !!r.upgradable;
		}
	}

	void onMapChange(Pk0091 p)
	{
		auto map = p.mapName.as!char.charsToString.stripExtension;

		{
			RO.status.items.clear;

			ROent.onMap(map, Vector2s(p.x, p.y));
		}

		send!Pk007d;

		_flags |= M_PING;
	}

	void onSkillEntry(Pk09ca p)
	{}

	void onGroundSkill(Pk0117 p)
	{
		RO.effects.addSkill(p.skillId, Vector2s(p.x, p.y));
	}

	void onMsgState(Pk0983 p)
	{}

	void onAttack(Pk08c8 p)
	{
		ROent.doActor(p.srcId, a => a.doAttack(p));

		if(p.damage)
		{
			ROent.doActor(p.dstId, a => RO.gui.values.show(a, p.damage));
		}
	}

	void onSkillAttack(Pk01de p)
	{
		ROent.doActor(p.dstId, a => a.ent.info.damageSkill(p.damage));
	}

	void onNpcMessage(Pk00b4 p)
	{
		ROnpc.mes(p.message.toStr, p.npcId);
	}

	void onNpcWait(Pk00b5 p)
	{
		ROnpc.next;
	}

	void onNpcClose(Pk00b6 p)
	{
		ROnpc.close;
	}

	void onNpcSelect(Pk00b7 p)
	{
		ROnpc.select(p.menuItems.toStr);
	}

	void onChatPlayer(Pk008d p)
	{
		auto c = Color(0, 255, 0, 255);
		auto s = p.text.toStr;

		alias F = (a)
		{
			a.ent.info.msg(s, c);
		};

		chat(s, c);
		ROent.doActor(p.bl, a => F(a));
	}

	void onPlayerChat(Pk008e p)
	{
		auto c = Color(0, 255, 0, 255);
		auto s = p.message.toStr;

		if(ROent.self)
		{
			ROent.self.ent.info.msg(s, c);
		}

		chat(s, c);
	}

	void onGuildChat(Pk017f p)
	{
		chat(p.message.toStr, Color(180, 250, 180, 255));
	}

	void onDisplayMessage(Pk02c1 p)
	{
		chat(p.message.toStr, Color.fromInt((p.color << 8) | 255));
	}

	NetStatus st;
private:
	void chat(string s, Color c)
	{
		RO.gui.chat.add(s, c);
	}

	void initialize()
	{
		foreach(m; __traits(allMembers, typeof(this)))
		{
			static if(m.startsWith(`on`))
			{
				alias F = AliasSeq!(__traits(getMember, this, m));
				alias T = Parameters!F[0];

				auto id = pId!T;
				checkId(id);

				_handlers[id] = &doPacket!(F, T);
			}
		}
	}

	void delegate(ubyte[])[ushort] _handlers;
}
