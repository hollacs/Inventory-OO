#if defined _oo_game_item_included
	#endinput
#endif
#define _oo_game_item_included

#include <oo>

stock const MAX_GAMEITEM_OPTIONS = 7;

#define __GI_CHECK_MANAGER(%0) if (g_oItemManager == @null) { log_amx("GameItemManager not initialized, please use oo_gameitem_init()"); return %0; }
#define __GI_CHECK_ITEM(%0,%1) if (!oo_object_exists(%0) || !oo_isa(%0, "GameItem")) { log_amx("invalid (GameItem) object (#%d)", %0); return %1; }

// 使用道具事件
forward oo_on_gameitem_use(id, GameItem:item_o);

// 道具可不可以使用
// return PLUGIN_CONTINUE 為可以, PLUGIN_HANDLED 為不可以
forward oo_on_gameitem_can_use(id, GameItem:item_o);

// 容器的 hash
stock GameItemManager:g_oItemManager = @null;

// 初始化道具容器 (可自定義 GameItemManager 類別或物件, 用於如果你已經繼承了 GameItemManager 類別並覆寫原有類別的東西)
// @param class 容器的類別名稱
// @param manager_o 容器的hash
//   若 manager_o 不是 @null, 將使用 manger_o 作為容器
//   否則使用 class 的 GetInstance() 方法來獲取容器的hash
// @return 該物件的hash
stock GameItemManager:oo_gameitem_init(const class[]="GameItemManager", GameItemManager:manager_o=@null)
{
	if (manager_o != @null)
	{
		if (!oo_object_exists(manager_o))
		{
			log_amx("oo_gameitem_init() : object (#%d) does not exist", manager_o);
			return @null;
		}

		if (!oo_isa(manager_o, "GameItemManager"))
		{
			log_amx("oo_gameitem_init() : object (#%d) not a (GameItemManager)", manager_o);
			return @null;
		}
	}
	else
	{
		static call[64];
		formatex(call, charsmax(call), "%s@GetInstance", class);
		manager_o = any:oo_call(0, call);

		if (!oo_object_exists(manager_o))
		{
			log_amx("oo_gameitem_init() : %s() failed", call);
			return @null;
		}
	}

	g_oItemManager = manager_o;
	return g_oItemManager;
}

// 加入新道具到容器
// @param item_o 道具的hash
// @return 加入的索引位置
stock oo_gameitem_add(GameItem:item_o)
{
	__GI_CHECK_MANAGER(false)
	return oo_call(g_oItemManager, "AddItem", item_o);
}

// 從容器中移除道具
// @param index 索引位置
// @param delete 是否也刪除物件
//   若 delete=true 則同時刪除物件
// @noreturn
stock oo_gameitem_remove(index, bool:delete=false)
{
	__GI_CHECK_MANAGER( )
	oo_call(g_oItemManager, "RemoveItem", index, delete);
}

// 從容器中獲取道具的陣列
// @return 陣列的 array id
stock Array:oo_gameitem_get_items()
{
	__GI_CHECK_MANAGER(Invalid_Array)
	return any:oo_call(g_oItemManager, "GetItems");
}

// 從容器中獲取道具的數量
// @return 道具的數量
stock oo_gameitem_get_count()
{
	__GI_CHECK_MANAGER(0)
	return oo_call(g_oItemManager, "GetItemsCount");
}

// 從容器中以類別名稱搜尋道具所在的索引位置
// @param class 類別的名稱
// @return 索引位置
stock oo_gameitem_find_index(const class[])
{
	__GI_CHECK_MANAGER(-1)
	return oo_call(g_oItemManager, "FindItemIndexByClass", class);
}

// 從容器中以類別名稱搜尋道具的hash
// @param class 類別的名稱
// @return 道具的hash
stock GameItem:oo_gameitem_find_obj(const class[])
{
	__GI_CHECK_MANAGER(@null)
	return any:oo_call(g_oItemManager, "FindItemObjByClass", class);
}

// 從容器中以指定索引位置存取道具的hash
// @param class 索引位置
// @return 道具的hash
stock GameItem:oo_gameitem_at(index)
{
	__GI_CHECK_MANAGER(@null)
	return any:oo_call(g_oItemManager, "At", index);
}

// 從容器中移除所有道具
// @param delete 是否也刪除物件
//   若 delete=true 則同時刪除所有物件
// @noreturn
stock oo_gameitem_clear(bool:delete=false)
{
	__GI_CHECK_MANAGER(@null)
	return oo_call(g_oItemManager, "Clear", delete);
}

// 獲取道具的名稱
// @param item_o 道具的hash
// @param name 輸出的字串
// @param maxlen 字串長度
// @noreturn
stock oo_gameitem_get_name(GameItem:item_o, name[], maxlen)
{
	__GI_CHECK_ITEM(item_o, )
	oo_call(item_o, "GetName", name, maxlen);
}

// 獲取道具的註解
// @param item_o 道具的hash
// @param name 輸出的字串
// @param maxlen 字串長度
// @noreturn
stock oo_gameitem_get_desc(GameItem:item_o, name[], maxlen)
{
	__GI_CHECK_ITEM(item_o, )
	oo_call(item_o, "GetDesc", name, maxlen);
}

// 獲取道具的類別名稱
// @param item_o 道具的hash
// @param name 輸出的字串
// @param maxlen 字串長度
// @noreturn
stock oo_gameitem_get_class(GameItem:item_o, name[], maxlen)
{
	__GI_CHECK_ITEM(item_o, )
	oo_get_str(item_o, "class", name, maxlen+1);
}

// 獲取道具的堆疊數量
// @param item_o 道具的hash
// @return 堆疊數量
stock oo_gameitem_get_stacks(GameItem:item_o)
{
	__GI_CHECK_ITEM(item_o, 0)
	return oo_get(item_o, "stacks");
}