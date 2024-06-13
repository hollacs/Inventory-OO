#include <amxmodx>
#include <fun>
#include <oo_game_item>

new GameItem:g_oItem;

public plugin_init()
{
	register_plugin("GameItem: Medkit", "0.1", "holla");

	oo_gameitem_init();

	g_oItem = oo_new("GameItem", "medkit", "急救包", "+100HP", 2);
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

		if (get_user_health(id) >= 100)
		{
			client_print(id, print_chat, "血量已滿");
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public oo_on_gameitem_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		set_user_health(id, min(get_user_health(id) + 100, 100));
		client_print(id, print_chat, "你使用了急救包 (+100HP)");
	}
}