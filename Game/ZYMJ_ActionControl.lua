local ASMJ_ActionControl = class("ASMJ_ActionControl", function() return cc.Node:create() end)

--create( ... )
function ASMJ_ActionControl_create()
    print("ASMJ_ActionControl_create")
    local Node = ASMJ_ActionControl.new()
    return Node
end

--ctor()
function ASMJ_ActionControl:ctor()
    print("ASMJ_ActionControl:ctor")
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1
    self.m_ptAction = cc.p(0,0)
end

----------------------------------
function ASMJ_ActionControl:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_ActionControl:SetActionPoint(iXPos, iYPos)
    self.m_ptAction = cc.p(iXPos,iYPos)
end

function ASMJ_ActionControl:DrawHuAction(cbHuMJType)


    local pActionBack = cc.Sprite:createWithSpriteFrameName("316_BlockOther_back.png")
    local pActionType = nil
    local pActionTypeOrigin = nil

    if cbHuMJType == HT_PENG_316 then
        
        pActionType = cc.Sprite:createWithSpriteFrameName("316_BlockOther_peng.png")
        pActionTypeOrigin = cc.Sprite:createWithSpriteFrameName("316_BlockOther_peng.png")
    
    elseif cbHuMJType <= HT_AN_GANG_316 then

        pActionType = cc.Sprite:createWithSpriteFrameName("316_BlockOther_gang.png")
        pActionTypeOrigin = cc.Sprite:createWithSpriteFrameName("316_BlockOther_gang.png")

    elseif cbHuMJType == HT_TING_316 then
        
        pActionType = cc.Sprite:createWithSpriteFrameName("316_BlockOther_ting.png")
        pActionTypeOrigin = cc.Sprite:createWithSpriteFrameName("316_BlockOther_ting.png")

    elseif cbHuMJType == HT_HU_316 then

        pActionType = cc.Sprite:createWithSpriteFrameName("316_BlockOther_hu.png")
        pActionTypeOrigin = cc.Sprite:createWithSpriteFrameName("316_BlockOther_hu.png")

    end
    
    pActionBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    pActionType:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    pActionTypeOrigin:setScale(self.m_fMinScaleX*0.6, self.m_fMinScaleY*0.6)

    pActionBack:setPosition(self.m_ptAction)
    pActionType:setPosition(self.m_ptAction)
    pActionTypeOrigin:setPosition(self.m_ptAction)

    self:addChild(pActionBack, ZORDER_ACTION_316)
    self:addChild(pActionType, ZORDER_ACTION_316+2)
    self:addChild(pActionTypeOrigin, ZORDER_ACTION_316+1)

    local pScaleSamll = cc.ScaleTo:create(0.3, 0.6*self.m_fMinScaleY)
    local pFade = cc.FadeOut:create(0.3)
    local pScaleBig = cc.ScaleTo:create(0.3, 1.2*self.m_fMinScaleY)
    local pSpawn = cc.Spawn:create(pScaleBig, pFade)
    local pSeqType = cc.Sequence:create(pScaleSamll, pSpawn, cc.CallFunc:create(function () pActionType:removeFromParent() end))
    pActionType:runAction(pSeqType)

    local pSeqBack = cc.Sequence:create(
            cc.FadeIn:create(0.2), 
            cc.DelayTime:create(0.6), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 0.5), cc.FadeOut:create(0.2)), 
            cc.CallFunc:create(function () pActionBack:removeFromParent() end))

    local pSeqOrigin = cc.Sequence:create(
            cc.FadeIn:create(0.2), 
            cc.DelayTime:create(0.6), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 0.5), cc.FadeOut:create(0.2)), 
            cc.CallFunc:create(function () pActionTypeOrigin:removeFromParent() end))

    pActionBack:runAction(pSeqBack)
    pActionTypeOrigin:runAction(pSeqOrigin)
end
