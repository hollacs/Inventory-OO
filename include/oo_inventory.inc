#if defined _oo_inventory_included
	#endinput
#endif
#define _oo_inventory_included

#include <oo>
#include <oo_game_item>
#include <oo_inventory_const>

#define __PI_LOG_INSTANCE(%0) 	log_amx("PlayerInventory@GetInstance(%d) failed", %0)
#define __PI_LOG_ITEM(%0) 		log_amx("invalid (GameItem) object (#%d)", %0)
#define __PI_LOG_SLOT(%0) 		log_amx("slot index (%d) out of bounds", %0)
#define __PI_LOG_INVENTORY(%0) 	log_amx("invalid (PlayerInventroy) object (#%d)", %0)

#define __PI_GET_INVENTORY(%0,%1,%2) new PlayerInventory:%0 = oo_inventory_get_instance(%1); if (!oo_object_exists(%0)) { __PI_LOG_INSTANCE(%1); return %2; }
#define __PI_CHECK_ITEM(%0,%1) if (!oo_object_exists(%0) || !oo_isa(%0, "GameItem")) { __PI_LOG_ITEM(%0); return %1; }
#define __PI_CHECK_SLOT(%0,%1,%2) if (%1 < 0 || %1 >= oo_call(%0, "GetSize")) { __PI_LOG_SLOT(%1); return %2; }
#define __PI_CHECK_INVENTORY(%0,%1) if (!oo_object_exists(%0) || !oo_isa(%0, "PlayerInventory")) { __PI_LOG_INVENTORY(%0); return %1; }

// 建立背包實例的事件
// 在 forward 中 return PLUGIN_HANDLE 可以阻止原有的事件, 
// 然後可使用 oo_inventory_set_instance() 取代原有的實例
// 以上方法用於如果你繼承了新的 PlayerInventory 類別, 想使用新的類別作為實例
forward oo_on_inventory_new(id);

// 背包的建構事件
forward oo_on_inventory_ctor(id);

// 背包的解構事件
forward oo_on_inventory_dtor(id);

// 背包給予道具事件
forward oo_on_inventory_give(id, GameItem:item_o, amount);

// 背包選項進行事件
// return PLUGIN_HANDLE 可阻止事件進行
forward oo_on_inventory_perform_option(id, option, slot);

// 給道具進背包
// @param id 玩家
// @param item_o 道具的hash
// @param amount 給予的數量
// @param check_space 是否先檢查有沒有足夠空間, 若空間不足則不給予
// @return 給了多少個
stock oo_inventory_give_item(id, GameItem:item_o, amount=1, bool:check_space=false)
{
	__PI_GET_INVENTORY(inv_o, id, 0)
	__PI_CHECK_ITEM(item_o, 0)
	return oo_call(inv_o, "GiveItem", item_o, amount, check_space);
}

// 移除指定背包欄位的道具
// @param id 玩家
// @param slot 欄位的索引位置
// @param amount 移除的數量, 若為 0 則移除該欄位的全部
// @noreturn 
stock oo_inventory_remove_slot(id, slot, amount=0)
{
	__PI_GET_INVENTORY(inv_o, id, )
	__PI_CHECK_SLOT(inv_o, slot, )
	oo_call(inv_o, "RemoveSlot", slot, amount);
}

// 移除背包中的指定一種道具
// @param id 玩家
// @param item_o 道具的hash
// @param amount 移除的數量
// @return 移除了多少個 
stock oo_inventory_remove_item(id, GameItem:item_o, amount=1)
{
	__PI_GET_INVENTORY(inv_o, id, 0)
	__PI_CHECK_ITEM(item_o, 0)
	return oo_call(inv_o, "RemoveItem", item_o, amount);
}

// 計算背包中指定一種道具的數量
// @param id 玩家
// @param item_o 道具的hash
// @return 計算後的數量
stock oo_inventory_count_item(id, GameItem:item_o)
{
	__PI_GET_INVENTORY(inv_o, id, 0)
	__PI_CHECK_ITEM(item_o, 0)
	return oo_call(inv_o, "CountItem", item_o);
}

// 整理背包
// @param id 玩家
// @noreturn 
stock oo_inventory_organize(id)
{
	__PI_GET_INVENTORY(inv_o, id, )
	oo_call(inv_o, "Organize");
}

// 複製背包內容
// @param id 玩家
// @param inventory_o 要被複製的背包的hash
// @param resize 是否改變背包大小 (若玩家背包大小跟要被複製的背包大小不一樣)
// @noreturn
stock oo_inventory_copy(id, PlayerInventory:inventory_o, bool:resize=false)
{
	__PI_GET_INVENTORY(inv_o, id, )
	__PI_CHECK_INVENTORY(inventory_o, )
	oo_call(inv_o, "Copy", inventory_o, resize);
}

// 獲取背包的大小
// @param id 玩家
// @noreturn
stock oo_inventory_get_size(id)
{
	__PI_GET_INVENTORY(inv_o, id, 0)
	return oo_call(inv_o, "GetSize");
}

// 清空背包
// @param id 玩家
// @noreturn
stock oo_inventory_clear(id)
{
	__PI_GET_INVENTORY(inv_o, id, )
	oo_call(inv_o, "Clear");
}

// 獲取背包中指定欄位中的資料 (包括道具hash 和 堆疊數量)
// @param id 玩家
// @param slot_id 欄位的索引位置
// @param slot_data 欄位的資料 (詳見 oo_inventory_const.inc 的 PlayerInventorySlot)
// @noreturn
stock oo_inventory_get(id, slot_id, slot_data[PlayerInventorySlot])
{
	__PI_GET_INVENTORY(inv_o, id, )
	__PI_CHECK_SLOT(inv_o, id, )
	oo_call(inv_o, "Get", slot_id, slot_data);
}

// 改變背包中指定欄位中的資料 (包括道具hash 和 堆疊數量)
// @param id 玩家
// @param slot_id 欄位的索引位置
// @param slot_data 欄位的資料 (詳見 oo_inventory_const.inc 的 PlayerInventorySlot)
// @noreturn
stock oo_inventory_set(id, slot_id, slot_data[PlayerInventorySlot])
{
	__PI_GET_INVENTORY(inv_o, id, )
	__PI_CHECK_SLOT(inv_o, id, )
	oo_call(inv_o, "Set", slot_id, slot_data);
}

// 顯示背包選單
// @param id 玩家
// @param page 顯示頁數
// @param time 顯示時間 (若為 -1 則永久顯示)
// @return 選單的id
stock oo_inventory_show_menu(id, page=0, time=-1)
{
	__PI_GET_INVENTORY(inv_o, id, -1)
	return oo_call(inv_o, "ShowMenu", page, time);
}

// 獲取背包的選項
// @param id 玩家
// @param options 輸出到的陣列
// @noreturn
stock oo_inventory_get_options(id, options[MAX_INVENTORY_OPTIONS])
{
	__PI_GET_INVENTORY(inv_o, id, )
	oo_call(inv_o, "GetOptions", options);
}

// 進行背包的選項
// @param id 玩家
// @param option_id 選項的id
// @param slot_id 背包欄位的id
// @return false 為進行失敗, true 則為成功
stock bool:oo_inventory_perform_option(id, option_id, slot_id)
{
	__PI_GET_INVENTORY(inv_o, id, false)
	return bool:oo_call(inv_o, "PerformOption", option_id, slot_id);
}

// 獲取背包的實例
// @param id 玩家
// @return 實例的hash
stock PlayerInventory:oo_inventory_get_instance(id)
{
	return any:oo_call(0, "PlayerInventory@GetInstance", id);
}

// 改變背包的實例
// @param id 玩家
// @param instance_o 實例的hash
// @noreturn
stock oo_inventory_set_instance(id, PlayerInventory:instance_o)
{
	if (instance_o != @null)
	{
		__PI_CHECK_INVENTORY(instance_o, )
	}

	oo_call(0, "PlayerInventory@SetInstance", id, instance_o);
}