#include <amxmodx>
#include <oo_game_item>
#include <oo_inventory>

public plugin_init()
{
	oo_gameitem_init();
	oo_gameitem_add(oo_new("GameItem", "a", "a", "aaa", 1));
	oo_gameitem_add(oo_new("GameItem", "0", "0", "000", 1));
	oo_gameitem_add(oo_new("GameItem", "b", "b", "bbb", 2));
	oo_gameitem_add(oo_new("GameItem", "c", "c", "ccc", 3));

	oo_gameitem_remove(oo_gameitem_find_index("0"), true);

	new Array:arr = oo_gameitem_get_items();
	server_print("arr size = %d, item count = %d", ArraySize(arr), oo_gameitem_get_count());

	new GameItem:a = oo_gameitem_find_obj("a");
	server_print("item (a) object = #%d", a);

	new GameItem:b = oo_gameitem_at(1);
	new GameItem:c = oo_gameitem_at(oo_gameitem_find_index("c"));
	server_print("item[1] object = #%d, item (c) object = #%d", b, c);

	new size = ArraySize(arr);
	new GameItem:o, name[32], desc[48], class[32], stacks;
	for (new i = 0; i < size; i++)
	{
		o = ArrayGetCell(arr, i);
		oo_gameitem_get_name(o, name, charsmax(name));
		oo_gameitem_get_desc(o, desc, charsmax(desc));
		oo_gameitem_get_class(o, class, charsmax(class));
		stacks = oo_gameitem_get_stacks(o);
		server_print("#%d: name = %s, desc = %s, class = %s, stacks = %d",
			i, name, desc, class, stacks);
	}

	oo_inventory_set_instance(1, oo_new("PlayerInventory", 1, 10));
	server_print("get_instance(1) = #%d", oo_inventory_get_instance(1));

	new num = oo_inventory_give_item(1, a, 20, true);
	num || server_print("inventory has not enough space to add(a, 20)");

	num = oo_inventory_give_item(1, a, 10, true);
	server_print("added %d (a) to inventory", num);

	server_print("count item (a) = %d", oo_inventory_count_item(1, a))

	oo_inventory_remove_slot(1, 3, 0);
	oo_inventory_give_item(1, b, 4, false);

	oo_inventory_remove_item(1, a, 2);
	oo_inventory_give_item(1, c, 9, false);

	oo_inventory_remove_slot(1, 0, 0);

	new slot[PlayerInventorySlot];
	slot[PIS_Item] = b;
	slot[PIS_Count] = 1;
	oo_inventory_set(1, 1, slot);

	server_print("before organize:");
	PrintInventory(1);

	oo_inventory_organize(1);

	server_print("^nafter organize:");
	PrintInventory(1);

	oo_inventory_set_instance(2, oo_new("PlayerInventory", 2, 5));
	oo_inventory_give_item(2, c, 20, false);

	oo_inventory_copy(1, oo_inventory_get_instance(2), true);
	server_print("^nafter copy:");
	PrintInventory(1);

	oo_inventory_clear(2);
	server_print("^nafter clear:");
	PrintInventory(2);

	oo_gameitem_clear(true);
	server_print("object (#%d) %s", a, oo_object_exists(a) ? "exists" : "does not exist");

	// release memory
	oo_delete(oo_inventory_get_instance(1));
	oo_delete(oo_inventory_get_instance(2));
}

PrintInventory(id)
{
	new slot[PlayerInventorySlot], name[32];
	new size = oo_inventory_get_size(id);
	for (new i = 0; i < size; i++)
	{
		oo_inventory_get(id, i, slot);
		if (slot[PIS_Item] == @null)
			server_print("%d. ---", i+1);
		else
		{
			oo_gameitem_get_name(slot[PIS_Item], name, charsmax(name));
			server_print("%d. %s [%d/%d]", i+1, name, slot[PIS_Count], oo_gameitem_get_stacks(slot[PIS_Item]));
		}
	}
}