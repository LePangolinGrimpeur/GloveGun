holygrenade = {
	shellNum = 1,
	shells = {},
	defaultShell = {
		active = false, 
		grenadeTimer = 0,
		boomTimer = 0,
		bounces = 0,
	},
}

function init()
	RegisterTool("holygrenade", "Holy Grenade", "MOD/vox/holygrenade.vox")
	SetBool("game.tool.holygrenade.enabled", true)
	SetFloat("game.tool.holygrenade.ammo", 101)

	holygrenadegravity = Vec(0, -160, 0)
	holygrenadevelocity = 100
	holygrenadefuseTime = 5
	swingTimer = 0

	for i=1, 250 do
		holygrenade.shells[i] = deepcopy(holygrenade.defaultShell)
	end

	holygrenadethrowsound = LoadSound("MOD/snd/throw.ogg")
	holygrenadebouncesound = LoadSound("MOD/snd/holybounce.ogg")
	holygrenadehallesound = LoadSound("MOD/snd/hallelujah.ogg")
	holygrenadeboomsound = LoadSound("MOD/snd/holyboom.ogg")

	holygrenadesprite = LoadSprite("MOD/img/holygren.png")
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Shoot()
	local ct = GetCameraTransform()
	local fwdpos = TransformToParentPoint(ct, Vec(0, 0, -2))
	local gunpos = TransformToParentPoint(ct, Vec(0, 0, -1))
	local direction = VecSub(fwdpos, gunpos)
	swingTimer = 0.125

	PlaySound(holygrenadethrowsound, ct.pos, 1, false)
	
	holygrenade.shells[holygrenade.shellNum] = deepcopy(holygrenade.defaultShell)
	loadedShell = holygrenade.shells[holygrenade.shellNum] 
	loadedShell.active = true
	loadedShell.grenadepos = gunpos
	loadedShell.predictedBulletVelocity = VecScale(direction, holygrenadevelocity)
	loadedShell.grenadeTimer = holygrenadefuseTime
	loadedShell.gravity = holygrenadegravity

	holygrenade.shellNum = (holygrenade.shellNum%#holygrenade.shells) +1
end

function HolyGrenadeOperations(projectile)
	projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity, (VecScale(projectile.gravity, GetTimeStep()/4)))
	local point2 = VecAdd(projectile.grenadepos, VecScale(projectile.predictedBulletVelocity, GetTimeStep()/4))
	local dir = VecNormalize(VecSub(point2, projectile.grenadepos))
	local distance = VecLength(VecSub(point2, projectile.grenadepos))
	local hit, dist, normal = QueryRaycast(projectile.grenadepos, dir, distance)
	if hit then
		if projectile.bounces == 30 then
			projectile.gravity = Vec(0, 0, 0)
			projectile.predictedBulletVelocity = Vec(0, 0, 0)
		else
			if projectile.bounces < 10 then
				PlaySound(holygrenadebouncesound, projectile.grenadepos, 1, false)
			end
			local dot = VecDot(normal, projectile.predictedBulletVelocity)
			projectile.predictedBulletVelocity = VecSub(projectile.predictedBulletVelocity, VecScale(normal, dot*1.4))
			projectile.bounces = projectile.bounces + 1
		end
	else
		projectile.grenadepos = point2
	end
end

function tick(dt)
	if GetString("game.player.tool") == "holygrenade" and GetPlayerVehicle() == 0 then
		if InputPressed("lmb") then
			Shoot()
		end

		local b = GetToolBody()
		if b ~= 0 then
			local offset = Transform(Vec(0, 0, 0), QuatEuler(0, 0, 0))
			SetToolTransform(offset)

			if swingTimer > 0 then
				local t = Transform()
				t.pos = Vec(0, 0, swingTimer*2)
				t.rot = QuatEuler(swingTimer*50, 0, 0)
				SetToolTransform(t)

				swingTimer = swingTimer - dt
			end
		end

		if InputPressed("X") then
			holygrenadefuseTime = math.min(20, holygrenadefuseTime + 1)
		elseif InputPressed("Z") then
			holygrenadefuseTime = math.max(1, holygrenadefuseTime - 1)
		end
	end

	for key, shell in ipairs(holygrenade.shells) do
		if shell.grenadeTimer > 0 then
			shell.grenadeTimer = shell.grenadeTimer - GetTimeStep()
			if shell.grenadeTimer < 0.1 then
				shell.grenadeTimer = 0
				PlaySound(holygrenadehallesound, shell.grenadepos, 1, false)
				shell.boomTimer = 1.4
			end
		end

		if shell.boomTimer > 0 then
			shell.boomTimer = shell.boomTimer - GetTimeStep()
			if shell.boomTimer < 0.1 then
				shell.boomTimer = 0
				shell.active = false
				Explosion(shell.grenadepos, 10)
				PlaySound(holygrenadeboomsound, shell.grenadepos, 1)
			end
		end

		if shell.active then
			HolyGrenadeOperations(shell)
			local rot = QuatLookAt(shell.grenadepos, GetCameraTransform().pos)
			local transform = Transform(shell.grenadepos, rot)
			DrawSprite(holygrenadesprite, transform, 0.4, 0.4, 0.5, 0.5, 0.5, 1, true, false)
		end
	end
end