#include <amxmodx>
#include <nvault>
#include <oo_inventory>

new g_Vault;

public plugin_init()
{
	register_plugin("Inventory Save", "0.1", "holla");
	oo_gameitem_init();
	g_Vault = nvault_open("inventory");
}

public plugin_end()
{
	nvault_close(g_Vault);
}

public client_putinserver(id)
{
	static data[512], arg[2][32], authid[50];
	get_user_authid(id, authid, charsmax(authid));

	if (nvault_get(g_Vault, authid, data, charsmax(data)))
	{
		new size = oo_inventory_get_size(id);
		new slot[PlayerInventorySlot], GameItem:item_o;
		for (new i = 0; i < size; i++)
		{
			if (argbreak(data, arg[0], charsmax(arg[]), data, charsmax(data)) == -1) break;
			if (argbreak(data, arg[1], charsmax(arg[]), data, charsmax(data)) == -1) break;

			item_o = oo_gameitem_find_obj(arg[0]);
			if (item_o != @null)
			{
				slot[PIS_Item] = item_o;
				slot[PIS_Count] = str_to_num(arg[1]);
				oo_inventory_set(id, i, slot);
			}
		}
	}
}

public oo_on_inventory_dtor(id)
{
	static data[512], class[32], authid[50];

	new len = 0;
	new slot[PlayerInventorySlot]
	new size = oo_inventory_get_size(id);
	for (new i = 0; i < size; i++)
	{
		oo_inventory_get(id, i, slot);
		if (slot[PIS_Item] == @null)
			copy(class, charsmax(class), "^"^"");
		else
			oo_gameitem_get_class(slot[PIS_Item], class, charsmax(class));

		len += formatex(data[len], charsmax(data)-len, "%s %d ", class, slot[PIS_Count]);
	}

	get_user_authid(id, authid, charsmax(authid));
	nvault_set(g_Vault, authid, data);
}