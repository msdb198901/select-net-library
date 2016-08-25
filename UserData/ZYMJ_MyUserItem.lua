ASMJ_MyUserItem = class("ASMJ_MyUserItem", nil)

function ASMJ_MyUserItem:new(o)
    print("ASMJ_MyUserItem:new")
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function ASMJ_MyUserItem:GetInstance()
    if self.instance == nil then
        self.instance = self:new()
        self:Reset()
    end
    return self.instance
end

function ASMJ_MyUserItem:ReleaseInstance()
    print("ASMJ_MyUserItem:ReleaseInstance")
    if self.instance then
        self.instance = nil
    end
end

function ASMJ_MyUserItem:GetMyUserData()
    return self
end

function ASMJ_MyUserItem:Reset()
   
    self.dwUserID = 0                      
    self.dwGameID = 0                     
    self.dwGroupID = 0                   
    self.szNickName = ""    
    self.szAccounts = ""
    self.szPassword = ""
    self.szGroupName = ""      
    self.szUnderWrite = ""       
    self.wFaceID  = 0                            
    self.dwCustomID  = 0                        

    self.cbGender  = 0 
    self.cbHaveBindMobilePhone = 0
    self.cbHaveSetLogonPassword= 0
    self.isVip = false                         
    self.cbMemberKind  = 0                      
    self.cbMemberOrder = 0                      
    self.cbMasterOrder  = 0                     
    self.dwMemberPoint  = 0  

    self.MemberOverDate = {}
    self.MemberOverDate.wYear = 0
    self.MemberOverDate.wMonth = 0
    self.MemberOverDate.wDayOfWeek = 0
    self.MemberOverDate.wDay = 0
    self.MemberOverDate.wHour = 0
    self.MemberOverDate.wMinute = 0
    self.MemberOverDate.wSecond = 0
    self.MemberOverDate.wMilliseconds = 0

    self.wTableID  = 0                          
    self.wLastGameTableID  = 0                  
    self.wChairID = 0                       
    self.cbUserStatus = 0                       
    self.cbAndroidUser = 0                      
    self.cbGameHallOfFame = 0                   
    self.cbMemberHallOfFame = 0                 

    self.lScore = 0                             
    self.lGrade = 0                             
    self.lGoldA = 0                             
    self.lInsure = 0                                               
    self.lUserIngot = 0                         

    self.dwRankScore = 0                        
    self.dwWinCount = 0                         
    self.dwLostCount = 0                        
    self.dwDrawCount = 0                        
    self.dwFleeCount = 0                        
    self.dwUserMedal = 0                        
    self.dwExperience = 0                       
    self.dwMatchTiket = 0                       
    self.lLoveLiness = 0                        

    self.TimerInfo = {}
    self.TimerInfo.dwEnterTableTimer = 0    
    self.TimerInfo.dwLeaveTableTimer = 0    
    self.TimerInfo.dwStartGameTimer = 0    
    self.TimerInfo.dwEndGameTimer = 0    
 
    self.cbMobileUser = 0

    ------------------offline--------------------
    self.OffLine = {}
    self.OffLine.cbGameStatus = 0

    self.OffLine.lCellScore  = 0
    self.OffLine.wBankerUser = 0            
    self.OffLine.wCurrentUser= 0
    self.OffLine.wTimeCount  = 0

    self.OffLine.wFirstChickenUser  = 0
    
    self.OffLine.cbFirstChicken = 0
    self.OffLine.cbActionCard   = 0
    self.OffLine.cbActionMask   = 0
    self.OffLine.cbLeftCardCount= 0
    self.OffLine.wOutCardUser   = 0
    self.OffLine.cbOutCardData  = 0
    self.OffLine.cbCardCount    = 0
    self.OffLine.cbSendCardData = 0
    
    self.OffLine.bTrustee = {}
    self.OffLine.cbHearStatus = {}
    self.OffLine.cbDiscardCount = {}
    self.OffLine.cbDiscardCard  = {}
    self.OffLine.cbCardData     = {}
    self.OffLine.cbWeaveCount   = {}
    self.OffLine.WeaveItemArray = {}

    for i=1,GAME_PLAYER_316 do
        self.OffLine.cbDiscardCard[i] = {}
        self.OffLine.WeaveItemArray[i] = {}
        for j=1,MAX_WEAVE_316 do
            self.OffLine.WeaveItemArray[i][j] = {}
            self.OffLine.WeaveItemArray[i][j].cbWeaveKind     = 0
            self.OffLine.WeaveItemArray[i][j].cbCenterCard   = 0
            self.OffLine.WeaveItemArray[i][j].cbPublicCard    = 0
            self.OffLine.WeaveItemArray[i][j].wProvideUser    = 0
            self.OffLine.WeaveItemArray[i][j].cbCardData      = {}
            for z=1,4 do
                self.OffLine.WeaveItemArray[i][j].cbCardData[z] = 0
            end
       end
    end

    -----------------onfastMode------------------
    self.dwFastGameCount = 0
    self.lFastGoldCount = 0
    self.lFastMedalCount = 0

    -----------------onMatchMode------------------
    self.cbMatchStatus = 0
    self.dwMatchCurrentServerTime = 0
    self.dwMatchCurrentLocalTime = 0

    self.MatchAttribute = {}
    self.MatchAttribute.dwMatchID = 0
    self.MatchAttribute.dwMatchNo = 0
    self.MatchAttribute.dwCurStartTime = 0
    self.MatchAttribute.dwNextStartTime = 0
    self.MatchAttribute.dwMatchStartTime = 0
    self.MatchAttribute.dwMatchTime = 0
    self.MatchAttribute.wMatchSenceIndex = 0
    self.MatchAttribute.dwTotalCount = 0
    self.MatchAttribute.dwEndCount = 0
    self.MatchAttribute.dwPromtCount = 0
    self.MatchAttribute.dwCurRank = 0
    self.MatchAttribute.dwTableRank = 0
    self.MatchAttribute.wGameCount = 0
    self.MatchAttribute.wContiunePlayCount = 0
    self.MatchAttribute.dwSurviveRewardTime = 0
    self.MatchAttribute.dwNowBaseScore = 0
    self.MatchAttribute.dwPlayTableCount = 0
    self.MatchAttribute.dwResurrectionCostGold = 0
    self.MatchAttribute.dwResurrectionScore = 0

    self.MatchAttribute.dwUserIDArry = {}
    self.MatchAttribute.wRankArry = {}
    self.MatchAttribute.dwOtherCurRank = {}
    for i=1,GAME_PLAYER_316 do
         self.MatchAttribute.dwUserIDArry[i] = 0
         self.MatchAttribute.wRankArry[i] = 0
         self.MatchAttribute.dwOtherCurRank[i]= 0
    end
    ---------------------------------
end

-------------------------------------------------------
function ASMJ_MyUserItem:SwitchViewChairID(chair)
    local wMeChairID =  self:GetChairID()
    local wViewChairID = (chair + GAME_PLAYER_316 + 2 - wMeChairID)%GAME_PLAYER_316  + 1
    return wViewChairID
end

function ASMJ_MyUserItem:UpdataDeskUserItem()
    self.myDeskUserItem = {}
    local wTableID = self:GetTableID()
    for i=1,GAME_PLAYER_316 do
        local UserItem = ASMJ_ClientUserManager:GetInstance():SeachTableUserItem(wTableID, i)

        if not UserItem then
            return i
        end

        local viewChairID = self:SwitchViewChairID(UserItem.wChairID)
        self.myDeskUserItem[viewChairID] = UserItem
    end

    return GAME_PLAYER_316
end

function ASMJ_MyUserItem:GetClientUserItem(id)
    
    if id > GAME_PLAYER_316 then
        return nil
    end
    return self.myDeskUserItem[id]
end
---------------------------------------
function ASMJ_MyUserItem:SetUserID(dwUserID)
    self.dwUserID = dwUserID
end
 
function ASMJ_MyUserItem:SetGameID(dwGameID)
    self.dwGameID = dwGameID
end

function ASMJ_MyUserItem:SetGroupID(dwGroupID)
    self.dwGroupID = dwGroupID
end

function ASMJ_MyUserItem:SetNickName(szNickName)
    self.szNickName = szNickName
end

function ASMJ_MyUserItem:SetGroupName(szGroupName)
    self.szGroupName = szGroupName
end

function ASMJ_MyUserItem:SetUnderWrite(szUnderWrite)
    self.szUnderWrite = szUnderWrite
end

function ASMJ_MyUserItem:SetFaceID(wFaceID)
    self.wFaceID = wFaceID
end

function ASMJ_MyUserItem:SetCustomID(dwCustomID)
    self.dwCustomID = dwCustomID
end

function ASMJ_MyUserItem:SetGender(cbGender)
    self.cbGender = cbGender
end

function ASMJ_MyUserItem:SetMemberKind(cbMemberKind)
    self.cbMemberKind = cbMemberKind
end

function ASMJ_MyUserItem:SetMemberOrder(cbMemberOrder)
    self.cbMemberOrder = cbMemberOrder
end

function ASMJ_MyUserItem:SetMasterOrder(cbMasterOrder)
    self.cbMasterOrder = cbMasterOrder
end

function ASMJ_MyUserItem:SetMemberPoint(dwMemberPoint)
    self.dwMemberPoint = dwMemberPoint
end

function ASMJ_MyUserItem:SetMemberOverDate(MemberOverDate)
    self.MemberOverDate = MemberOverDate
end

function ASMJ_MyUserItem:SetTableID(wTableID)
    self.wTableID = wTableID
end

function ASMJ_MyUserItem:SetLastGameTableID(wLastGameTableID)
    self.wLastGameTableID = wLastGameTableID
end

function ASMJ_MyUserItem:SetChairID(wChairID)
    self.wChairID = wChairID
end

function ASMJ_MyUserItem:SetUserStatus(cbUserStatus)
    self.cbUserStatus = cbUserStatus
end

function ASMJ_MyUserItem:SetAndroidUser(cbAndroidUser)
    self.cbAndroidUser = cbAndroidUser
end

function ASMJ_MyUserItem:SetGameHallOfFame(cbGameHallOfFame)
    self.cbGameHallOfFame = cbGameHallOfFame
end

function ASMJ_MyUserItem:SetMemberHallOfFame(cbMemberHallOfFame)
    self.cbMemberHallOfFame = cbMemberHallOfFame
end

function ASMJ_MyUserItem:SetScore(lScore)
    self.lScore = lScore
end

function ASMJ_MyUserItem:SetGrade(lGrade)
    self.lGrade = lGrade
end

function ASMJ_MyUserItem:SetGoldA(lGoldA)
    self.lGoldA = lGoldA
end

function ASMJ_MyUserItem:SetInsure(lInsure)
    self.lInsure = lInsure
end

function ASMJ_MyUserItem:SetUserIngot(lUserIngot)
    self.lUserIngot = lUserIngot
end

function ASMJ_MyUserItem:SetWinCount(dwWinCount)
    self.dwWinCount = dwWinCount
end

function ASMJ_MyUserItem:SetLostCount(dwLostCount)
    self.dwLostCount = dwLostCount
end

function ASMJ_MyUserItem:SetDrawCount(dwDrawCount)
    self.dwDrawCount = dwDrawCount
end

function ASMJ_MyUserItem:SetFleeCount(dwFleeCount)
    self.dwFleeCount = dwFleeCount
end

function ASMJ_MyUserItem:SetUserMedal(dwUserMedal)
    self.dwUserMedal = dwUserMedal
end

function ASMJ_MyUserItem:SetExperience(dwExperience)
    self.dwExperience = dwExperience
end

function ASMJ_MyUserItem:SetMatchTiket(dwMatchTiket)
    self.dwMatchTiket = dwMatchTiket
end

function ASMJ_MyUserItem:SetLoveLiness(lLoveLiness)
    self.lLoveLiness = lLoveLiness
end


function ASMJ_MyUserItem:SetTimerInfo(TimerInfo)
    self.TimerInfo = TimerInfo
end

--------------------------------------
function ASMJ_MyUserItem:GetUserID()
    return self.dwUserID
end
 
function ASMJ_MyUserItem:GetGameID()
    return self.dwGameID
end

function ASMJ_MyUserItem:GetGroupID()
    return self.dwGroupID
end

function ASMJ_MyUserItem:GetNickName()
    return self.szNickName
end

function ASMJ_MyUserItem:GetAccounts()
    return self.szAccounts
end

function ASMJ_MyUserItem:GetPassword()
    return self.szPassword
end

function ASMJ_MyUserItem:GetGroupName()
    return self.szGroupName
end

function ASMJ_MyUserItem:GetUnderWrite()
    return self.szUnderWrite
end

function ASMJ_MyUserItem:GetFaceID()
    return self.wFaceID
end

function ASMJ_MyUserItem:GetCustomID()
    return self.dwCustomID
end

function ASMJ_MyUserItem:GetGender()
    return self.cbGender
end

function ASMJ_MyUserItem:GetMemberKind()
    return self.cbMemberKind
end

function ASMJ_MyUserItem:GetMemberOrder()
    return self.cbMemberOrder
end

function ASMJ_MyUserItem:GetMasterOrder()
    return self.cbMasterOrder
end

function ASMJ_MyUserItem:GetMemberPoint()
    return self.dwMemberPoint
end

function ASMJ_MyUserItem:GetMemberOverDate()
    return self.MemberOverDate
end

function ASMJ_MyUserItem:GetTableID()
    return self.wTableID
end

function ASMJ_MyUserItem:GetLastGameTableID()
    return self.wLastGameTableID
end

function ASMJ_MyUserItem:GetChairID()
    return self.wChairID
end

function ASMJ_MyUserItem:GetUserStatus()
    return self.cbUserStatus
end

function ASMJ_MyUserItem:GetAndroidUser()
    return self.cbAndroidUser
end

function ASMJ_MyUserItem:GetGameHallOfFame()
    return self.cbGameHallOfFame
end

function ASMJ_MyUserItem:GetMemberHallOfFame()
    return self.cbMemberHallOfFame
end

function ASMJ_MyUserItem:GetScore()
    return self.lScore
end

function ASMJ_MyUserItem:GetGrade()
    return self.lGrade
end

function ASMJ_MyUserItem:GetGoldA()
    return self.lGoldA
end

function ASMJ_MyUserItem:GetInsure()
    return self.lInsure
end

function ASMJ_MyUserItem:GetUserIngot()
    return self.lUserIngot
end

function ASMJ_MyUserItem:GetRankScore()
    return self.dwRankScore
end

function ASMJ_MyUserItem:GetWinCount()
    return self.dwWinCount
end

function ASMJ_MyUserItem:GetLostCount()
    return self.dwLostCount
end

function ASMJ_MyUserItem:GetDrawCount()
    return self.dwDrawCount
end

function ASMJ_MyUserItem:GetFleeCount()
    return self.dwFleeCount
end

function ASMJ_MyUserItem:GetUserMedal()
    return self.dwUserMedal
end

function ASMJ_MyUserItem:GetExperience()
    return self.dwExperience
end

function ASMJ_MyUserItem:GetMatchTiket()
    return self.dwMatchTiket
end

function ASMJ_MyUserItem:GetLoveLiness()
    return self.lLoveLiness
end


function ASMJ_MyUserItem:GetTimerInfo()
    return self.TimerInfo
end

function ASMJ_MyUserItem:GetMobileUser()
    return self.cbMobileUser
end

-----------offline---------------
function ASMJ_MyUserItem:GetOffLine()
    return self.OffLine
end

function ASMJ_MyUserItem:SetOffLine(msgcmd)
    
    -- read scene data
    self.OffLine.lCellScore           =  msgcmd:readLONGLONG()
                                         msgcmd:readWORD()
    self.OffLine.wBankerUser          =  msgcmd:readWORD() + 1                    
    self.OffLine.wCurrentUser         =  msgcmd:readWORD() + 1
    self.OffLine.wTimeCount           =  msgcmd:readWORD()

    self.OffLine.wFirstChickenUser    =  msgcmd:readWORD() + 1
    
    self.OffLine.cbFirstChicken       =  msgcmd:readBYTE()
                                         msgcmd:readBYTE()
                                         msgcmd:readBYTE()
                                         msgcmd:readBYTE()
                                         msgcmd:readBYTE()

    self.OffLine.cbActionCard         =  msgcmd:readBYTE()
    self.OffLine.cbActionMask         =  msgcmd:readBYTE()
    
    self.OffLine.cbHearStatus         = {}
    for i=1,GAME_PLAYER_316 do
        self.OffLine.cbHearStatus[i]  =  msgcmd:readBYTE()
    end

    self.OffLine.cbLeftCardCount      =  msgcmd:readBYTE()

    self.OffLine.bTrustee             = {}
    for i=1,GAME_PLAYER_316 do
        self.OffLine.bTrustee[i]      =  msgcmd:readBYTE()
    end

    self.OffLine.wOutCardUser         =  msgcmd:readWORD() + 1
    self.OffLine.cbOutCardData        =  msgcmd:readBYTE()
    self.OffLine.cbDiscardCount       = {}
    for i=1,GAME_PLAYER_316 do
        self.OffLine.cbDiscardCount[i]=  msgcmd:readBYTE()
    end

    self.OffLine.cbDiscardCard        = {}
    for i=1,GAME_PLAYER_316 do
        self.OffLine.cbDiscardCard[i] = {}
        for j=1,60 do
            self.OffLine.cbDiscardCard[i][j] =  msgcmd:readBYTE()
        end
    end

    self.OffLine.cbCardCount          = msgcmd:readBYTE()
    self.OffLine.cbCardData           = {}
    for i=1,MAX_COUNT_316 do
        self.OffLine.cbCardData[i]    =  msgcmd:readBYTE()
    end

    self.OffLine.cbSendCardData       =  msgcmd:readBYTE()
    self.OffLine.cbWeaveCount         = {}
    for i=1,GAME_PLAYER_316 do
        self.OffLine.cbWeaveCount[i]  =  msgcmd:readBYTE()
    end

    self.OffLine.WeaveItemArray       = {}
    for i=1,GAME_PLAYER_316 do
        self.OffLine.WeaveItemArray[i]= {}
        for j=1,MAX_WEAVE_316 do
            self.OffLine.WeaveItemArray[i][j] = {}
            self.OffLine.WeaveItemArray[i][j].cbWeaveKind     = msgcmd:readBYTE()
            self.OffLine.WeaveItemArray[i][j].cbCenterCard    = msgcmd:readBYTE()
            self.OffLine.WeaveItemArray[i][j].cbPublicCard    = msgcmd:readBYTE()
            self.OffLine.WeaveItemArray[i][j].wProvideUser    = msgcmd:readWORD() + 1
            self.OffLine.WeaveItemArray[i][j].cbCardData      = {}
            for z=1,GAME_PLAYER_316 do
                self.OffLine.WeaveItemArray[i][j].cbCardData[z] = msgcmd:readBYTE()
            end
        end
    end
end

-----------onfastmode--------------
function ASMJ_MyUserItem:SetFastGameCount(dwFastGameCount)
    self.dwFastGameCount = dwFastGameCount
end

function ASMJ_MyUserItem:SetFastGoldCount(lFastGoldCount)
    self.lFastGoldCount = lFastGoldCount
end

function ASMJ_MyUserItem:SetFastMedalCount(lFastMedalCount)
    self.lFastMedalCount = lFastMedalCount
end

function ASMJ_MyUserItem:GetFastGameCount()
    return self.dwFastGameCount
end

function ASMJ_MyUserItem:GetFastGoldCount()
    return self.lFastGoldCount
end

function ASMJ_MyUserItem:GetFastMedalCount()
    return self.lFastMedalCount
end

-----------onmatchmode--------------
function ASMJ_MyUserItem:SetMatchStatus(cbMatchStatus)
    self.cbMatchStatus = cbMatchStatus
end

function ASMJ_MyUserItem:SetMatchCurrentServerTime(dwMatchCurrentServerTime)
    self.dwMatchCurrentServerTime = dwMatchCurrentServerTime
end

function ASMJ_MyUserItem:SetMatchCurrentLocalTime(dwMatchCurrentLocalTime)
    self.dwMatchCurrentLocalTime = dwMatchCurrentLocalTime
end

function ASMJ_MyUserItem:GetMatchStatus()
    return self.cbMatchStatus
end

function ASMJ_MyUserItem:GetMatchCurrentServerTime()
    return self.dwMatchCurrentServerTime
end

function ASMJ_MyUserItem:GetMatchCurrentLocalTime()
    return self.dwMatchCurrentLocalTime
end

function ASMJ_MyUserItem:GetMatchAttribute()
    return self.MatchAttribute
end

--------------------------------------
function ASMJ_MyUserItem:UpdataItem_Cmd(msgcmd)
    
    local dwGameID = msgcmd:readDWORD()
    local dwUserID = msgcmd:readDWORD()

    self.dwGameID = dwGameID                 
    self.dwUserID = dwUserID                 
    self.dwGroupID = msgcmd:readDWORD()                

    self.wFaceID = msgcmd:readWORD()                    
    self.dwCustomID = msgcmd:readDWORD()                 

    self.cbGender = msgcmd:readBYTE()                   
    self.cbMemberKind = msgcmd:readBYTE()               
    self.cbMemberOrder = msgcmd:readBYTE()             
    self.cbMasterOrder = msgcmd:readBYTE()              
    self.dwMemberPoint = msgcmd:readDWORD() 

    self.MemberOverDate = {}
    self.MemberOverDate.wYear = msgcmd:readWORD() 
    self.MemberOverDate.wMonth = msgcmd:readWORD()
    self.MemberOverDate.wDayOfWeek = msgcmd:readWORD()
    self.MemberOverDate.wDay = msgcmd:readWORD()
    self.MemberOverDate.wHour = msgcmd:readWORD()
    self.MemberOverDate.wMinute = msgcmd:readWORD()
    self.MemberOverDate.wSecond = msgcmd:readWORD()
    self.MemberOverDate.wMilliseconds = msgcmd:readWORD()

    self.wTableID = msgcmd:readWORD()                 
    self.wChairID = msgcmd:readWORD() + 1                  
    self.cbUserStatus = msgcmd:readBYTE()               
    self.cbAndroidUser = msgcmd:readBYTE()              

    self.cbGameHallOfFame = msgcmd:readBYTE()            
    self.cbMemberHallOfFame = msgcmd:readBYTE()          

    self.lScore = msgcmd:readLONGLONG()                      
    self.lGrade = msgcmd:readLONGLONG()                      
    self.lGoldA = msgcmd:readLONGLONG()                                         
    self.lInsure = msgcmd:readLONGLONG()                    
    self.lUserIngot = msgcmd:readLONGLONG()                 

    self.dwRankScore = msgcmd:readDWORD()               
    self.dwWinCount = msgcmd:readDWORD()                 
    self.dwLostCount = msgcmd:readDWORD()                 
    self.dwDrawCount = msgcmd:readDWORD()                
    self.dwFleeCount = msgcmd:readDWORD()                 
    self.dwUserMedal = msgcmd:readDWORD()                 
    self.dwExperience = msgcmd:readDWORD()                
    self.dwMatchTiket = msgcmd:readDWORD()                
    self.lLoveLiness = msgcmd:readLONG()                 

    self.cbMobileUser = msgcmd:readBYTE()          

    --off 4
    msgcmd:readDWORD()
    self.szNickName = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)

end
