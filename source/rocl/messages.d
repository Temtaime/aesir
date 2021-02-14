module rocl.messages;

import
		std.conv;


enum LANGS = [ `en`, `ru` ];

__gshared ubyte LANG = 1;

mixin(
{
	string s;

	foreach(i, m; MESSAGES)
	{
		s ~= `@property MSG_` ~ m[0] ~ `() { auto arr = MESSAGES[` ~ i.to!string ~ `]; auto k = LANG + 1; return arr.length > k ? arr[k] : arr[1]; }`;
	}

	return s;
}
());

@property lang()
{
	return LANGS[LANG];
}

private:

enum MESSAGES =
[
	[ `SETTINGS`, `Settings`, `Настройки` ],
	[ `SHADOWS`, `Shadows`, `Тени` ],
	[ `LIGHTING`, `Lighting`, `Освещение` ],
	[ `RENDER_QUALITY`, `Render quality`, `Качество прорисовки` ],
	[ `FOG`, `Fog`, `Туман` ],
	[ `FULLSCREEN`, `Fullscreen`, `Полный экран` ],
	[ `ANTIALIASING`, `Antialiasing`, `Сглаживание` ],
	[ `VSYNC`, `V-Sync` ],
	[ `NO`, `No`, `Нет` ],
	[ `LOW`, `Low`, `Низко` ],
	[ `MIDDLE`, `Middle`, `Средне` ],
	[ `HIGH`, `High`, `Высоко` ],
	[ `HIGHEST`, `Highest`, `Высочайше` ],
	[ `DIFFUSE`, `Diffuse`, `Фоновое` ],
	[ `FULL`, `Full`, `Полное` ],

	[ `CHAR_SELECT`, `Character select`, `Выбор персонажа` ],
	[ `ENTER`, `Enter`, `Войти` ],

	[ `INVENTORY`, `Inventory`, `Инвентарь` ],
	[ `WEIGHT`, `weight`, `вес` ],
	[ `PCS`, `pcs`, `шт.` ],

	[ `NEXT`, `Next`, `Далее` ],
	[ `CLOSE`, `Close`, `Закрыть` ],

	[ `SKILLS`, `Skills`, `Умения` ],
	[ `USE`, `Use`, `Использовать` ],
	[ `LEARN`, `Learn`, `Изучить` ],

	[ `CHARACTER`, `Character`, `Персонаж` ],
	[ `INV`, `Inv.`, `Инв.` ],
	[ `EQP`, `Equip`, `Экип.` ],
	[ `SK`, `Sk.`, `Умен.` ],
	[ `OPTS`, `Opt.`, `Наст.` ],
	[ `BASE_LVL`, `Base lvl`, `Баз. ур.` ],
	[ `JOB_LVL`, `Job lvl`, `Проф. ур.` ],

	[`SPEED`, `Speed`, `Скорость`],
	[`STAT_POINTS`, `Status points`, `Очки статуса`],
	[`STAT_COSTS`, `Costs %u points`, `Расходует %u очков статуса`],

	[ `STATS`, `Stats`, `Характеристики` ],
	[ `EQUIPMENT`, `Equipment`, `Экипировка` ],
	[ `HEAD`, `Head`, `Голова` ],
	[ `ARMOR`, `Armor`, `Броня` ],
	[ `SHOES`, `Shoes`, `Ботинки` ],
	[ `ROBE`, `Robe`, `Мантия` ],
	[ `HAND_R`, `Right hand`, `Правая рука` ],
	[ `HAND_L`, `Left hand`, `Левая рука` ],
	[ `ACC`, `Accessory`, `Аксессуар` ],

	[ `STORAGE`, `Storage`, `Склад` ],
	[ `TRADING`, `Trading`, `Торговля` ],
	[ `BUY`, `Buy`, `Купить` ],
	[ `SELL`, `Sell`, `Продать` ],
	[ `BUYING`, `Buying`, `Покупка` ],
	[ `SELLING`, `Selling`, `Продажа` ],
	[ `TOTAL`, `Total`, `Всего` ],

	[ `OK`, `OK` ],
	[ `TRADE`, `Trade`, `Торг` ],
	[ `CANCEL`, `Cancel`, `Отмена` ],
	[ `INFO`, `Information`, `Информация` ],
	[ `HOTKEYS`, `Hotkeys`, `Горячие клавиши` ],
	[ `HOTKEY_SETTINGS`, `Hotkey settings`, `Настройка горячих клавиш` ],

	[ `CREATE`, `Create`, `Создать` ],
	[ `CHAR_CREATION`, `Character creation`, `Создание персонажа` ],
	[ `HAIR_COLOR`, `Hair color`, `Цвет волос` ],
	[ `HAIR_STYLE`, `Hair style`, `Причёска` ],
	[ `CHAR_NAME`, `Character name`, `Имя персонажа` ],

	[ `DEALING`, `Request a deal`, `Запросить сделку` ],
	[ `DEALING_WITH`, `Trading with`, `Обмен с` ],
	[ `DEAL_REQUEST`, "Player ^0000ff%s^000000 with level ^ff0000%u^000000 requests a deal.\nAccept?", "Игрок ^0000ff%s^000000 с уровнем ^ff0000%u^000000 запрашивает сделку.\nПринять?" ],

	[ `INTERFACE`, `Interface`, `Интерфейс` ],

	[ `WIN_EQUIP`, `Equip window`, `Окно экипировки` ],
	[ `WIN_SKILLS`, `Skills window`, `Окно умений` ],
	[ `WIN_SETTINGS`, `Settings window`, `Окно настроек` ],
	[ `WIN_INVENTORY`, `Inventory window`, `Окно инвентаря` ],

	[ `ITM`, `Item`, `Предм.` ],
	[ `ETC`, `Etc`, `Проч.` ],

	[ `CHAT`, `Chat`, `Чат` ],
	[ `SUBMIT`, `Submit`, `Отправить` ],

	[ `QUIT`, `Quit`, `Выйти` ],
	[ `LOGIN`, `Login`, `Вход` ],
	[ `USERNAME`, `Username`, `Логин` ],
	[ `PASSWORD`, `Password`, `Пароль` ],
	[ `ADD`, `Add`, `Добавить` ],
	[ `REMOVE`, `Remove`, `Удалить` ],
	[ `ADDING`, `Adding`, `Добавление` ],

	//[ ``, ``, `` ],
];
