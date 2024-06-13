#if defined _oo_inventory_const_included
	#endinput
#endif
#define _oo_inventory_const_included

const MAX_INVENTORY_OPTIONS = 7;

enum _:PlayerInventorySlot
{
	GameItem:PIS_Item,
	PIS_Count
};