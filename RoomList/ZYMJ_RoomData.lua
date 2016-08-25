require "src/app/Game/AnShunMaJiang/bit"
ASMJ_CServerManager = class("ASMJ_RoomListScene", nil)

function ASMJ_CServerManager:new(o)
    print("ASMJ_CServerManager:new")
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function ASMJ_CServerManager:GetInstance()
    if self.instance == nil then
        self.instance = self:new()

        self.m_pServerArray = {}
        self.m_pServerArrayXS = {}
        self.m_pServerArrayCG = {}
        self.m_pServerArrayFL = {}
    end
    return self.instance
end

function ASMJ_CServerManager:ReleaseInstance()
    print("ASMJ_CServerManager:ReleaseInstance")
    if self.instance then
        self.instance = nil
    end
end

function ASMJ_CServerManager:UpdataServerList(msgcmd)
    print("ASMJ_CServerManager.instance:UpdataServerList")

    local iRoomCount = msgcmd:getLen()/278

    for i=1,iRoomCount do

        self.m_pServerArray[i] = {}

        self.m_pServerArray[i].wKindID = msgcmd:readWORD()
        self.m_pServerArray[i].wNodeID = msgcmd:readWORD()
        self.m_pServerArray[i].wSortID = msgcmd:readWORD()
        self.m_pServerArray[i].wServerID = msgcmd:readWORD()
        self.m_pServerArray[i].wClassifyID = msgcmd:readWORD()
        self.m_pServerArray[i].wWelfareID = msgcmd:readWORD()
        self.m_pServerArray[i].wServerPort = msgcmd:readWORD()
        self.m_pServerArray[i].wServerType = msgcmd:readWORD()

        self.m_pServerArray[i].dwServerRule = msgcmd:readDWORD()
        self.m_pServerArray[i].dwOnLineCount = msgcmd:readDWORD()
        self.m_pServerArray[i].dwOnLineMobileCount = msgcmd:readDWORD()
        self.m_pServerArray[i].dwOnLinePCCount = msgcmd:readDWORD()
        self.m_pServerArray[i].dwOnLineCountEx = msgcmd:readDWORD()
        self.m_pServerArray[i].dwFullCount = msgcmd:readDWORD()
        self.m_pServerArray[i].dwServerAddr = msgcmd:readDWORD()

        self.m_pServerArray[i].lCellScore = msgcmd:readLONG()
        self.m_pServerArray[i].lMinEnterScore = msgcmd:readLONGLONG()

        self.m_pServerArray[i].szKeyWord = CMCipher:g2u_forlua(msgcmd:readChars(20), 20)
        self.m_pServerArray[i].szServerName = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)
        self.m_pServerArray[i].WelfareName = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)

        self.m_pServerArray[i].dwMatchID = msgcmd:readDWORD()
        self.m_pServerArray[i].cbAllowMinMember = msgcmd:readBYTE()
        self.m_pServerArray[i].cbAllowMaxMember = msgcmd:readBYTE()
        self.m_pServerArray[i].cbAllowMatchUser = msgcmd:readBYTE()
        self.m_pServerArray[i].cbAllowMemberUser = msgcmd:readBYTE()

        self.m_pServerArray[i].lMatchGoldCount = msgcmd:readLONGLONG()
        self.m_pServerArray[i].lMatchMedalCount = msgcmd:readLONGLONG()
        self.m_pServerArray[i].lMatchTiketCount = msgcmd:readLONGLONG()

        self.m_pServerArray[i].dwAllowMinExperience = msgcmd:readDWORD()
        self.m_pServerArray[i].dwAllowMaxExperience = msgcmd:readDWORD()

        self.m_pServerArray[i].cbServiceDay = {}
        for j=1,7 do
            self.m_pServerArray[i].cbServiceDay[j] = msgcmd:readBYTE()
        end

        self.m_pServerArray[i].cbLoopServiceMode = msgcmd:readBYTE()

        self.m_pServerArray[i].dwServiceTimeStart = msgcmd:readDWORD()
        self.m_pServerArray[i].dwServiceTimeClose = msgcmd:readDWORD()

        self.m_pServerArray[i].dwMatchClock = {}
        for j=1,20 do
            self.m_pServerArray[i].dwMatchClock[j] = msgcmd:readDWORD()
        end
        self.m_pServerArray[i].cbMatchMode = msgcmd:readBYTE()
        self.m_pServerArray[i].cbRoomType = msgcmd:readBYTE()


    end


    if #self.m_pServerArrayXS == 0 then
        local iCount = 0
        for i=1,#self.m_pServerArray do
            if self.m_pServerArray[i].cbRoomType == 0 and bit:_and(self.m_pServerArray[i].wServerType, GAME_GENRE_MATCH) == 0 then
                iCount = iCount + 1
                self.m_pServerArrayXS[iCount] = self.m_pServerArray[i]
            end
        end
        table.sort(self.m_pServerArrayXS, function(a,b) return a.wSortID < b.wSortID end)
    end

    if #self.m_pServerArrayFL == 0 then
        local iCount = #self.m_pServerArrayFL
        for i=1,#self.m_pServerArray do
            if bit:_and(self.m_pServerArray[i].wServerType, GAME_GENRE_MATCH) ~= 0 then
                iCount = iCount + 1
                self.m_pServerArrayFL[iCount] = self.m_pServerArray[i]
            end
        end
        table.sort(self.m_pServerArrayFL, function(a,b) return a.wSortID < b.wSortID end)
    end

    if #self.m_pServerArrayCG == 0 then
        local iCount = 0
        for i=1,#self.m_pServerArray do
            if self.m_pServerArray[i].cbRoomType == 1 then
                iCount = iCount + 1
                self.m_pServerArrayCG[iCount] = self.m_pServerArray[i]
                self.m_pServerArrayCG[iCount].m_iType = ERT_CJ_316
            elseif self.m_pServerArray[i].cbRoomType == 2 then
                iCount = iCount + 1
                self.m_pServerArrayCG[iCount] = self.m_pServerArray[i]
                self.m_pServerArrayCG[iCount].m_iType = ERT_GJ_316
            end
        end
        table.sort(self.m_pServerArrayCG, function(a,b) return a.cbRoomType < b.cbRoomType end)
        table.sort(self.m_pServerArrayCG, function(a,b) return a.wSortID < b.wSortID end)

        --xs room
        if self:GetRoomXSCount() > 0 then
            table.insert(self.m_pServerArrayCG, 1, {})
            self.m_pServerArrayCG[1].m_iType = ERT_XS_316
        end
        
        --fl room
        if self:GetRoomFLCount() > 0 then
            table.insert(self.m_pServerArrayCG, #self.m_pServerArrayCG+1, {})
            self.m_pServerArrayCG[#self.m_pServerArrayCG].m_iType = ERT_FL_316
        end
    end
end

-----------------------------------
function ASMJ_CServerManager:GetRoomXSCount()
    return #self.m_pServerArrayXS
end

function ASMJ_CServerManager:GetRoomXSItem(index)
    if (index > #self.m_pServerArrayXS) then
        return nil
    end
    return self.m_pServerArrayXS[index]
end

function ASMJ_CServerManager:GetRoomCGCount()
    return #self.m_pServerArrayCG
end

function ASMJ_CServerManager:GetRoomCGItem(index)
    if (index > #self.m_pServerArrayCG) then
        return nil
    end
    return self.m_pServerArrayCG[index]
end

function ASMJ_CServerManager:GetRoomFLCount()
    return #self.m_pServerArrayFL
end

function ASMJ_CServerManager:GetRoomFLItem(index)
    if (index > #self.m_pServerArrayFL) then
        return nil
    end
    return self.m_pServerArrayFL[index]
end

--onclick index--------------------------------------------------
function ASMJ_CServerManager:SetOnClickRoomType(iType)
    self.iRoomType = iType
end

function ASMJ_CServerManager:GetOnClickRoomType()
    return self.iRoomType
end

function ASMJ_CServerManager:SetEntryRoomStatus(iStatus)
    self.iEntryRoomStatus = iStatus
end

function ASMJ_CServerManager:GetEntryRoomStatus()
    return self.iEntryRoomStatus
end


function ASMJ_CServerManager:SetOnClickRoomIndex(iIndex)
    self.iRoomIndex = iIndex
end

function ASMJ_CServerManager:GetOnClickRoomIndex()
    return self.iRoomIndex
end
