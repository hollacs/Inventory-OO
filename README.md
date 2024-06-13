## CVAR
預設背包的空間
- `inv_default_size 14`

## 管理員/伺服器指令
給予玩家道具
- `inv_give 玩家名 道具的類別名稱 給予的數量`
- `inv_give holla shit 5`
- `inv_give holla medkit 1`

顯示伺服器的道具列表
- `gameitem_list`

## 玩家指令
打開背包選單
- `inv_open`

---

## 安裝需求
- 必須先安裝 [OO 模塊](https://github.com/hollacs/oo_amxx/releases/latest)
- AMXX 1.9 或以上

## 展示影片
[![IMAGE ALT TEXT](http://img.youtube.com/vi/Ip7Ihi4PHY8/0.jpg)](http://www.youtube.com/watch?v=Ip7Ihi4PHY8 "背包系統 Inventory AMXX")

## plugins.ini order
```
; 核心
oo_game_item.amxx ; 道具管理器
oo_inventory.amxx ; 背包系統

; 道具
oo_item_medkit.amxx
oo_item_armor.amxx
oo_item_gravity.amxx
oo_item_footstep.amxx
oo_item_godmode.amxx
oo_item_shit.amxx
oo_item_respawn.amxx

; 其他
kill_random_item.amxx ; 殺人獲得隨機道具 及顯示 獲得 和 丟棄操作 的訊息
inventory_save.amxx ; 以 steamid 儲存背包的道具 (nvault)
;test_game_item_and_inventory.sma ; 用以測試功能有沒有運作正常
```
