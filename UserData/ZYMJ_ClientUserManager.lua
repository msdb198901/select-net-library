ASMJ_ClientUserManager = class("ASMJ_ClientUserManager", nil)

function ASMJ_ClientUserManager:new(o)
    print("ASMJ_ClientUserManager:new")
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function ASMJ_ClientUserManager:GetInstance()
    if self.instance == nil then
        self.instance = self:new()

        self.UserItem = {}
    end
    return self.instance
end

function ASMJ_ClientUserManager:ReleaseInstance()
    print("ASMJ_ClientUserManager:ReleaseInstance")
    if self.instance then
        self.instance = nil
    end
end

function ASMJ_ClientUserManager:SeachByUserID(dwUserID)
    print("ASMJ_ClientUserManager:SeachByUserID", dwUserID)
    for i=1,#self.UserItem do
        if self.UserItem[i].dwUserID == dwUserID then
            return self.UserItem[i]
        end
    end
    return nil
end

function ASMJ_ClientUserManager:SeachTableUserItem(table, chair)
    
    if table ~= INVALID_TABLE_316 and chair ~= INVALID_CHAIR_316 then
        for i=1,#self.UserItem do
            if  self.UserItem[i] and
                self.UserItem[i].dwUserID ~= 0 and 
                self.UserItem[i].wTableID == table and 
                self.UserItem[i].wChairID == chair then

                return self.UserItem[i]
            end
        end
    end

    return nil
end

function ASMJ_ClientUserManager:UpdataItem_Cmd(msgcmd)

    local dwGameID = msgcmd:readDWORD()
    local dwUserID = msgcmd:readDWORD()

    local iUserItemCount = #self.UserItem
    local UserItem = self:SeachByUserID(dwUserID)
    if UserItem == nil then
        iUserItemCount = iUserItemCount + 1
        self.UserItem[iUserItemCount] = {}
    else
        --- find half of the day
        for i=1,iUserItemCount do
            if self.UserItem[i].dwUserID == dwUserID then
                iUserItemCount = i
                break
            end
        end
    end

    self.UserItem[iUserItemCount].dwGameID = dwGameID                 
    self.UserItem[iUserItemCount].dwUserID = dwUserID                 
    self.UserItem[iUserItemCount].dwGroupID = msgcmd:readDWORD()                

    self.UserItem[iUserItemCount].wFaceID = msgcmd:readWORD()                    
    self.UserItem[iUserItemCount].dwCustomID = msgcmd:readDWORD()                 

    self.UserItem[iUserItemCount].cbGender = msgcmd:readBYTE()                   
    self.UserItem[iUserItemCount].cbMemberKind = msgcmd:readBYTE()               
    self.UserItem[iUserItemCount].cbMemberOrder = msgcmd:readBYTE()             
    self.UserItem[iUserItemCount].cbMasterOrder = msgcmd:readBYTE()              
    self.UserItem[iUserItemCount].dwMemberPoint = msgcmd:readDWORD() 

    self.UserItem[iUserItemCount].MemberOverDate = {}
    self.UserItem[iUserItemCount].MemberOverDate.wYear = msgcmd:readWORD() 
    self.UserItem[iUserItemCount].MemberOverDate.wMonth = msgcmd:readWORD()
    self.UserItem[iUserItemCount].MemberOverDate.wDayOfWeek = msgcmd:readWORD()
    self.UserItem[iUserItemCount].MemberOverDate.wDay = msgcmd:readWORD()
    self.UserItem[iUserItemCount].MemberOverDate.wHour = msgcmd:readWORD()
    self.UserItem[iUserItemCount].MemberOverDate.wMinute = msgcmd:readWORD()
    self.UserItem[iUserItemCount].MemberOverDate.wSecond = msgcmd:readWORD()
    self.UserItem[iUserItemCount].MemberOverDate.wMilliseconds = msgcmd:readWORD()

    self.UserItem[iUserItemCount].wTableID = msgcmd:readWORD()                 
    self.UserItem[iUserItemCount].wChairID = msgcmd:readWORD() + 1                  
    self.UserItem[iUserItemCount].cbUserStatus = msgcmd:readBYTE()               
    self.UserItem[iUserItemCount].cbAndroidUser = msgcmd:readBYTE()              

    self.UserItem[iUserItemCount].cbGameHallOfFame = msgcmd:readBYTE()            
    self.UserItem[iUserItemCount].cbMemberHallOfFame = msgcmd:readBYTE()          

    self.UserItem[iUserItemCount].lScore = msgcmd:readLONGLONG()                      
    self.UserItem[iUserItemCount].lGrade = msgcmd:readLONGLONG()                      
    self.UserItem[iUserItemCount].lGoldA = msgcmd:readLONGLONG()                                         
    self.UserItem[iUserItemCount].lInsure = msgcmd:readLONGLONG()                    
    self.UserItem[iUserItemCount].lUserIngot = msgcmd:readLONGLONG()                 

    self.UserItem[iUserItemCount].dwRankScore = msgcmd:readDWORD()               
    self.UserItem[iUserItemCount].dwWinCount = msgcmd:readDWORD()                 
    self.UserItem[iUserItemCount].dwLostCount = msgcmd:readDWORD()                 
    self.UserItem[iUserItemCount].dwDrawCount = msgcmd:readDWORD()                
    self.UserItem[iUserItemCount].dwFleeCount = msgcmd:readDWORD()                 
    self.UserItem[iUserItemCount].dwUserMedal = msgcmd:readDWORD()                 
    self.UserItem[iUserItemCount].dwExperience = msgcmd:readDWORD()                
    self.UserItem[iUserItemCount].dwMatchTiket = msgcmd:readDWORD()                
    self.UserItem[iUserItemCount].lLoveLiness = msgcmd:readLONG()                 

    self.UserItem[iUserItemCount].cbMobileUser = msgcmd:readBYTE()          

    --off 4
    msgcmd:readDWORD()
    self.UserItem[iUserItemCount].szNickName = CMCipher:g2u_forlua(msgcmd:readChars(64), 64)
  
end

function ASMJ_ClientUserManager:UpdataItem_User(msgcmd)

    local iUserItemCount = #self.UserItem
    local dwUserID = msgcmd:GetUserID()

    local UserItem = self:SeachByUserID(dwUserID)
    if UserItem == nil then
        iUserItemCount = iUserItemCount + 1
        self.UserItem[iUserItemCount] = {}
    end

    self.UserItem[iUserItemCount].dwUserID = dwUserID                      
    self.UserItem[iUserItemCount].dwGameID = msgcmd:GetGameID()                     
    self.UserItem[iUserItemCount].dwGroupID = msgcmd:GetGroupID()   

    self.UserItem[iUserItemCount].szNickName = msgcmd:GetNickName()
    self.UserItem[iUserItemCount].szGroupName = msgcmd:GetGroupName()       
    self.UserItem[iUserItemCount].szUnderWrite = msgcmd:GetUnderWrite()        
    self.UserItem[iUserItemCount].wFaceID  = msgcmd:GetFaceID()                           
    self.UserItem[iUserItemCount].dwCustomID  = msgcmd:GetCustomID()                        

    self.UserItem[iUserItemCount].cbGender  = msgcmd:GetGender()                          
    self.UserItem[iUserItemCount].cbMemberKind  = msgcmd:GetMemberKind()                  
    self.UserItem[iUserItemCount].cbMemberOrder = msgcmd:GetMemberOrder()                       
    self.UserItem[iUserItemCount].cbMasterOrder  = msgcmd:GetMasterOrder()                     
    self.UserItem[iUserItemCount].dwMemberPoint  = msgcmd:GetMemberPoint()  

    self.UserItem[iUserItemCount].MemberOverDate = {}
    self.UserItem[iUserItemCount].MemberOverDate.wYear = msgcmd:GetMemberOverDate().wYear
    self.UserItem[iUserItemCount].MemberOverDate.wMonth = msgcmd:GetMemberOverDate().wMonth
    self.UserItem[iUserItemCount].MemberOverDate.wDayOfWeek = msgcmd:GetMemberOverDate().wDayOfWeek
    self.UserItem[iUserItemCount].MemberOverDate.wDay = msgcmd:GetMemberOverDate().wDay
    self.UserItem[iUserItemCount].MemberOverDate.wHour = msgcmd:GetMemberOverDate().wHour
    self.UserItem[iUserItemCount].MemberOverDate.wMinute = msgcmd:GetMemberOverDate().wMinute
    self.UserItem[iUserItemCount].MemberOverDate.wSecond = msgcmd:GetMemberOverDate().wSecond
    self.UserItem[iUserItemCount].MemberOverDate.wMilliseconds = msgcmd:GetMemberOverDate().wMilliseconds
   
    self.UserItem[iUserItemCount].wTableID  = msgcmd:GetTableID()                          
    self.UserItem[iUserItemCount].wLastGameTableID  = msgcmd:GetLastGameTableID()               
    self.UserItem[iUserItemCount].wChairID = msgcmd:GetChairID() + 1                      
    self.UserItem[iUserItemCount].cbUserStatus = msgcmd:GetUserStatus()                      
    self.UserItem[iUserItemCount].cbAndroidUser = msgcmd:GetAndroidUser()                 
    self.UserItem[iUserItemCount].cbGameHallOfFame = msgcmd:GetGameHallOfFame()                    
    self.UserItem[iUserItemCount].cbMemberHallOfFame = msgcmd:GetMemberHallOfFame()                 

    self.UserItem[iUserItemCount].lScore = msgcmd:GetScore()                         
    self.UserItem[iUserItemCount].lGrade = msgcmd:GetGrade()                       
    self.UserItem[iUserItemCount].lGoldA = msgcmd:GetGoldA()                   
    self.UserItem[iUserItemCount].lInsure = msgcmd:GetInsure()                   
    self.UserItem[iUserItemCount].lUserIngot = msgcmd:GetUserIngot()                      

    self.UserItem[iUserItemCount].dwRankScore = msgcmd:GetRankScore()               
    self.UserItem[iUserItemCount].dwWinCount = msgcmd:GetWinCount()                        
    self.UserItem[iUserItemCount].dwLostCount = msgcmd:GetLostCount()                      
    self.UserItem[iUserItemCount].dwDrawCount = msgcmd:GetDrawCount()                      
    self.UserItem[iUserItemCount].dwFleeCount = msgcmd:GetFleeCount()                       
    self.UserItem[iUserItemCount].dwUserMedal = msgcmd:GetUserMedal()                   
    self.UserItem[iUserItemCount].dwExperience = msgcmd:GetExperience()                     
    self.UserItem[iUserItemCount].dwMatchTiket = msgcmd:GetMatchTiket()                    
    self.UserItem[iUserItemCount].lLoveLiness = msgcmd:GetLoveLiness()                     

    self.UserItem[iUserItemCount].TimerInfo = {}
    self.UserItem[iUserItemCount].TimerInfo.dwEnterTableTimer = msgcmd:GetTimerInfo().dwEnterTableTimer    
    self.UserItem[iUserItemCount].TimerInfo.dwLeaveTableTimer = msgcmd:GetTimerInfo().dwLeaveTableTimer    
    self.UserItem[iUserItemCount].TimerInfo.dwStartGameTimer = msgcmd:GetTimerInfo().dwStartGameTimer    
    self.UserItem[iUserItemCount].TimerInfo.dwEndGameTimer = msgcmd:GetTimerInfo().dwEndGameTimer    

    self.UserItem[iUserItemCount].cbMobileUser = msgcmd:GetMobileUser()
end

function ASMJ_ClientUserManager:ResetList()
    self.UserItem = nil
end

function ASMJ_ClientUserManager:ResetOtherList(dwUserID)

    for i=#self.UserItem,1,-1 do
        if self.UserItem[i].dwUserID ~= dwUserID then
            table.remove(self.UserItem, i)
        end
    end

    assert(#self.UserItem == 1, "error ClientUserManager count")
    assert(self.UserItem[1].dwUserID == dwUserID, "error ClientUserManager delete")
    
    self.UserItem[1].wChairID = 65535
    self.UserItem[1].wTableID = 65535
    
    return true
end