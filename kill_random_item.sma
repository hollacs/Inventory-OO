#include <amxmodx>
#include <hamsandwich>
#include <oo_inventory>

public plugin_init()
{
	register_plugin("Kill Random Item", "0.1", "holla");

	oo_gameitem_init() // 容器初始化

	RegisterHam(Ham_Killed, "player", "OnPlayerKilled_Post", 1); // 註冊事件
}

// 玩家被殺
public OnPlayerKilled_Post(id, killer)
{
	if (id != killer)
	{
		// 給予殺手道具隨機的道具
		oo_inventory_give_item(killer, oo_gameitem_at(random(oo_gameitem_get_count())));
	}
}

// 背包給予道具的事件
public oo_on_inventory_give(id, GameItem:item_o, amount)
{
	static name[32];
	oo_gameitem_get_name(item_o, name, charsmax(name)); // 獲取道具的名稱
	client_print(0, print_chat, "%n 獲得了 %s x %d", id, name, amount);
}

// 背包選項進行事件
public oo_on_inventory_perform_option(id, option, slot)
{
	// 預設是 (0 = 使用, 1 = 丟棄一個, 2 = 丟棄欄位全部)
	if (option == 1 || option == 2)
	{
		new slot_data[PlayerInventorySlot];
		oo_inventory_get(id, slot, slot_data);

		new amount = (option == 1) ? 1 : slot_data[PIS_Count];

		static name[32];
		oo_gameitem_get_name(slot_data[PIS_Item], name, charsmax(name)); // 獲取道具的名稱
		client_print(id, print_chat, "你丟棄了 %s x %d", name, amount);
	}
}