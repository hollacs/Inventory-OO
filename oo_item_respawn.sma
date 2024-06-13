#include <amxmodx>
#include <hamsandwich>
#include <oo_game_item>

new GameItem:g_oItem;

public plugin_init()
{
	register_plugin("GameItem: Respawn", "0.1", "holla");

	oo_gameitem_init();

	g_oItem = oo_new("GameItem", "respawn", "復活券", "不用等三天", 4);
	oo_gameitem_add(g_oItem);
}

public oo_on_gameitem_can_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		if (is_user_alive(id))
		{
			client_print(id, print_chat, "只有死亡時才能使用");
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public oo_on_gameitem_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		ExecuteHam(Ham_CS_RoundRespawn, id);
		client_print(0, print_chat, "%n 使用復活券重生了", id);
	}
}