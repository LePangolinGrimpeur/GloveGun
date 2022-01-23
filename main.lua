rocket = {

}

function init()
    RegisterTool("testitem","Test Item","MOD/vox/testrock.vox")
    SetBool("game.tool.testitem.enabled", true)
end

function tick(dt)
    if GetString("game.player.tool") == "testitem" then
		--Tool is selected. Tool logic goes here.
      if InputPressed("lmb") then
        test = 10
        local ct = GetCameraTransform()
        local fwdpos = TransformToParentPoint(ct, Vec(0, 0, -2))
	      local gunpos = TransformToParentPoint(ct, Vec(0, 0, -1))
	      local direction = VecSub(fwdpos, gunpos)
        
      end
    end
end