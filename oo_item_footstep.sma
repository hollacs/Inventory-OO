#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <oo_game_item>

new GameItem:g_oItem;

public plugin_init()
{
	register_plugin("GameItem: Foot Step", "0.1", "holla");

	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn_Post", 1);

	oo_gameitem_init();

	g_oItem = oo_new("GameItem", "footstep", "貓步", "走路無腳步聲", 3);
	oo_gameitem_add(g_oItem);
}

public OnPlayerSpawn_Post(id)
{
	if (is_user_alive(id))
		set_user_footsteps(id, 0); // 不知為何 fun 模塊中只有這個在重生時不會重設 (x
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

		if (get_user_footsteps(id))
		{
			client_print(id, print_chat, "你已經有貓步了");
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public oo_on_gameitem_use(id, GameItem:item_o)
{
	if (item_o == g_oItem)
	{
		set_user_footsteps(id, 1);
		client_print(0, print_chat, "%n 使用了貓步 (走路無腳步聲)", id);
	}
}