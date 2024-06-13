#include <amxmodx>
#include <fun>
#include <oo_game_item>

new GameItem:g_oItem; // 用以記錄道具的 hash

public plugin_init()
{
	register_plugin("GameItem: Shit", "0.1", "holla");

	oo_gameitem_init(); // 初始化容器

	// oo_new("GameItem", 類別名稱, 道具顯示名稱, 註解, 堆疊數量)
	g_oItem = oo_new("GameItem", "shit", "屎", "使用就知道效果", 3);
	oo_gameitem_add(g_oItem); // 加入道具到容器
}

// 判定道具能不能使用
public oo_on_gameitem_can_use(id, GameItem:item_o)
{
	if (item_o == g_oItem) // 檢查道具 hash
	{
		if (!is_user_alive(id)) // 玩家已死亡
		{
			client_print(id, print_chat, "只有生存時才能使用");
			return PLUGIN_HANDLED; // 不能使用
		}
	}

	return PLUGIN_CONTINUE; // 可以使用
}

// 使用道具的動作
public oo_on_gameitem_use(id, GameItem:item_o)
{
	if (item_o == g_oItem) // 檢查道具 hash
	{
		user_kill(id); // 處死玩家
		client_print(0, print_chat, "%n 吃了屎臭得自己也昏了", id);
	}
}