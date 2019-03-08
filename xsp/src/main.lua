
require 'utils'

init("0",0)

mSleep(3000)

--showUI("ui.json")

screenWidth,screenHeight = getScreenSize()

startX = 0
startY = 0

initX = 0
initXmax = 0
initY = 810 / 2160 * screenHeight


function judgeColor(x, y)
	
	r,g,b = getColorRGB(x, y)
	r0,g0,b0 = getColorRGB(screenWidth - 77, initY)
	if math.abs(r0 - r) < 20 and math.abs(g0 - g) < 20 and math.abs(b0 - b) < 20 then
		return false
	else
		return true
	end
end

function tiaoyitiao(x, y)
	juli = math.sqrt(math.pow(x - startX, 2) + math.pow(y - startY, 2))
	
	sysLog('结束：x:' .. x ..';y:' .. y)
	-- 跳一跳
	offsetX = math.random(700)
	offsetY = math.random(250)
	t = 1.365821020352576 * juli
	touchDown(1, 11 + offsetX, 13 + offsetY)
	mSleep(t)
	touchUp(1, 11 + offsetX, 13 + offsetY)
	
	print('-------------------------------------------------------------')
	
	mSleep(1000 + math.random(500, 1000))
	
end

function getStartPoint()
	x = initX
	y = initY
	keepScreen(true);
	while true do
		if x >= screenWidth - 1 then
			x = initX
			y = y + 1
			if y > screenHeight then
				sysLog('结束')
				break
			end
		end
		
		-- 当小人高于目标物体时，寻找的时候要忽略小人
		r,g,b = getColorRGB(x, y)
		r_min = 50
		r_max = 70
		g_min = 50
		g_max = 60
		b_min = 50
		b_max = 90
		if r > r_min and r < r_max and g > g_min and g < g_max and b > b_min and b < b_max then
			x = x + 60
		else
			if judgeColor(x, y) then
				sysLog('开始：x:' .. x ..';y:' .. y)
				keepScreen(false);
				return x, y
			else
				x = x + 2
			end
		end
	end
end


function getTargetCoorde()
	
	x1, y1 = findMultiColorInRegionFuzzy(0x363c66,"-28|-5|0x2e2d50,-35|-9|0x2b2b49,24|-8|0x39365d,33|-12|0x393651,0|-72|0x3e384a,0|-105|0x554d7d,-2|-152|0x413d59,-1|-170|0x534c7b,15|-170|0x9289b1,-17|-170|0x3d3f5d,2|-183|0x50436b", 95, 0, 0, 1079, 2159, 0, 0)
	if x1 > -1 then
		startX = x1
		startY = y1
	end
	
	centerX = (screenWidth - 1) / 2
	if startX < centerX then -- 起跳点在左边，说明目标在右边
		initX = centerX
		initXmax = screenWidth - 1
	else -- -- 起跳点在右边，说明目标在左边
		initX  = 20
		initXmax = centerX
	end
	
	x0, y0 = getStartPoint()	
	
	-- 往下循环
	
	x = x0
	y = y0
	targetX = x0
	targetY = 0
	isFinish = false
	keepScreen(true);
	while true do
		if x >= initXmax then -- 说明靠近最右边，以此为水平中心
			targetY = y
			isFinish = true
			break
		else
			if not judgeColor(x, y) then
				for i = 1, 8 do
					if judgeColor(x, y + 1) then
						y = y + 1
						break
					end
					if i == 8 then
						targetY = y
						isFinish = true
						break
					end
				end
			end
		end
		
		if isFinish then
			keepScreen(false);
			tiaoyitiao(targetX, targetY)
			break
		end
		
		x = x + 1
	end
end

while true do	
	getTargetCoorde()
end

