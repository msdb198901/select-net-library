local ASMJ_OtherHandMJControl = class("ASMJ_OtherHandMJControl", function() return cc.Node:create() end)

--create( ... )
function ASMJ_OtherHandMJControl_create()
    print("ASMJ_OtherHandMJControl_create")
    local Node = ASMJ_OtherHandMJControl.new()
    return Node
end

--ctor()
function ASMJ_OtherHandMJControl:ctor()
    print("ASMJ_OtherHandMJControl:ctor")

    self.m_OtherHandMJData = {}
    self.m_OtherShowMJData = {}

    self.m_fMinScaleY = 1
    self.m_fMinScaleX = 1

    self.m_OriginMJPoint = cc.p(0,0)
    self.m_HandMJDirection = Direction_East_316
end

----------------------------------
function ASMJ_OtherHandMJControl:OtherHandMJClear()
    self.m_OtherHandMJData = {}
    self.m_OtherShowMJData = {}
    self:removeAllChildren()
end

function ASMJ_OtherHandMJControl:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_OtherHandMJControl:SetOriginControlPoint(iXPos, iYPos)
    self.m_OriginMJPoint = cc.p(iXPos,iYPos)
    self.m_CurrentMJPoint = self.m_OriginMJPoint
end

function ASMJ_OtherHandMJControl:GetSendMJPoint()
    
    local pt = cc.p(0,0)
    if self.m_HandMJDirection == Direction_East_316 then
        local nYExcusion = Y_USER_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x
        pt.y = self.m_OriginMJPoint.y-nYExcusion*(#self.m_OtherHandMJData)*self.m_fMinScaleY

    elseif self.m_HandMJDirection == Direction_West_316 then

        local nYExcusion = Y_USER_LR_EXCUSION_316
        pt.x = self.m_OriginMJPoint.x
        pt.y = self.m_OriginMJPoint.y+nYExcusion*(#self.m_OtherHandMJData)*self.m_fMinScaleY

    elseif self.m_HandMJDirection == Direction_North_316 then
        local pUserNorth = cc.Sprite:createWithSpriteFrameName("316_tileBack_up_0.png")
        local nXExcusion = pUserNorth:getContentSize().width-2
        pt.x = self.m_OriginMJPoint.x - nXExcusion*(#self.m_OtherHandMJData)*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y
    end

    return pt
end

function ASMJ_OtherHandMJControl:DrawUserHandMJ(iMJCount, bCurrentCard, bAction)

    bAction = bAction or false

    if self.m_HandMJDirection == Direction_East_316 then
        
        local pUserEast = cc.Sprite:createWithSpriteFrameName("316_tileBack_left_0.png")

        local nYExcusion = Y_USER_LR_EXCUSION_316 * self.m_fMinScaleY
        local nXPos = self.m_CurrentMJPoint.x
        local nYPos = self.m_CurrentMJPoint.y

        local iHandMJCount = #self.m_OtherHandMJData
        local iZorderMJ = iHandMJCount

        if iHandMJCount > 0 then
            nYPos = self.m_OtherHandMJData[iHandMJCount]:getPositionY() - nYExcusion
        end

        for i=1,iMJCount do
            local pUserEast  = cc.Sprite:createWithSpriteFrameName("316_tileBack_left_0.png")
            pUserEast:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            
            if i == iMJCount and bCurrentCard then
                nYPos = nYPos - 18*self.m_fMinScaleY
            end

            if bAction then
                pUserEast:setPosition(nXPos,nYPos+50*self.m_fMinScaleY)
                local moveAction = cc.MoveTo:create(0.8, cc.p(nXPos,nYPos))
                local easeAction = cc.EaseBounceOut:create(moveAction:clone())
                local seqAction = cc.Sequence:create(easeAction)
                pUserEast:runAction(seqAction)
            else
                pUserEast:setPosition(nXPos,nYPos)
            end
            self:addChild(pUserEast, iZorderMJ + i)
            nYPos = nYPos - nYExcusion
            self.m_OtherHandMJData[iHandMJCount + i] = pUserEast
        end

        assert(#self.m_OtherHandMJData <= MAX_COUNT_316)

    elseif self.m_HandMJDirection == Direction_West_316 then
        
        local pUserWest = cc.Sprite:createWithSpriteFrameName("316_tileBack_right_0.png")

        local nYExcusion = Y_USER_LR_EXCUSION_316 * self.m_fMinScaleY
        local nXPos = self.m_CurrentMJPoint.x
        local nYPos = self.m_CurrentMJPoint.y

        local iHandMJCount = #self.m_OtherHandMJData
        local iZorderMJ = 50

        if iHandMJCount > 0 then
            iZorderMJ = self.m_OtherHandMJData[iHandMJCount]:getLocalZOrder() - 1
            nYPos = self.m_OtherHandMJData[iHandMJCount]:getPositionY() + nYExcusion
        end

        for i=1,iMJCount do
            local pUserWest  = cc.Sprite:createWithSpriteFrameName("316_tileBack_right_0.png")
            pUserWest:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            
            if i == iMJCount and bCurrentCard then
                nYPos = nYPos + 10*self.m_fMinScaleY
            end

            if bAction then
                pUserWest:setPosition(nXPos,nYPos+50*self.m_fMinScaleY)
                local moveAction = cc.MoveTo:create(0.8, cc.p(nXPos,nYPos))
                local easeAction = cc.EaseBounceOut:create(moveAction:clone())
                local seqAction = cc.Sequence:create(easeAction)
                pUserWest:runAction(seqAction)
            else
                pUserWest:setPosition(nXPos,nYPos)
            end
            self:addChild(pUserWest, iZorderMJ - i)
            nYPos = nYPos + nYExcusion
            self.m_OtherHandMJData[iHandMJCount + i] = pUserWest
        end

        assert(#self.m_OtherHandMJData <= MAX_COUNT_316)
    
    elseif self.m_HandMJDirection == Direction_North_316 then
        local pUserNorth = cc.Sprite:createWithSpriteFrameName("316_tileBack_up_0.png")

        local nXExcusion = (pUserNorth:getContentSize().width-2)*self.m_fMinScaleX
        local nXPos = self.m_CurrentMJPoint.x
        local nYPos = self.m_CurrentMJPoint.y

        local iHandMJCount = #self.m_OtherHandMJData
        if iHandMJCount > 0 then
            nXPos = self.m_OtherHandMJData[iHandMJCount]:getPositionX() - nXExcusion
        end

        for i=1,iMJCount do
            local pUserNorth  = cc.Sprite:createWithSpriteFrameName("316_tileBack_up_0.png")
            pUserNorth:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            
            if i == iMJCount and bCurrentCard then
                nXPos = nXPos - 12*self.m_fMinScaleX
            end

            if bAction then
                pUserNorth:setPosition(nXPos,nYPos+50*self.m_fMinScaleY)
                local moveAction = cc.MoveTo:create(0.8, cc.p(nXPos,nYPos))
                local easeAction = cc.EaseBounceOut:create(moveAction:clone())
                local seqAction = cc.Sequence:create(easeAction)
                pUserNorth:runAction(seqAction)
            else
                pUserNorth:setPosition(nXPos,nYPos)
            end
            self:addChild(pUserNorth)
            nXPos = nXPos - nXExcusion
            self.m_OtherHandMJData[iHandMJCount + i] = pUserNorth
        end

        assert(#self.m_OtherHandMJData <= MAX_COUNT_316)
    end
end

function ASMJ_OtherHandMJControl:OrbitUserHandMJ()

    if self.m_HandMJDirection == Direction_East_316 then
        
        for i=1,#self.m_OtherHandMJData do
            local pMJSeq = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.5), cc.Show:create())
            self.m_OtherHandMJData[i]:runAction(pMJSeq)

            local pMJDownBack = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_leftRight_0.png")
            pMJDownBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJDownBack:setPosition(self.m_OtherHandMJData[i]:getPosition())
            self:addChild(pMJDownBack)

            local pMJDownBackSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function () pMJDownBack:removeFromParent() end))
            pMJDownBack:runAction(pMJDownBackSeq)
        end

    elseif self.m_HandMJDirection == Direction_West_316 then
        
        for i=1,#self.m_OtherHandMJData do
            local pMJSeq = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.5), cc.Show:create())
            self.m_OtherHandMJData[i]:runAction(pMJSeq)

            local pMJDownBack = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_leftRight_0.png")
            pMJDownBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJDownBack:setPosition(self.m_OtherHandMJData[i]:getPosition())
            self:addChild(pMJDownBack, 50 - i)

            local pMJDownBackSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function () pMJDownBack:removeFromParent() end))
            pMJDownBack:runAction(pMJDownBackSeq)
        end
    
    elseif self.m_HandMJDirection == Direction_North_316 then
        
        for i=1,#self.m_OtherHandMJData do
            local pMJSeq = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.5), cc.Show:create())
            self.m_OtherHandMJData[i]:runAction(pMJSeq)

            local pMJDownBack = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_Up_0.png")
            pMJDownBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJDownBack:setPosition(self.m_OtherHandMJData[i]:getPosition())
            self:addChild(pMJDownBack)

            local pMJDownBackSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function () pMJDownBack:removeFromParent() end))
            pMJDownBack:runAction(pMJDownBackSeq)
        end

    end
end

function ASMJ_OtherHandMJControl:DeleteUserHandMJ(cbMJCount, cbDeleteLR)

    cbDeleteLR = cbDeleteLR or 0

    local iHandMJCount = #self.m_OtherHandMJData
    assert(cbDeleteLR <= 1, "error cbDeleteLR")
    assert(iHandMJCount > cbMJCount)

    if cbDeleteLR == 0 then
        
        for i=iHandMJCount, iHandMJCount - cbMJCount + 1, -1 do
            self.m_OtherHandMJData[i]:removeFromParent()
            table.remove(self.m_OtherHandMJData, i)
        end
        return

    elseif cbDeleteLR == 1 then
        
        for i=1,cbMJCount do
            self.m_OtherHandMJData[1]:removeFromParent()
            table.remove(self.m_OtherHandMJData, 1)
        end

    end

    iHandMJCount = #self.m_OtherHandMJData
    local bCurrentMJ = iHandMJCount % 3 == 2

    if self.m_HandMJDirection == Direction_East_316 then

        local nYExcusion = Y_USER_LR_EXCUSION_316*self.m_fMinScaleY
        
        for i=1,iHandMJCount do
            self.m_OtherHandMJData[i]:setPositionY(self.m_CurrentMJPoint.y - (i-1)*nYExcusion)
        end

        if bCurrentMJ then
            self.m_OtherHandMJData[iHandMJCount]:setPositionY(self.m_OtherHandMJData[iHandMJCount]:getPositionY()-18*self.m_fMinScaleY)
        end

    elseif self.m_HandMJDirection == Direction_West_316 then
    
        local nYExcusion = Y_USER_LR_EXCUSION_316*self.m_fMinScaleY
        
        for i=1,iHandMJCount do
            self.m_OtherHandMJData[i]:setPositionY(self.m_CurrentMJPoint.y + (i-1)*nYExcusion)
        end

        if bCurrentMJ then
            self.m_OtherHandMJData[iHandMJCount]:setPositionY(self.m_OtherHandMJData[iHandMJCount]:getPositionY()+21*self.m_fMinScaleY)
        end

    elseif self.m_HandMJDirection == Direction_North_316 then

        local pUserNorth = cc.Sprite:createWithSpriteFrameName("316_tileBack_up_0.png")
        local nXExcusion = (pUserNorth:getContentSize().width-2)*self.m_fMinScaleX

        self.m_CurrentMJPoint.x = self.m_OriginMJPoint.x - nXExcusion*(MAX_COUNT_316 - 1) - 12*self.m_fMinScaleX
        self.m_CurrentMJPoint.x = self.m_CurrentMJPoint.x + (not bCurrentMJ and 12*self.m_fMinScaleX or 0 ) + nXExcusion*iHandMJCount

        for i=1,iHandMJCount do
            self.m_OtherHandMJData[i]:setPositionX(self.m_CurrentMJPoint.x - (i-1)*nXExcusion)
        end

        if bCurrentMJ then
            self.m_OtherHandMJData[iHandMJCount]:setPositionX(self.m_OtherHandMJData[iHandMJCount]:getPositionX()-12*self.m_fMinScaleX)
        end
    end

    return
end

function ASMJ_OtherHandMJControl:OrbitShowUserHandMJ(cbMJData, cbMJCount, cbProvideMJ)

    cbProvideMJ = cbProvideMJ or 0

    if self.m_HandMJDirection == Direction_East_316 then

        for i=1,#self.m_OtherHandMJData do
            self.m_OtherHandMJData[i]:removeFromParent()
        end
        self.m_OtherHandMJData = {}

        local iShowCount = #self.m_OtherShowMJData
        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")
        local nItemWidth = pHuMJGAP:getContentSize().width-3
        
        for i=1,cbMJCount do

            local nItemHeight = Y_TABLE_LR_EXCUSION_316

            local pt = cc.p(0,0)
            pt.x = self.m_CurrentMJPoint.x
            pt.y = self.m_CurrentMJPoint.y - (i-1)*nItemHeight*self.m_fMinScaleY

            if i == cbMJCount and cbProvideMJ ~= 0 then
                pt.y = pt.y - 3*self.m_fMinScaleY
            end

            local str = string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData[i], 4), bit:_and(cbMJData[i], 15))
            local pMJData = cc.Sprite:createWithSpriteFrameName(str)
            local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")

            pMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

            pMJBack:setPosition(pt)
            pMJData:setPosition(pt.x, pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)

            self:addChild(pMJBack, i)
            self:addChild(pMJData, i+1)

            self.m_OtherShowMJData[iShowCount + i] = {}
            self.m_OtherShowMJData[iShowCount + i].pMJBack = pMJBack
            self.m_OtherShowMJData[iShowCount + i].pMJData = pMJData
            self.m_OtherShowMJData[iShowCount + i].cbMJData = cbMJData[i]
        end

    elseif self.m_HandMJDirection == Direction_West_316 then
        
        for i=1,#self.m_OtherHandMJData do
            self.m_OtherHandMJData[i]:removeFromParent()
        end
        self.m_OtherHandMJData = {}

        local iShowCount = #self.m_OtherShowMJData
        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")
        local nItemWidth = pHuMJGAP:getContentSize().width-3
        
        for i=1,cbMJCount do

            local nItemHeight = Y_TABLE_LR_EXCUSION_316

            local pt = cc.p(0,0)
            pt.x = self.m_CurrentMJPoint.x
            pt.y = self.m_CurrentMJPoint.y + (i-1)*nItemHeight*self.m_fMinScaleY

            if i == cbMJCount and cbProvideMJ ~= 0 then
                pt.y = pt.y + 3*self.m_fMinScaleY
            end

            local str = string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData[i], 4), bit:_and(cbMJData[i], 15))
            local pMJData = cc.Sprite:createWithSpriteFrameName(str)
            local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")

            pMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

            pMJBack:setPosition(pt)
            pMJData:setPosition(pt.x, pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)

            self:addChild(pMJBack, 50-i)
            self:addChild(pMJData, 50-i+1)

            self.m_OtherShowMJData[iShowCount + i] = {}
            self.m_OtherShowMJData[iShowCount + i].pMJBack = pMJBack
            self.m_OtherShowMJData[iShowCount + i].pMJData = pMJData
            self.m_OtherShowMJData[iShowCount + i].cbMJData = cbMJData[i]
        end

    elseif self.m_HandMJDirection == Direction_North_316 then

        for i=1,#self.m_OtherHandMJData do
            self.m_OtherHandMJData[i]:removeFromParent()
        end
        self.m_OtherHandMJData = {}

        local iShowCount = #self.m_OtherShowMJData
        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")
        local nItemWidth = pHuMJGAP:getContentSize().width-3

        for i=1,cbMJCount do

            local pt = cc.p(0,0)
            pt.x = self.m_CurrentMJPoint.x - (i-1)*nItemWidth*self.m_fMinScaleX
            pt.y = self.m_CurrentMJPoint.y

            if i == cbMJCount and cbProvideMJ ~= 0 then
                pt.x = pt.x - 12*self.m_fMinScaleX
            end

            local str = string.format("316_tile_meUp_%d%d.png", bit:_rshift(cbMJData[i], 4), bit:_and(cbMJData[i], 15))
            local pMJData = cc.Sprite:createWithSpriteFrameName(str)
            local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")

            pMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

            pMJBack:setPosition(pt)
            pMJData:setPosition(pt.x, pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)

            self:addChild(pMJBack, i)
            self:addChild(pMJData, i+1)

            self.m_OtherShowMJData[iShowCount + i] = {}
            self.m_OtherShowMJData[iShowCount + i].pMJBack = pMJBack
            self.m_OtherShowMJData[iShowCount + i].pMJData = pMJData
            self.m_OtherShowMJData[iShowCount + i].cbMJData = cbMJData[i]
        end

    end

end

function ASMJ_OtherHandMJControl:SetSwayChichenColor(cbSwayData, cbSwayCount)

    for i=1,#self.m_OtherShowMJData do
        for j=1,cbSwayCount do
            if self.m_OtherShowMJData[i].cbMJData == 17 or self.m_OtherShowMJData[i].cbMJData == cbSwayData[j] then
                self.m_OtherShowMJData[i].pMJBack:setColor(cc.c3b(243,170,175))
                self.m_OtherShowMJData[i].pMJData:setColor(cc.c3b(243,170,175))
            end
        end
    end
    
end
