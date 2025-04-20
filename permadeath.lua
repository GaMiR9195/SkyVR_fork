replicatesignal(game.Players.LocalPlayer.ConnectDiedSignalBackend)
task.wait(math.max(game.Players.RespawnTime + (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 2500), 0))
replicatesignal(game.Players.LocalPlayer.Kill)