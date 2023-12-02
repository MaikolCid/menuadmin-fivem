CREATE TABLE IF NOT EXISTS `menuadmin` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `permissions` varchar(350) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

INSERT INTO `menuadmin` (`Id`, `permissions`) VALUES
	(2, '{"tpoint","spectate","clearVehicle","clearChat","bring","goto","kick","announce","fix","freeze"}\n'),
	(3, '{"noclip","tpoint","spectate","clearVehicle","clearChat","setJob","bring","goto","kick","freeze","spawnCar","fixvehicle"}\n'),
	(4, '{"adminplayers","staff","spawn","sanciones","noclip","godmode","vanish","spectate","tpoint","bring","goto","spawnCar","fixvehicle","clearVehicle","spawnWeapon","spawnObject","spawnMoney","clearInventory","setJob","clearChat","freeze","heal","kill","revive","warn","ck","ban","warnlist","banlist","refresh","kick"}');
