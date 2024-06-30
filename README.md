Certainly! Here's the translation of the provided information into English:

## CVAR
Default inventory size:
- `inv_default_size 14`

## Admin/Server Commands
Give item to a player:

```inv_give <player_name> <item_category_name> <quantity>```

- Example: `inv_give holla shit 5`
- Example: `inv_give holla medkit 1`

Display the server's item list:
- `gameitem_list`

## Player Commands
Open the inventory menu:
- `inv_open`

## Installation Requirements
- You must first install the [OO module](https://github.com/hollacs/oo_amxx/releases/latest).
- AMXX 1.9 or higher is required.

## Showcase Video
[![IMAGE ALT TEXT](http://img.youtube.com/vi/Ip7Ihi4PHY8/0.jpg)](http://www.youtube.com/watch?v=Ip7Ihi4PHY8 "Inventory System AMXX")

## Recommended plugins.ini Order
```ini
; Core
oo_game_item.amxx ; Item manager
oo_inventory.amxx ; Inventory system

; Items
oo_item_medkit.amxx
oo_item_armor.amxx
oo_item_gravity.amxx
oo_item_footstep.amxx
oo_item_godmode.amxx
oo_item_shit.amxx
oo_item_respawn.amxx

; Other
kill_random_item.amxx ; Kill to obtain random items and display messages for using and discarding item in inventory
inventory_save.amxx ; Save inventory items by SteamID (nvault)
;test_game_item_and_inventory.sma ; Used for testing functionality
```

### Example 1: Adding a New Game Item (oo_item_shit.sma)

```sourcepawn
#include <amxmodx>
#include <fun>
#include <oo_game_item>

new GameItem:g_oItem; // Used to store the item's hash

public plugin_init()
{
       register_plugin("GameItem: Shit", "0.1", "holla");

       oo_gameitem_init(); // Initialize the container

       // oo_new("GameItem", class name, display name, description, stack quantity)
       g_oItem = oo_new("GameItem", "shit", "Shit", "Use it to see the effect", 3);
       oo_gameitem_add(g_oItem); // Add the item to the container
}

// Check if the item can be used
public oo_on_gameitem_can_use(id, GameItem:item_o)
{
       if (item_o == g_oItem) // Check the item's hash
       {
              if (!is_user_alive(id)) // Player is already dead
              {
                     client_print(id, print_chat, "You can only use this when alive.");
                     return PLUGIN_HANDLED; // Cannot use
              }
       }

       return PLUGIN_CONTINUE; // Can use
}

// Action when using the item
public oo_on_gameitem_use(id, GameItem:item_o)
{
       if (item_o == g_oItem) // Check the item's hash
       {
              user_kill(id); // Kill the player
              client_print(0, print_chat, "%n ate the shit and fainted.", id);
       }
}
```

To give a player 5 shit:
Copy the following code:

```sourcepawn
new GameItem:item_o = oo_gameitem_find_obj("shit");
oo_inventory_give_item(id, item_o, 5);
```

### Example 2: Killing and Obtaining Random Items (kill_random_item.sma)

```sourcepawn
#include <amxmodx>
#include <hamsandwich>
#include <oo_inventory>

public plugin_init()
{
       register_plugin("Kill Random Item", "0.1", "holla");

       oo_gameitem_init(); // Initialize the container

       RegisterHam(Ham_Killed, "player", "OnPlayerKilled_Post", 1); // Register the event
}

// Player is killed
public OnPlayerKilled_Post(id, killer)
{
       if (id != killer)
       {
              // Give the killer a random item
              oo_inventory_give_item(killer, oo_gameitem_at(random(oo_gameitem_get_count())));
       }
}

// Event when an item is given to the inventory
public oo_on_inventory_give(id, GameItem:item_o, amount)
{
       static name[32];
       oo_gameitem_get_name(item_o, name, charsmax(name)); // Get the item's name
       client_print(0, print_chat, "%n received %s x %d", id, name, amount);
}

// Event when an inventory option is performed
public oo_on_inventory_perform_option(id, option, slot)
{
       // Default options: (0 = use, 1 = drop one, 2 = drop all from slot)
       if (option == 1 || option == 2)
       {
              new slot_data[PlayerInventorySlot];
              oo_inventory_get(id, slot, slot_data);

              new amount = (option == 1) ? 1 : slot_data[PIS_Count];

              static name[32];
              oo_gameitem_get_name(slot_data[PIS_Item], name, charsmax(name)); // Get the item's name
              client_print(id, print_chat, "You dropped %s x %d", name, amount);
       }
}
```

### Example 3: Saving Player Inventory Using nvault (inventory_save.sma)

```sourcepawn
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
```