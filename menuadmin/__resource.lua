fx_version 'adamant'
description 'Admin System'

server_scripts { 
	'server/main.lua',
	'@mysql-async/lib/MySQL.lua'
}

client_scripts {
	'client/main.lua'
}