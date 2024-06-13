#include <amxmodx>
#include <fun>
#include <oo_game_item>

new GameItem:g_oItem;

public plugin_init()
{
	register_plugin("GameItem: Gravity", "0.1", "holla");

	oo_gameitem_init();

	g_oItem = oo_new("GameItem", "gravity", "跳躍鞋", "降低重力", 5);
	oo_gameitem_add(g_oItem);
}

public oo_on_gameitem_can_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		if (!is_user_alive(id))
		{
			client_print(id, print_chat, "只有生存時才能使用");
			return PLUGIN_HANDLED;
		}

		if (get_user_gravity(id) <= 0.5)
		{
			client_print(id, print_chat, "你已經穿了跳躍鞋");
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public oo_on_gameitem_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		set_user_gravity(id, 0.5);
		client_print(0, print_chat, "%n 使用了跳躍鞋", id);
	}
}