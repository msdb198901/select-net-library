MK_NULL_316                 = 0
MK_OutCard_316              = 1
MK_SendCard_316             = 2
MK_StartCard_316            = 3
MK_ShowCard_316             = 4
MK_OrbitCard_316            = 5

local ASMJ_CMoveCardItem = class("ASMJ_CMoveCardItem")
--create( ... )ASMJ_CMoveCardItem_create
function ASMJ_CMoveCardItem_create()
    local ASMJ_CMoveCardItem = ASMJ_CMoveCardItem.new()
    return ASMJ_CMoveCardItem
end

--ctor()
function ASMJ_CMoveCardItem:ctor()
    self.m_MoveKind = MK_NULL_316
end

function ASMJ_CMoveCardItem:GetMoveKind()
    return self.m_MoveKind
end


local ASMJ_COutCardItem = class("ASMJ_COutCardItem", ASMJ_CMoveCardItem)
--create( ... )ASMJ_CMoveCardItem_create
function ASMJ_COutCardItem_create()
    local ASMJ_COutCardItem = ASMJ_COutCardItem.new()
    return ASMJ_COutCardItem
end

--ctor()
function ASMJ_COutCardItem:ctor()
    self.m_MoveKind = MK_OutCard_316
    self.m_wOutCardUser =  INVALID_CHAIR
    self.m_cbOutCardData =  0
    self.m_cbFirstChicken =  0  
    self.m_ptOrigin = cc.p(0,0)
end

--SetOutCardItem()
function ASMJ_COutCardItem:SetOutCardItem(pOutCard)
    self.m_MoveKind = MK_OutCard_316
    self.m_wOutCardUser = pOutCard.wOutCardUser
    self.m_cbOutCardData = pOutCard.cbOutCardData
    self.m_cbFirstChicken = pOutCard.cbFirstChicken
    self.m_ptOrigin = pOutCard.ptOrigin
end

local ASMJ_CSendCardItem = class("ASMJ_CSendCardItem", ASMJ_CMoveCardItem)
--create( ... )ASMJ_CMoveCardItem_create
function ASMJ_CSendCardItem_create()
    local ASMJ_CSendCardItem = ASMJ_CSendCardItem.new()
    return ASMJ_CSendCardItem
end

--ctor()
function ASMJ_CSendCardItem:ctor()
    self.m_MoveKind = MK_SendCard_316  
    self.m_cbCardData = 0  
    self.m_cbActionMask = 0
    self.m_wCurrentUser = INVALID_CHAIR_316
    self.m_wSendCardUser = INVALID_CHAIR_316
    self.m_bTail = 0
end

--SetSendCardItem()
function ASMJ_CSendCardItem:SetSendCardItem(pSendCard)
    self.m_MoveKind = MK_SendCard_316
    self.m_cbCardData = pSendCard.cbCardData
    self.m_cbActionMask = pSendCard.cbActionMask
    self.m_wCurrentUser = pSendCard.wCurrentUser
    self.m_wSendCardUser = pSendCard.wSendCardUser
    self.m_bTail = pSendCard.bTail
end

local ASMJ_CShowCardItem = class("ASMJ_CShowCardItem", ASMJ_CMoveCardItem)
--create( ... )ASMJ_CMoveCardItem_create
function ASMJ_CShowCardItem_create()
    local ASMJ_CShowCardItem = ASMJ_CShowCardItem.new()
    return ASMJ_CShowCardItem
end

--ctor()
function ASMJ_CShowCardItem:ctor()
    self.m_MoveKind = MK_ShowCard_316
    self.m_cbCardData = 0
end

--SetSendCardItem()
function ASMJ_CShowCardItem:SetShowCardItem(cbCardData)
    self.m_MoveKind = MK_ShowCard_316
    self.m_cbCardData = cbCardData
end

local ASMJ_CStartCardItem = class("ASMJ_CStartCardItem", ASMJ_CMoveCardItem)
--create( ... )ASMJ_CMoveCardItem_create
function ASMJ_CStartCardItem_create()
    local ASMJ_CStartCardItem = ASMJ_CStartCardItem.new()
    return ASMJ_CStartCardItem
end

--ctor()
function ASMJ_CStartCardItem:ctor()
    self.m_MoveKind = MK_StartCard_316

    self.m_wChairID = INVALID_CHAIR_316
    self.m_cbCardCount = 0  
    self.m_cbCardData = {}
    self.m_wHeapID = INVALID_CHAIR_316
    self.m_wHeapCardIndex = 0
    self.m_bLastItem = false
end


local ASMJ_COrbitCardItem = class("ASMJ_COrbitCardItem", ASMJ_CMoveCardItem)
--create( ... )ASMJ_CMoveCardItem_create
function ASMJ_COrbitCardItem_create()
    local ASMJ_COrbitCardItem = ASMJ_COrbitCardItem.new()
    return ASMJ_COrbitCardItem
end

--ctor()
function ASMJ_COrbitCardItem:ctor()
    self.m_MoveKind = MK_OrbitCard_316
    self.m_cbCardData = {}
    self.m_cbProvideMJ = 0
    self.m_cbCardCount = 0

end

--SetSendCardItem()
function ASMJ_COrbitCardItem:SetOrbitCardItem(cbCardData, cbCardCount, cbProvideMJ)
    self.m_MoveKind = MK_OrbitCard_316
    self.m_cbProvideMJ = cbProvideMJ
    self.m_cbCardCount = cbCardCount
    for i=1,#cbCardData do
        self.m_cbCardData[i] = cbCardData[i]
    end
end