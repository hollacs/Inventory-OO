#include <amxmodx>
#include <amxmisc>
#include <oo>

enum Forwards
{
	FW_CAN_USE,
	FW_USE,
};

new g_Forward[Forwards];
new g_ForwardRet;

new GameItemManager:g_oGameItemManager;

public plugin_init()
{
	register_plugin("[OO] Game Item", "0.1", "holla");

	register_concmd("gameitem_list", "CmdList", ADMIN_BAN);

	g_oGameItemManager = oo_new("GameItemManager");

	g_Forward[FW_CAN_USE] = CreateMultiForward("oo_on_gameitem_can_use", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forward[FW_USE] = CreateMultiForward("oo_on_gameitem_use", ET_CONTINUE, FP_CELL, FP_CELL);
}

public oo_init()
{
	oo_class("GameItem")
	{
		new cl[] = "GameItem";
		oo_var(cl, "class", 32);
		oo_var(cl, "name", 32);
		oo_var(cl, "desc", 48);
		oo_var(cl, "stacks", 1);

		oo_ctor(cl, "Ctor", @str(class), @str(name), @str(desc), @int(stacks));
		oo_dtor(cl, "Dtor");

		oo_mthd(cl, "CanUse", @int(id)); // bool:
		oo_mthd(cl, "Use", @int(id));

		oo_mthd(cl, "GetName", @stref(name), @int(maxlen));
		oo_mthd(cl, "GetDesc", @stref(name), @int(maxlen));
	}

	oo_class("GameItemManager")
	{
		new cl[] = "GameItemManager";
		oo_var(cl, "items", 1); // Array:
		oo_var(cl, "item_index", 1); // Trie:

		oo_ctor(cl, "Ctor");
		oo_dtor(cl, "Dtor");

		oo_mthd(cl, "AddItem", @obj(item_o));
		oo_mthd(cl, "RemoveItem", @int(index), @bool(delete));
		oo_mthd(cl, "GetItems"); // Array:
		oo_mthd(cl, "GetItemsCount");
		oo_mthd(cl, "FindItemIndexByClass", @str(class));
		oo_mthd(cl, "FindItemObjByClass", @str(class)); // GameItem:
		oo_mthd(cl, "At", @int(index)); // GameItem:
		oo_mthd(cl, "Clear", @bool(delete));

		oo_smthd(cl, "GetInstance"); // GameItemManager:
	}
}

public GameItem@Ctor(const class[], const name[], const desc[], stacks)
{
	new this = oo_this();
	oo_set_str(this, "class", class);
	oo_set_str(this, "name", name);
	oo_set_str(this, "desc", desc);
	oo_set(this, "stacks", stacks);
}

public GameItem@Dtor() {}

public GameItem@GetName(name[], maxlen)
{
	oo_get_str(oo_this(), "name", name, maxlen+1);
}

public GameItem@GetDesc(name[], maxlen)
{
	oo_get_str(oo_this(), "desc", name, maxlen+1);
}

public bool:GameItem@CanUse(id)
{
	ExecuteForward(g_Forward[FW_CAN_USE], g_ForwardRet, id, oo_this());
	if (g_ForwardRet >= PLUGIN_HANDLED)
		return false;

	return true;
}

public GameItem@Use(id)
{
	new this = oo_this();
	if (!oo_call(this, "CanUse", id))
		return false;

	ExecuteForward(g_Forward[FW_USE], g_ForwardRet, id, this);
	return true;
}

public GameItemManager@Ctor()
{
	new this = oo_this();
	oo_set(this, "items", ArrayCreate(1));
	oo_set(this, "item_index", TrieCreate());
}

public GameItemManager@Dtor()
{
	new this = oo_this();

	new Array:items_a = any:oo_get(this, "items");
	new items_count = ArraySize(items_a), GameItem:item_o;
	for (new i = 0; i < items_count; i++)
	{
		item_o = any:ArrayGetCell(items_a, i);
		if (oo_object_exists(item_o))
			oo_delete(item_o);
	}
	ArrayDestroy(items_a);

	new Trie:item_index_t = any:oo_get(this, "item_index");
	TrieDestroy(item_index_t);
}

public GameItemManager@AddItem(GameItem:item_o)
{
	if (!oo_object_exists(item_o))
	{
		log_amx("GameItemManager@AddItem() : object #%d does not exist", item_o);
		return -1;
	}

	if (!oo_isa(item_o, "GameItem"))
	{
		log_amx("GameItemManager@AddItem() : object #%d not a (GameItem)", item_o);
		return -1;
	}

	new this = oo_this();
	new Array:items_a = any:oo_get(this, "items");
	new index = ArraySize(items_a);

	static class[32];
	oo_get_str(item_o, "class", class, sizeof class);
	TrieSetCell(Trie:oo_get(this, "item_index"), class, index);
	ArrayPushCell(Array:oo_get(this, "items"), item_o);
	return index;
}

public GameItemManager@RemoveItem(remove_index, bool:delete)
{
	new this = oo_this();
	new Array:items_a = any:oo_get(this, "items");
	if (remove_index < 0 || remove_index >= ArraySize(items_a))
	{
		log_amx("GameItemManager@RemoveItem() : index (%d) out of bounds", remove_index);
		return;
	}

	new GameItem:item_o = ArrayGetCell(items_a, remove_index);
	if (delete && oo_object_exists(item_o))
		oo_delete(item_o);

	ArrayDeleteItem(items_a, remove_index);

	static remove_key[32], key[32], index;
	new Trie:item_index_t = any:oo_get(this, "item_index");
	new TrieIter:iter = TrieIterCreate(item_index_t);
	while (!TrieIterEnded(iter))
	{
		TrieIterGetCell(iter, index);

		if (index == remove_index)
		{
			TrieIterGetKey(iter, remove_key, charsmax(remove_key)); // delete key later
		}
		else if (index > remove_index)
		{
			TrieIterGetKey(iter, key, charsmax(key));
			TrieSetCell(item_index_t, key, --index); // shift index
		}

		TrieIterNext(iter);
	}
	TrieIterDestroy(iter);

	TrieDeleteKey(item_index_t, remove_key);
}

public Array:GameItemManager@GetItems()
{
	return Array:oo_get(oo_this(), "items");
}

public GameItemManager@GetItemsCount()
{
	return ArraySize(Array:oo_get(oo_this(), "items"));
}

public GameItemManager@FindItemIndexByClass(const class[])
{
	new index;
	if (TrieGetCell(Trie:oo_get(oo_this(), "item_index"), class, index))
		return index;

	return -1;
}

public GameItem:GameItemManager@FindItemObjByClass(const class[])
{
	new this = oo_this();
	new index = oo_call(this, "FindItemIndexByClass", class);
	if (index != -1)
		return any:oo_call(this, "At", index);

	return @null;
}

public GameItem:GameItemManager@At(index)
{
	new this = oo_this();
	new Array:items_a = any:oo_get(this, "items");
	if (index < 0 || index >= ArraySize(items_a))
	{
		log_amx("GameItemManager@At() : index (%d) out of bounds", index);
		return @null;
	}

	return any:ArrayGetCell(Array:oo_get(this, "items"), index);
}

public GameItemManager@Clear(bool:delete)
{
	new this = oo_this();
	new Array:items_a = any:oo_get(this, "items");
	if (delete)
	{
		new items_count = ArraySize(items_a), GameItem:item_o;
		for (new i = 0; i < items_count; i++)
		{
			item_o = any:ArrayGetCell(items_a, i);
			if (oo_object_exists(item_o))
				oo_delete(item_o);
		}
	}
	ArrayClear(items_a);

	new Trie:item_index_t = any:oo_get(this, "item_index");
	TrieClear(item_index_t);
}

public GameItemManager:GameItemManager@GetInstance()
{
	return g_oGameItemManager;
}

public CmdList(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	console_print(id, "#id [class] [name] [desc] stacks^n------------------------------");

	static class[32], name[32], desc[48], stacks, GameItem:item_o;
	new count = oo_call(g_oGameItemManager, "GetItemsCount");
	for (new i = 0; i < count; i++)
	{
		item_o = any:oo_call(g_oGameItemManager, "At", i);
		oo_get_str(item_o, "class", class, sizeof class);
		oo_call(item_o, "GetName", name, charsmax(name));
		oo_call(item_o, "GetDesc", desc, charsmax(desc));
		stacks = oo_get(item_o, "stacks");
		console_print(id, "#%d [%s] [%s] [%s] %d", i, class, name, desc, stacks);
	}

	return PLUGIN_HANDLED;
}