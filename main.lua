rocket = {

}

function init()
    RegisterTool("glovegun","Glove Gun","MOD/vox/testrock.vox")
    SetBool("game.tool.glovegun.enabled", true)
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
        DebugPrint("Test d'affichage vecteur")
        DebugPrint(Vec(0,1,2))
        --Penser a utiliser DebugCross pour afficher differents pour pour tester TransformToParentChild
	      --Penser a utiliser transform.pos avec DebugCross pour tester differentes position (pour la caméra par exemple)
        
      end
    end
end