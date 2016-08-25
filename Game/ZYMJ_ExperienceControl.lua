ASMJ_ExperienceLogic = class("ASMJ_ExperienceLogic")

EXP_COUNT_316   = 100
EXP_WEL_COUNT_316 = 23

WT_MEDAL_316    = 1    
WT_PHONE_316    = 2    
WT_GAME_316     = 3 
WT_VIP_316      = 4  
WT_GOLD_316     = 5 
WT_CHONG_316    = 6    
WT_NONE_316     = 7 

EXP_BT_CLOSE_316    = 1

local gameExprience = 
{
    0,10,20,40,70,110,160,230,330,430,
    550,680,840,1110,1330,1570,1850,2150,2680,3080,
    3520,3990,4510,5430,6080,6770,7520,8320,9790,10760,
    11790,12890,14050,16240,17620,19080,20620,22230,25340,27230,
    29210,31280,33450,37700,40200,42810,45520,48350,54000,57220,
    60560,64040,67650,74950,79020,83230,87590,92100,101370,106420,
    111620,117000,122550,134100,140260,146610,153140,159870,174040,181470,
    189110,196950,205020,222180,231040,240120,249440,259000,279550,289990,
    300690,311650,322880,347230,359440,371940,384720,397790,426380,440540,
    455020,469810,484910,518210,534520,551170,568170,585510,624000,666666
}

local ExpWelfareStage = 
{
    1,3,5,7,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,99
}

local WelfareRewardType =
{
    WT_NONE_316,
    WT_MEDAL_316,
    WT_VIP_316,
    WT_PHONE_316,
    WT_CHONG_316,
    WT_MEDAL_316,
    WT_PHONE_316,
    WT_VIP_316,
    WT_NONE_316,
    WT_MEDAL_316,
    WT_PHONE_316,
    WT_VIP_316,
    WT_NONE_316,
    WT_MEDAL_316,
    WT_PHONE_316,
    WT_VIP_316,
    WT_NONE_316,
    WT_MEDAL_316,
    WT_PHONE_316,
    WT_VIP_316,
    WT_NONE_316,
    WT_VIP_316,
    WT_NONE_316
}


function ASMJ_ExperienceLogic:new(o)
    print("ASMJ_ExperienceLogic:new")
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function ASMJ_ExperienceLogic:GetInstance()
    if self.instance == nil then
        self.instance = self:new()
    end
    return self.instance
end

function ASMJ_ExperienceLogic:ReleaseInstance()
    print("ASMJ_ExperienceLogic:ReleaseInstance")
    if self.instance then
        self.instance = nil
    end
end

function ASMJ_ExperienceLogic:ExpToLevel(iExp)
    
    for i=1,EXP_COUNT_316-1 do
        if iExp >= gameExprience[i] and iExp < gameExprience[i+1] then
            return (i-1)
        end
    end

    return (EXP_COUNT_316 - 1)
end

local ASMJ_ExperienceLayer = class("ASMJ_ExperienceLayer", function() return cc.Layer:create() end)

--create( ... )
function ASMJ_ExperienceLayer_create(iExp)
    print("ASMJ_ExperienceLayer_create")
    local Layer = ASMJ_ExperienceLayer.new(iExp)
    return Layer
end

--ctor()
function ASMJ_ExperienceLayer:ctor(iExp)
    print("ASMJ_ExperienceLayer:ctor")
    self:init(iExp)
end

--init()
function ASMJ_ExperienceLayer:init(iExp)
    print("ASMJ_ExperienceLayer:init")
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape

    self:setScale(0)

    local pWelfareBg = cc.Sprite:createWithSpriteFrameName("316_experience_bg.png")
    pWelfareBg:setScale(scalex, scaley)
    pWelfareBg:setPosition(visibleSize.width/2, visibleSize.height/2)
    self:addChild(pWelfareBg, 0)

    local iExpLevel = ASMJ_ExperienceLogic:GetInstance():ExpToLevel(iExp)
    local iLevelIndex = self:CurrentLevelIndex(iExpLevel)

    local iTopX = pWelfareBg:getPositionX() - pWelfareBg:getBoundingBox().width/2 + 20*scalex
    local iTopY = pWelfareBg:getPositionY() + pWelfareBg:getBoundingBox().height/2 - 30*scaley

    local iTitleSize = 20
    local pWelfareTitle1 = cc.LabelTTF:create(CUtilEx:getString("316_exp_reward_title1"),"Arial", iTitleSize)
    pWelfareTitle1:setScale(scalex, scaley)
    pWelfareTitle1:setColor(cc.c3b(188,65,65))
    pWelfareTitle1:setAnchorPoint(cc.p(0, 0.5))
    pWelfareTitle1:setPosition(iTopX, iTopY)
    self:addChild(pWelfareTitle1, 1)

    iTopX = iTopX + pWelfareTitle1:getContentSize().width*scalex
    local szExp = string.format("%d", iExpLevel)
    local pExpLevel = cc.LabelTTF:create(szExp, "Arial", iTitleSize)
    pExpLevel:setScale(scalex, scaley)
    pExpLevel:setColor(cc.c3b(188,65,65))
    pExpLevel:setAnchorPoint(cc.p(0, 0.5))
    pExpLevel:setPosition(iTopX, iTopY)
    self:addChild(pExpLevel, 1)

    iTopX = iTopX + pExpLevel:getContentSize().width*scalex
    local pWelfareTitle2 = cc.LabelTTF:create(CUtilEx:getString("316_exp_reward_title2"), "Arial", iTitleSize)
    pWelfareTitle2:setScale(scalex, scaley)
    pWelfareTitle2:setColor(cc.c3b(188,65,65))
    pWelfareTitle2:setAnchorPoint(cc.p(0, 0.5))
    pWelfareTitle2:setPosition(iTopX, iTopY)
    self:addChild(pWelfareTitle2, 1)

    iTopX = iTopX + pWelfareTitle2:getContentSize().width*scalex
    szExp = string.format("316_exp_reward_context_%d", iLevelIndex)
    local pWelfareContext = cc.LabelTTF:create(CUtilEx:getString(szExp), "Arial", iTitleSize)
    pWelfareContext:setScale(scalex, scaley)
    pWelfareContext:setColor(cc.c3b(188,65,65))
    pWelfareContext:setAnchorPoint(cc.p(0, 0.5))
    pWelfareContext:setPosition(iTopX, iTopY)
    self:addChild(pWelfareContext, 1)

    local iRemainReward = EXP_WEL_COUNT_316 - iLevelIndex

    if iRemainReward > 0 then
        iTopX = pWelfareBg:getPositionX() - pWelfareBg:getBoundingBox().width/2 + 20*scalex
        iTopY = pWelfareBg:getPositionY() + pWelfareBg:getBoundingBox().height/2 - 85*scaley

        if WelfareRewardType[iLevelIndex] <= WT_CHONG_316 then
            szExp = string.format("316_exp_reward_sub_title_%d", WelfareRewardType[iLevelIndex])
            local pSubTitle = cc.LabelTTF:create(CUtilEx:getString(szExp), "Arial", 15)
            pSubTitle:setScale(scalex, scaley)
            pSubTitle:setColor(cc.c3b(0,0,0))
            pSubTitle:setAnchorPoint(cc.p(0, 0.5))
            pSubTitle:setPosition(iTopX, iTopY)
            self:addChild(pSubTitle, 1)
        end

        iTopY = iTopY - 30*scaley
        local pSubTitle0 = cc.LabelTTF:create(CUtilEx:getString("316_exp_reward_sub_title_0"), "Arial", 15)
        pSubTitle0:setScale(scalex, scaley)
        pSubTitle0:setColor(cc.c3b(167,135,80))
        pSubTitle0:setAnchorPoint(cc.p(0.5, 0.5))
        pSubTitle0:setPosition(visibleSize.width/2, iTopY)
        self:addChild(pSubTitle0, 1)

        iTopY = iTopY - 10*scaley
        local iNextCount = iRemainReward > 4 and 4 or iRemainReward
        local pNextKuang = cc.Sprite:createWithSpriteFrameName("316_experience_frame.png")
        local iNextLevelX = visibleSize.width/2 - pNextKuang:getContentSize().width*(iNextCount-1)/2*scalex
        pNextKuang:setScale(scalex, scaley)
        pNextKuang:setAnchorPoint(cc.p(0.5,1))
        pNextKuang:setPosition(iNextLevelX, iTopY)
        self:addChild(pNextKuang, 1)

        assert(iLevelIndex+1<=EXP_WEL_COUNT_316, "error is iLevelIndex")
       
        szExp = string.format("316_exp_reward_level_%d", iLevelIndex+1)
        local pNextLevel = cc.LabelTTF:create(CUtilEx:getString(szExp), "Arial", 15)
        pNextLevel:setScale(scalex, scaley)
        pNextLevel:setColor(cc.c3b(0,0,0))
        pNextLevel:setAnchorPoint(cc.p(0.5, 0.5))
        pNextLevel:setPosition(pNextKuang:getPositionX(), pNextKuang:getPositionY() - 1.0/4*pNextKuang:getBoundingBox().height)
        self:addChild(pNextLevel, 2)
        
        szExp = string.format("316_exp_reward_context_%d", iLevelIndex+1)
        local pNextReward = cc.LabelTTF:create(CUtilEx:getString(szExp), "Arial", 15)
        pNextReward:setScale(scalex, scaley)
        pNextReward:setColor(cc.c3b(0,0,0))
        pNextReward:setAnchorPoint(cc.p(0.5, 0.5))
        pNextReward:setPosition(pNextKuang:getPositionX(), pNextKuang:getPositionY() - 3.0/4*pNextKuang:getBoundingBox().height)
        self:addChild(pNextReward, 2)
        

        for i=1,iNextCount-1 do
            iNextLevelX = iNextLevelX + pNextKuang:getBoundingBox().width
            local pNextKuang = cc.Sprite:createWithSpriteFrameName("316_experience_frame.png")
            pNextKuang:setScale(scalex, scaley)
            pNextKuang:setAnchorPoint(cc.p(0.5,1))
            pNextKuang:setPosition(iNextLevelX, iTopY)
            self:addChild(pNextKuang, 1)

            szExp = string.format("316_exp_reward_level_%d", iLevelIndex+1+i)
            local pNextLevel = cc.LabelTTF:create(CUtilEx:getString(szExp), "Arial", 15)
            pNextLevel:setScale(scalex, scaley)
            pNextLevel:setColor(cc.c3b(0,0,0))
            pNextLevel:setAnchorPoint(cc.p(0.5, 0.5))
            pNextLevel:setPosition(pNextKuang:getPositionX(), pNextKuang:getPositionY() - 1.0/4*pNextKuang:getBoundingBox().height)
            self:addChild(pNextLevel, 2)

            szExp = string.format("316_exp_reward_context_%d", iLevelIndex+1+i)
            local pNextReward = cc.LabelTTF:create(CUtilEx:getString(szExp), "Arial", 15)
            pNextReward:setScale(scalex, scaley)
            pNextReward:setColor(cc.c3b(0,0,0))
            pNextReward:setAnchorPoint(cc.p(0.5, 0.5))
            pNextReward:setPosition(pNextKuang:getPositionX(), pNextKuang:getPositionY() - 3.0/4*pNextKuang:getBoundingBox().height)
            self:addChild(pNextReward, 2)
        end
    else
        iTopY = pWelfareBg:getPositionY() + pWelfareBg:getBoundingBox().height/2 - 120*scaley
        local pTopLevel = cc.Sprite:createWithSpriteFrameName("316_experience_max_level_tip.png")
        pTopLevel:setScale(scalex, scaley)
        pTopLevel:setPosition(visibleSize.width/2, iTopY)
        self:addChild(pTopLevel, 1)
    end

    iTopY = pWelfareBg:getPositionY() + pWelfareBg:getBoundingBox().height/2 - 255*scaley
    m_btClose = CImageButton:CreateWithSpriteFrameName("316_experience_bt_close0.png", "316_experience_bt_close1.png", EXP_BT_CLOSE_316)
    m_btClose:setScale(scalex, scaley)
    m_btClose:setPosition(visibleSize.width/2, iTopY)
    self:addChild(m_btClose, 1)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)

    self:runAction(cc.ScaleTo:create(0.3, scalex, scaley))
end

function ASMJ_ExperienceLayer:OnClickEvent(clickcmd)
    print("ASMJ_ExperienceLayer:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == EXP_BT_CLOSE_316  then
        self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 0), cc.CallFunc:create(function () self:removeFromParent() end )))
    end
end

function ASMJ_ExperienceLayer:CurrentLevelIndex(iLevel)
    for i=1,EXP_WEL_COUNT_316-1 do
        if iLevel >= ExpWelfareStage[i] and iLevel < ExpWelfareStage[i+1] then
            return i
        end
    end
    return EXP_WEL_COUNT_316
end
