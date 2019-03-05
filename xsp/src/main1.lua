
require "utils"
require "buzaiduichendian"

--init("0",0)

mSleep(3000)

function judgeColor(x, y)
	
	r,g,b = getColorRGB(x, y)
	r0,g0,b0 = getColorRGB(1079, 851)
	
	if math.abs(r0 - r) < 15 and math.abs(g0 - g) < 15 and math.abs(b0 - b) < 15 then
		return false
	else
		return true
	end
end

allNum = 0
function tiaoyitiao(x, y)
	juli = math.sqrt(math.pow(x - startX, 2) + math.pow(y - startY, 2))
	--	print('距离:' .. juli)
	
--	sysLog('target：x:' .. x ..';y:' .. y)
--	print('-------------------------------------------------------------')
	
	-- 跳一跳
	offsetX = math.random(700)
	offsetY = math.random(250)
	touchDown(1, 11 + offsetX, 13 + offsetY)
	t = 1.345821020352576 * juli
	mSleep(t + math.random(15, 20))
	touchUp(1, 11 + offsetX, 13 + offsetY)
	
--	allNum = allNum + 1
--	if allNum == 20 then
--		allNum = 0
		
--		choice = dialogRet("请点击确定继续：", "确定", "", "", 0);
--	end
	
	mSleep(2000 + math.random(500, 1000))
	
end

startX = 0
startY = 0
targetX = 0
targetY = 0

screenWidth,screenHeight = getScreenSize()

centerX = screenWidth / 2
centerY = screenHeight / 2


isDuichendian = false

function getTargetCoorde()
	x, y = findMultiColorInRegionFuzzy(0x363c66,"-28|-5|0x2e2d50,-35|-9|0x2b2b49,24|-8|0x39365d,33|-12|0x393651,0|-72|0x3e384a,0|-105|0x554d7d,-2|-152|0x413d59,-1|-170|0x534c7b,15|-170|0x9289b1,-17|-170|0x3d3f5d,2|-183|0x50436b", 95, 0, 0, 1079, 2159, 0, 0)
	if x > -1 then
		startX = x
		startY = y
	end
	
--	sysLog('start：x:' .. startX ..';y:' .. startY)
	
	x0 = 2 * centerX - startX
	y0 = 2 * centerY - startY
	
--	sysLog('预测target：x:' .. x0 ..';y:' .. y0)
	
	if not judgeColor(x0, y0) then -- 对称点在目标物体上
		isDuichendian = true
		-- 纵向向下循环寻找targetX
		x = x0
		y = y0
		isLeft = false
		isRight = false
		isFinish = false
		
		keepScreen(true);
		while true do
			y = y - 1
			if not judgeColor(x, y) then
				-- 向左寻找
				num = 0
				while true do
					x = x - 1
					if not judgeColor(x, y) then
						num = num + 1
						if num >= 8 then -- 说明中心点在右面
							isRight = true
							break
						end
					else
						break
					end
				end
				
				-- 向右寻找
				x = x0
				num = 0
				while true do
					x = x + 1
					if not judgeColor(x, y) then
						num = num + 1
						if num >= 8 then -- 说明中心点在左面
							isLeft = true
							break
						end
					else
						break
					end
				end
				
				if isLeft and isRight then -- 说明当前就是水平中心
					targetX = x0
					break
				end
				
				if isLeft then
					x = x0 - 1
					while true do
						if not judgeColor(x, y) then
							y = y + 1
							x = x - 1
							if not judgeColor(x, y) then -- 说明左面已经没了
								targetX = x+ 1
								isFinish = true
								break
							end
						end
						
						y = y - 1
					end
				else
					x = x0 + 1
					while true do
						if not judgeColor(x, y) then
							y = y + 1
							x = x + 1
							if not judgeColor(x, y) then -- 说明右面已经没了
								targetX = x - 1
								isFinish = true
								break
							end
						end
						
						y = y - 1
					end
				end
				
				if isFinish then
					break
				end
				
			end
		end
		
		-- 横向向右循环寻找targetY
		x = x0
		y = y0
		isUp = false
		isDown = false
		isFinish = false
		
		while true do
			x = x + 1
			if not judgeColor(x, y) then
				-- 向上寻找
				num = 0
				while true do
					y = y - 1
					if not judgeColor(x, y) then
						num = num + 1
						if num >= 8 then -- 说明中心点在下面
							isDown = true
							break
						end
					else
						break
					end
				end
				
				-- 向下寻找
				y = y0
				num = 0
				while true do
					y = y + 1
					if not judgeColor(x, y) then
						num = num + 1
						if num >= 8 then -- 说明中心点在上面
							isUp = true
							break
						end
					else
						break
					end
				end
				
				if isUp and isDown then -- 说明当前就是水平中心
					targetY = y0
					break
				end
				
				if isUp then
					y = y0
					x = x - 1
					while true do
						y = y - 1
						if x >= screenWidth then -- 说明靠近最右边，以此为水平中心
							targetY = y
							isFinish = true
							break
						else
							if not judgeColor(x, y) then -- 说明上面已经没了
								targetY = y + 1
								isFinish = true
								break
							end
						end
					end
				else
					y = y0
					while true do
						if x >= screenWidth then -- 说明靠近最右边，以此为水平中心
							targetY = y
							isFinish = true
							break
						else
							if not judgeColor(x, y) then
								for i = 1, 8 do
									if judgeColor(x, y + i) then
										y = y + i
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
							keepScreen(false)
							break
						end
						
						x = x + 1
					end
				end
				
				if isFinish then
					keepScreen(false)
					break
				end
				
			end
		end
	else -- 对称点不在目标物体上
		isDuichendian = false
		getOtherTargetCoorde()
		
	end
end


while true do
	getTargetCoorde()
	if isDuichendian then
		tiaoyitiao(targetX, targetY)
	end
end




