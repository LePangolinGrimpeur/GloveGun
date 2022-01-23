function init()
    RegisterTool("testitem","Test Item","MOD/vox/testrock.vox")
    SetBool("game.tool.testitem.enabled", true)
end

function tick(dt)
    if GetString("game.player.tool") == "testitem" then
		--Tool is selected. Tool logic goes here.
      if InputPressed("lmb") then
        DebugPrint("lmb pressed")
      end
    end
end