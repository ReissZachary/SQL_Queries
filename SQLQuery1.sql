--select
--	Player_Name as PlayerName, 
--	Location_Name as RespawnLocation, 
--	Location_Zcord as ZCoordinate
--from 
--	Player inner join
--	Location 
--	on (Player.Player_RespawnLocation = location.Location_ID)
--	where Player.Player_Name = 'Blurrb';

--select 
--	Player_Name as Player,
--	Item_Name as Item,
--	Player_Inventory.Qantity as Qty,
--	Item_Durability as Durability
--from
--	Item inner join Player_Inventory
--	on(Item.Item_ID = Player_Inventory.Item_ID)
--	inner join Player on(Player.Player_ID = Player_Inventory.Player_ID)
--where Player.Player_Name = 'Blurrb';

		


