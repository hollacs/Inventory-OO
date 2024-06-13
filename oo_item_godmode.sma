#include <amxmodx>
#include <fun>
#include <oo_game_item>

new GameItem:g_oItem;

public plugin_init()
{
	register_plugin("GameItem: God Mode", "0.1", "holla");

	oo_gameitem_init();

	g_oItem = oo_new("GameItem", "godmode", "金鐘罩", "無敵", 1);
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

		if (get_user_godmode(id))
		{
			client_print(id, print_chat, "你已經有金鐘罩了");
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public oo_on_gameitem_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		set_user_godmode(id, 1);
		client_print(0, print_chat, "%n 使用了金鐘罩", id);
	}
}