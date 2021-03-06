local SZKWXData = require("szkawuxing.globle.SZKWXData")

local CardUtils = class("CardUtils")

function CardUtils:insertCardsByUid(uid, newCard)
	--todo
	local cards = SZKWXData:getCards(uid)
	
	self:insertCardsByUid(cards, newCard)
end

function CardUtils:insertCards(cards, newCard)
	if cards and table.getn(cards) > 0 then
		--todo
		local newValue = newCard

		local insertIndex = 1;
		local j = table.getn(cards)
		for i = 1, j do
			local index = math.floor((i + j) / 2)

			dump(index, "cards test")

			if cards[index] < newValue then
				--todo
				i = index + 1
				insertIndex = i
			elseif cards[index] > newValue then
				j = index - 1
				insertIndex = j
			else
				insertIndex = index + 1
				break
			end
		end

		table.insert(cards, insertIndex, newCard)
	end
end

function CardUtils:getPlayerType(seatId)
    local other_index = seatId - SZKWX_MY_USERINFO.seat_id

    dump(other_index, "playerType test")

	local playerType = CARD_PLAYERTYPE_MY
    if other_index < 0 then
      other_index = other_index + 3
    end

    if other_index == 1 then
    	playerType = CARD_PLAYERTYPE_RIGHT
    elseif other_index == 2 then
    	playerType = CARD_PLAYERTYPE_LEFT
    end

    return playerType
end

-- status 1：出牌 2：摸牌 3：重连
function CardUtils:getControlTable(handle, handleCard, status, ableGangCards)

	local result = {}
	result["type"] = handle
	result["value"] = handleCard

	if status == 1 then
		--todo

		local gangCards = {}
		if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
			--todo
			table.insert(gangCards, handleCard)
		end
		result["gangCards"] = gangCards
	elseif status == 2 then
		local gangCards = {}
		for k,v in pairs(ableGangCards) do
			if v > 0 then
				--todo
				table.insert(gangCards, v)
			else
				break
			end
		end
		
		result["gangCards"] = gangCards
	elseif status == 3 then
		local gangCards = {}
		local m = false
		for k,v in pairs(ableGangCards) do
			if v > 0 then
				--todo
				table.insert(gangCards, v)
				m = true
			else
				break
			end
		end

		if not m then
			--todo
			if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
				--todo
				table.insert(gangCards, handleCard)
			end
		end

		result["gangCards"] = gangCards
	end

	return result
end

function CardUtils:processControl(seatId, handle, value)
	local progCards = {}

	local removeCards = {}

	if bit.band(handle, CONTROL_TYPE_GANG) > 0 then
		--todo
		if bit.band(handle, GANG_TYPE_BU) > 0 then
			--todo
			for i=1,4 do
				table.insert(progCards, value)
			end
			table.insert(removeCards, value)
		else
			for i=1,3 do
				table.insert(progCards, value)
				table.insert(removeCards, value)
			end
			table.insert(progCards, value)
			if bit.band(handle, GANG_TYPE_AN) > 0 then
				--todo
				table.insert(removeCards, value)
			end
		end
		
	elseif bit.band(handle, CONTROL_TYPE_PENG) > 0 then
		for i=1,2 do
			table.insert(progCards, value)
			table.insert(removeCards, value)
		end
		table.insert(progCards, value)
	elseif bit.band(handle, CHI_TYPE_LEFT) > 0 then
		for i=value,value + 2 do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			table.insert(progCards, i)
		end
	elseif bit.band(handle, CHI_TYPE_MIDDLE) > 0 then
		for i=value - 1,value + 1 do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			table.insert(progCards, i)
		end
	elseif bit.band(handle, CHI_TYPE_RIGHT) > 0 then
		for i=value - 2,value do
			if value ~= i then
				--todo
				table.insert(removeCards, i)
			end

			table.insert(progCards, i)
		end
	end

	self:removeCards(seatId, removeCards)

	return progCards
end

function CardUtils:removeCards(seatId, removeCards)
	print("seatId=",seatId)
	dump(removeCards, "要删除的牌")
	local oriCards = SZKWX_GAMEINFO_TABLE[seatId .. ""].hand
	dump(oriCards, "手牌")

	local count = 0 --table.getn(oriCards)
	for k,v in pairs(oriCards) do
		count = count + 1
	end
	local removeCount = 0 -- table.getn(removeCards)
	for k,v in pairs(removeCards) do
		removeCount = removeCount + 1
	end
	print("手牌数量：",count, "要删除的牌数量：",removeCount)
	local removeIndex = 1

	local removeIndexs = {}
	if removeCount > 0 then
		--todo
		for i=1,count do
			if oriCards[i] == removeCards[removeIndex] or oriCards[i] == 0 then
				--todo
				table.insert(removeIndexs, i)
				removeIndex = removeIndex + 1

				if removeIndex > removeCount then
					--todo
					break
				end
			end
		end
	end
	
	dump(removeIndexs, "removeIndexs")
	for i=table.getn(removeIndexs),1,-1 do
		table.remove(oriCards, removeIndexs[i])
	end

	local reshu = 0
	for k,v in pairs(oriCards) do
		reshu = reshu + 1
	end
	print("剩余牌的数量：", reshu)

	if reshu > count - removeCount then
		if self:getPlayerType(seatId) ~= CARD_PLAYERTYPE_MY then
			table.sort(oriCards)
			for i=1,removeCount - count + reshu do
				table.remove(oriCards, 1)
			end
		end

		local lasts = 0
		for k,v in pairs(oriCards) do
			lasts = lasts + 1
		end
		print("强制删除后剩余牌的数量：", lasts)
	end
	print("座位",seatId)
	dump(SZKWX_GAMEINFO_TABLE[seatId .. ""].hand, "当前的手牌")
end

function CardUtils:playCard(seatId, value)
	local oriCards = SZKWX_GAMEINFO_TABLE[seatId .. ""].hand

	local tag = nil
	for i=1,table.getn(oriCards) do
		if oriCards[i] == 0 or oriCards[i] == value then
			--todo
			tag = i
			table.remove(oriCards, i)
			return tag
		end
	end

	if not tag then
		--todo
		for i=1,table.getn(oriCards) do
			if oriCards[i] == -1 then
				--todo
				tag = i
				table.remove(oriCards, i)
				return tag
			end
		end
	end
	
	return tag
end

function CardUtils:getNewCard(seatId, value)
	dump(seatId, "getNewCard seatId test")
	dump(SZKWX_GAMEINFO_TABLE, "getNewCard SZKWX_GAMEINFO_TABLE test")

	local oriCards = SZKWX_GAMEINFO_TABLE[seatId .. ""].hand

	-- self:insertCards(oriCards, value)

	table.insert(oriCards, value)
	table.sort(oriCards)

	dump(oriCards, "sort cards test")
end

return CardUtils