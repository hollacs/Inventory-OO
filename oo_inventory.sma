#include <amxmodx>
#include <amxmisc>
#include <oo_game_item>
#include <oo_inventory_const>

enum Forwards
{
	FW_NEW,
	FW_CTOR,
	FW_DTOR,
	FW_GIVE,
	FW_PERFORM,
};

new g_Forward[Forwards];
new g_ForwardRet;

new PlayerInventory:g_oPlayerInventory[MAX_PLAYERS + 1];
new InventoryOption:g_oOptionUse;
new InventoryOption:g_oOptionDiscardOne;
new InventoryOption:g_oOptionDiscard;

new cvar_size;

public plugin_init()
{
	register_plugin("[OO] Player Inventory", "0.1", "holla");

	register_concmd("inv_give", "CmdGive", ADMIN_BAN, "<player> <item class> <amount>");
	register_clcmd("inv_open", "CmdOpen");

	oo_gameitem_init();

	bind_pcvar_num(create_cvar("inv_default_size", "14"), cvar_size);

	g_oOptionUse = oo_new("IOptionUse");
	g_oOptionDiscardOne = oo_new("IOptionDiscardOne");
	g_oOptionDiscard = oo_new("IOptionDiscard");

	g_Forward[FW_NEW]  = CreateMultiForward("oo_on_inventory_new", ET_CONTINUE, FP_CELL);
	g_Forward[FW_CTOR] = CreateMultiForward("oo_on_inventory_ctor", ET_IGNORE, FP_CELL);
	g_Forward[FW_DTOR] = CreateMultiForward("oo_on_inventory_dtor", ET_IGNORE, FP_CELL);
	g_Forward[FW_GIVE] = CreateMultiForward("oo_on_inventory_give", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	g_Forward[FW_PERFORM] = CreateMultiForward("oo_on_inventory_perform_option", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
}

public oo_init()
{
	oo_class("InventoryOption")
	{
		new cl[] = "InventoryOption";
		oo_mthd(cl, "Perform", @obj(inventory_o), @int(index));
		oo_mthd(cl, "GetName", @stref(name), @int(maxlen));
	}

	oo_class("IOptionUse", "InventoryOption")
	{
		new cl[] = "IOptionUse";
		oo_mthd(cl, "Perform", @obj(inventory_o), @int(index));
		oo_mthd(cl, "GetName", @stref(name), @int(maxlen));
		oo_smthd(cl, "GetInstance");
	}
	oo_class("IOptionDiscardOne", "InventoryOption")
	{
		new cl[] = "IOptionDiscardOne";
		oo_mthd(cl, "Perform", @obj(inventory_o), @int(index));
		oo_mthd(cl, "GetName", @stref(name), @int(maxlen));
		oo_smthd(cl, "GetInstance");
	}
	oo_class("IOptionDiscard", "InventoryOption")
	{
		new cl[] = "IOptionDiscard";
		oo_mthd(cl, "Perform", @obj(inventory_o), @int(index));
		oo_mthd(cl, "GetName", @stref(name), @int(maxlen));
		oo_smthd(cl, "GetInstance");
	}

	oo_class("PlayerInventory")
	{
		new cl[] = "PlayerInventory";
		oo_var(cl, "player_id", 1);
		oo_var(cl, "slots", 1);
		oo_var(cl, "page", 1);

		oo_ctor(cl, "Ctor", @int(id), @int(size));
		oo_dtor(cl, "Dtor");

		oo_mthd(cl, "GiveItem", @obj(item_o), @int(amount), @bool(check_space));
		oo_mthd(cl, "RemoveSlot", @int(index), @int(amount));
		oo_mthd(cl, "RemoveItem", @obj(item_o), @int(amount));
		oo_mthd(cl, "CountItem", @obj(item_o));
		oo_mthd(cl, "Copy", @obj(inventory_o), @bool(resize));
		oo_mthd(cl, "GetSize");
		oo_mthd(cl, "Organize");
		oo_mthd(cl, "Clear");
		oo_mthd(cl, "Get", @int(index), @arr(slot[PlayerInventorySlot]));
		oo_mthd(cl, "Set", @int(index), @arr(slot[PlayerInventorySlot]));
		oo_mthd(cl, "GetOptions", @arr(options[MAX_INVENTORY_OPTIONS]))
		oo_mthd(cl, "GetTitle", @stref(title), @int(maxlen));
		oo_mthd(cl, "GetSlotName", @int(index), @stref(title), @int(maxlen));
		oo_mthd(cl, "CanShowMenu");
		oo_mthd(cl, "ShowMenu", @int(page), @int(time));
		oo_mthd(cl, "AddExtraMenuItems", @int(menu), @str(info));
		oo_mthd(cl, "HandleMenu", @int(menu), @int(item));
		oo_mthd(cl, "HandleExtraMenuItem", @int(menu), @int(item));
		oo_mthd(cl, "GetOptionTitle", @int(index), @stref(title), @int(maxlen));
		oo_mthd(cl, "ShowOptionMenu", @int(index));
		oo_mthd(cl, "HandleOptionMenu", @int(index), @int(menu), @int(item));
		oo_mthd(cl, "PerformOption", @int(opt_id), @int(slot_id));

		oo_smthd(cl, "GetInstance", @int(id));
		oo_smthd(cl, "SetInstance", @int(id), @obj(instance_o));
	}
}

public InventoryOption@Perform() {}

public InventoryOption@Ctor(const name[])
{
	oo_set_str(oo_this(), "name", name);
}

public InventoryOption@GetName(name[], maxlen)
{
	oo_get_str(oo_this(), "name", name, maxlen+1);
}

public IOptionUse@GetName(name[], maxlen)
{
	formatex(name, maxlen, "使用");
}
public IOptionUse@Perform(PlayerInventory:inventory_o, index)
{
	new slot[PlayerInventorySlot];
	oo_call(inventory_o, "Get", index, slot);
	if (oo_call(slot[PIS_Item], "Use", oo_get(inventory_o, "player_id")))
	{
		oo_call(inventory_o, "RemoveSlot", index, 1);
		return 1;
	}

	return 0;
}
public any:IOptionUse@GetInstance() { return g_oOptionUse; }

public IOptionDiscardOne@GetName(name[], maxlen)
{
	formatex(name, maxlen, "丟棄 1 個");
}
public IOptionDiscardOne@Perform(PlayerInventory:inventory_o, index)
{
	oo_call(inventory_o, "RemoveSlot", index, 1);
	oo_call(inventory_o, "ShowMenu", -1, -1);
	return 1;
}
public any:IOptionDiscardOne@GetInstance() { return g_oOptionDiscardOne; }

public IOptionDiscard@GetName(name[], maxlen)
{
	formatex(name, maxlen, "丟棄此欄位的全部");
}
public IOptionDiscard@Perform(PlayerInventory:inventory_o, index)
{
	oo_call(inventory_o, "RemoveSlot", index, 0);
	oo_call(inventory_o, "ShowMenu", -1, -1);
	return 1;
}
public any:IOptionDiscard@GetInstance() { return g_oOptionDiscard; }

public PlayerInventory@Ctor(id, size)
{
	new this = oo_this();
	oo_set(this, "player_id", id);
	oo_set(this, "page", 0);

	new Array:slots_a = ArrayCreate(PlayerInventorySlot);
	oo_set(this, "slots", slots_a);
	ArrayResize(slots_a, size);
	oo_call(this, "Clear");

	ExecuteForward(g_Forward[FW_CTOR], g_ForwardRet, id);
}

public PlayerInventory@Dtor()
{
	new this = oo_this();
	ExecuteForward(g_Forward[FW_DTOR], g_ForwardRet, oo_get(this, "player_id"));

	new Array:slots_a = any:oo_get(this, "slots");
	ArrayDestroy(slots_a);
}

public PlayerInventory@GetOptions(InventoryOption:options[MAX_INVENTORY_OPTIONS])
{
	options[0] = g_oOptionUse;
	options[1] = g_oOptionDiscardOne;
	options[2] = g_oOptionDiscard;
}

public PlayerInventory@GiveItem(GameItem:item_o, amount, bool:check_space)
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	new slots_size = ArraySize(slots_a);
	new stacks = oo_gameitem_get_stacks(item_o);
	new added_count = 0;
	new slot[PlayerInventorySlot], count;

	if (check_space)
	{
		for (new i = 0; i < slots_size; i++)
		{
			ArrayGetArray(slots_a, i, slot);
			if (slot[PIS_Item] == @null)
				added_count += stacks;
			else if (slot[PIS_Item] == item_o)
				added_count += stacks - slot[PIS_Count];
			else
				continue;
		}

		if (added_count < amount)
			return 0;

		added_count = 0;
	}

	for (new i = 0; i < slots_size; i++)
	{
		ArrayGetArray(slots_a, i, slot);
		if (slot[PIS_Item] == @null)
		{
			count = min(stacks, amount - added_count);
			slot[PIS_Item] = item_o;
			slot[PIS_Count] = count;
			added_count += count;
		}
		else if (slot[PIS_Item] == item_o)
		{
			count = min(stacks - slot[PIS_Count], amount - added_count);
			slot[PIS_Count] += count;
			added_count += count;
		}
		else
			continue;

		ArraySetArray(slots_a, i, slot);

		if (added_count >= amount)
			break;
	}

	ExecuteForward(g_Forward[FW_GIVE], g_ForwardRet, oo_get(this, "player_id"), item_o, added_count);
	return added_count;
}

public PlayerInventory@RemoveSlot(index, amount)
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	new slot[PlayerInventorySlot] = {@null, 0};
	if (amount != 0)
	{
		ArrayGetArray(slots_a, index, slot);
		if (amount >= slot[PIS_Count])
		{
			slot[PIS_Item] = @null;
			slot[PIS_Count] = 0;
		}
		else
		{
			slot[PIS_Count] -= amount;
		}
	}
	ArraySetArray(slots_a, index, slot);
}

public PlayerInventory@RemoveItem(GameItem:item_o, amount)
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	new slots_size = ArraySize(slots_a);
	new slot[PlayerInventorySlot], count;
	new remove_count = 0;

	for (new i = slots_size-1; i >= 0; i--)
	{
		ArrayGetArray(slots_a, i, slot);
		if (slot[PIS_Item] == item_o)
		{
			count = min(slot[PIS_Count], amount - remove_count);
			slot[PIS_Count] -= count;

			if (slot[PIS_Count] <= 0)
			{
				slot[PIS_Item] = @null;
				slot[PIS_Count] = 0;
			}

			ArraySetArray(slots_a, i, slot);
			remove_count += count;

			if (remove_count >= amount)
				break;
		}
	}

	return remove_count;
}

public PlayerInventory@Organize()
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	new slots_size = ArraySize(slots_a);
	new slot[PlayerInventorySlot], slot2[PlayerInventorySlot], count, stacks, j;

	new Array:new_a = ArrayCreate(PlayerInventorySlot);

	new index = 0;
	for (new i = 0; i < slots_size; i++)
	{
		ArrayGetArray(slots_a, i, slot);
		
		if (slot[PIS_Item] != @null)
		{
			count = 0;
			stacks = oo_gameitem_get_stacks(slot[PIS_Item]);

			for (j = i; j < slots_size; j++)
			{
				ArrayGetArray(slots_a, j, slot2);
				if (slot2[PIS_Item] == slot[PIS_Item])
				{
					count += slot2[PIS_Count];
					slot2[PIS_Item] = @null;
					slot2[PIS_Count] = 0;
					ArraySetArray(slots_a, j, slot2);
				}
			}

			while (index < slots_size && count > 0)
			{
				slot2[PIS_Item] = slot[PIS_Item];
				slot2[PIS_Count] = min(stacks, count);
				count -= slot2[PIS_Count];
				index++;
				ArrayPushArray(new_a, slot2);
			}
		}
	}

	for (new i = 0; i < index; i++)
	{
		ArrayGetArray(new_a, i, slot);
		ArraySetArray(slots_a, i, slot);
	}

	slot[PIS_Item] = @null;
	slot[PIS_Count] = 0;
	for (new i = index; i < slots_size; i++)
	{
		ArraySetArray(slots_a, i, slot);
	}

	ArrayDestroy(new_a);
}

public PlayerInventory@CountItem(GameItem:item_o)
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	new slots_size = ArraySize(slots_a);
	new count = 0;
	new slot[PlayerInventorySlot];

	for (new i = 0; i < slots_size; i++)
	{
		ArrayGetArray(slots_a, i, slot);
		if (slot[PIS_Item] == item_o)
			count += slot[PIS_Count];
	}

	return count;
}

public PlayerInventory@Copy(PlayerInventory:inventory_o, bool:resize)
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(inventory_o, "slots");
	new Array:slots_a2 = any:oo_get(this, "slots");
	if (resize)
		ArrayResize(slots_a2, ArraySize(slots_a));

	new slot[PlayerInventorySlot];
	new slots_size = ArraySize(slots_a2);
	for (new i = 0; i < slots_size; i++)
	{
		ArrayGetArray(slots_a, i, slot);
		ArraySetArray(slots_a2, i, slot);
	}
}

public PlayerInventory@GetSize()
{
	return ArraySize(Array:oo_get(oo_this(), "slots"));
}

public PlayerInventory@Clear()
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	new slots_size = ArraySize(slots_a);
	new slot[PlayerInventorySlot] = {@null, 0};

	for (new i = 0; i < slots_size; i++)
	{
		ArraySetArray(slots_a, i, slot);
	}
}

public PlayerInventory@Get(index, slot[PlayerInventorySlot])
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	ArrayGetArray(slots_a, index, slot);
}

public PlayerInventory@Set(index, slot[PlayerInventorySlot])
{
	new this = oo_this();
	new Array:slots_a = any:oo_get(this, "slots");
	ArraySetArray(slots_a, index, slot);
}

public PlayerInventory@GetTitle(title[], maxlen)
{
	formatex(title, maxlen, "Player Inventory");
}

public PlayerInventory@GetSlotName(index, output[], maxlen)
{
	new this = oo_this();

	new slot[PlayerInventorySlot];
	ArrayGetArray(any:oo_get(this, "slots"), index, slot);

	new GameItem:item_o = slot[PIS_Item];
	if (item_o == @null)
	{
		formatex(output, maxlen, "\d---");
	}
	else
	{
		static name[32];
		oo_gameitem_get_name(item_o, name, charsmax(name));
		formatex(output, maxlen, "%s \y[%d/%d]", name, slot[PIS_Count], oo_gameitem_get_stacks(item_o));
	}
}

public bool:PlayerInventory@CanShowMenu() { return true; }

public PlayerInventory@ShowMenu(page, time)
{
	new this = oo_this();
	if (!oo_call(this, "CanShowMenu"))
		return -1;

	if (page == -1)
		page = oo_get(this, "page");
	else if (page != oo_get(this, "page"))
		oo_set(this, "page", page);

	static str[64], info[32];
	oo_call(this, "GetTitle", str, charsmax(str));
	num_to_str(this, info, charsmax(info));

	new menu = menu_create(str, "HandleInventoryMenu", true);

	new Array:slots_a = any:oo_get(this, "slots");
	new slots_size = ArraySize(slots_a);
	if (slots_size < 1)
		return -1;

	for (new i = 0; i < slots_size; i++)
	{
		oo_call(this, "GetSlotName", i, str, charsmax(str));
		menu_additem(menu, str, info);
	}

	oo_call(this, "AddExtraMenuItems", menu, info);

	menu_display(oo_get(this, "player_id"), menu, page, time);
	return menu;
}

public PlayerInventory@AddExtraMenuItems(menu, const info[])
{
	menu_additem(menu, "整理背包", info);
}

public PlayerInventory@HandleMenu(menu, item)
{
	new this = oo_this();
	if (item == MENU_EXIT || !oo_call(this, "CanShowMenu"))
	{
		oo_set(this, "page", 0);
		return;
	}

	new oldmenu, newmenu, menupage;
	player_menu_info(oo_get(this, "player_id"), oldmenu, newmenu, menupage);
	oo_set(this, "page", menupage);
	
	new size = oo_call(this, "GetSize");
	if (item >= size)
	{
		oo_call(this, "HandleExtraMenuItem", menu, item - size);
	}
	else
	{
		new slot[PlayerInventorySlot];
		oo_call(this, "Get", item, slot);

		if (slot[PIS_Item] != @null)
			oo_call(this, "ShowOptionMenu", item);
		else
			oo_call(this, "ShowMenu", -1, -1);
	}
}

public PlayerInventory@HandleExtraMenuItem(menu, item)
{
	new this = oo_this();
	if (item == 0)
	{
		oo_call(this, "Organize");
		oo_call(this, "ShowMenu", 0, -1);
	}
}

public PlayerInventory@GetOptionTitle(index, title[], maxlen)
{
	new this = oo_this();
	static name[32], desc[48];
	new slot[PlayerInventorySlot];
	ArrayGetArray(Array:oo_get(this, "slots"), index, slot);
	oo_gameitem_get_name(slot[PIS_Item], name, charsmax(name));
	oo_gameitem_get_desc(slot[PIS_Item], desc, charsmax(desc));
	new stacks = oo_gameitem_get_stacks(slot[PIS_Item]);

	formatex(title, maxlen, "處理選項: \r欄位 #%d \w%s \y[%d/%d]^n\y說明: \w%s", 
		index+1, name, slot[PIS_Count], stacks, desc);
}

public PlayerInventory@ShowOptionMenu(index)
{
	new this = oo_this();
	if (!oo_call(this, "CanShowMenu"))
		return -1;

	new Array:slots_a = any:oo_get(this, "slots");

	new slot[PlayerInventorySlot];
	ArrayGetArray(slots_a, index, slot);
	if (slot[PIS_Item] == @null)
		return -1;
	
	new options[MAX_INVENTORY_OPTIONS] = {@null, ...};
	oo_call(this, "GetOptions", options);

	static str[96], info[32];
	oo_call(this, "GetOptionTitle", index, str, charsmax(str));
	formatex(info, charsmax(info), "%d %d", this, index);

	new menu = menu_create(str, "HandleOptionMenu", true);

	for (new i = 0; i < MAX_GAMEITEM_OPTIONS; i++)
	{
		if (options[i] == @null)
		{
			if (i == 0) break;
			menu_addblank2(menu);
		}
		else
		{
			oo_call(options[i], "GetName", str, charsmax(str));
			menu_additem(menu, str, info);
		}
	}

	if (menu_items(menu) < 1)
	{
		menu_destroy(menu);
		return -1;
	}

	menu_display(oo_get(this, "player_id"), menu);
	return menu;
}

public PlayerInventory@HandleOptionMenu(slot_id, menu, item)
{
	new this = oo_this();
	if (item == MENU_EXIT || !oo_call(this, "CanShowMenu"))
		return;

	oo_call(this, "PerformOption", item, slot_id);
}

public PlayerInventory@PerformOption(opt_id, slot_id)
{
	new this = oo_this();

	new options[MAX_INVENTORY_OPTIONS] = {@null, ...};
	oo_call(this, "GetOptions", options);
	if (options[opt_id] == @null)
		return false;
	
	ExecuteForward(g_Forward[FW_PERFORM], g_ForwardRet, oo_get(this, "player_id"), opt_id, slot_id);
	if (g_ForwardRet >= PLUGIN_HANDLED)
		return false;

	return oo_call(options[opt_id], "Perform", this, slot_id);
}

public PlayerInventory:PlayerInventory@GetInstance(id)
{
	return g_oPlayerInventory[id];
}

public PlayerInventory@SetInstance(id, PlayerInventory:instance_o)
{
	g_oPlayerInventory[id] = instance_o;
}

public HandleInventoryMenu(id, menu, item)
{
	static info[16];
	menu_item_getinfo(menu, item, _, info, charsmax(info));

	new PlayerInventory:inventory_o = any:str_to_num(info);
	if (oo_object_exists(inventory_o))
	{
		oo_call(inventory_o, "HandleMenu", menu, item);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public HandleOptionMenu(id, menu, item)
{
	static info[32], arg[2][16];
	menu_item_getinfo(menu, item, _, info, charsmax(info));
	parse(info, arg[0], charsmax(arg[]), arg[1], charsmax(arg[]));

	new PlayerInventory:inventory_o = any:str_to_num(arg[0]);
	if (oo_object_exists(inventory_o))
	{
		new index = str_to_num(arg[1]);
		oo_call(inventory_o, "HandleOptionMenu", index, menu, item);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
	ExecuteForward(g_Forward[FW_NEW], g_ForwardRet, id);
	if (g_ForwardRet == PLUGIN_HANDLED)
		return;

	g_oPlayerInventory[id] = oo_new("PlayerInventory", id, cvar_size);
}

public client_disconnected(id)
{
	if (oo_object_exists(g_oPlayerInventory[id]))
	{
		oo_delete(g_oPlayerInventory[id]);
		g_oPlayerInventory[id] = @null;
	}
}

public CmdGive(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	static arg[32], arg2[32], arg3[16];
	read_argv(1, arg, charsmax(arg))
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
	
	if (!player)
		return PLUGIN_HANDLED

	read_argv(2, arg2, charsmax(arg2));

	new GameItem:item_o = oo_gameitem_find_obj(arg2);
	if (item_o == @null)
	{
		console_print(id, "[inventory] invalid (GameItem) class (%s)", arg2);
		return PLUGIN_HANDLED;
	}

	read_argv(3, arg3, charsmax(arg3));
	new amount = str_to_num(arg3);
	if (amount < 1)
	{
		console_print(id, "[inventory] amount must be > 0");
		return PLUGIN_HANDLED;
	}

	new count = oo_call(g_oPlayerInventory[id], "GiveItem", item_o, amount, false);
	console_print(id, "[inventory] give %d (%s)", count, arg2);
	return PLUGIN_HANDLED;
}

public CmdOpen(id)
{
	oo_call(g_oPlayerInventory[id], "ShowMenu", -1, -1);
	return PLUGIN_HANDLED;
}