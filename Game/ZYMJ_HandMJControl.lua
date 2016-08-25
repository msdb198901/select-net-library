local ASMJ_HandMJControl = class("ASMJ_HandMJControl", function() return cc.Node:create() end)

--create( ... )ASMJ_HandMJControl_create
function ASMJ_HandMJControl_create()
    print("ASMJ_HandMJControl_create")
    local Node = ASMJ_HandMJControl.new()
    return Node
end

--ctor()
function ASMJ_HandMJControl:ctor()
    print("ASMJ_HandMJControl:ctor")

    self.m_iOrbitStatus = false
    self.m_iMJIndex = 0
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1
    self.m_HandMJData = {}
    self.m_bPositive = false
    self.m_OriginMJPoint = cc.p(0,0)
end

----------------------------------
function ASMJ_HandMJControl:HandMJClear()
    print("HandMJClear", self)
    self.m_HandMJData = {}
    print("HandMJClear1", self)
    self:removeAllChildren()
end

function ASMJ_HandMJControl:SetPositive(bPositive)
   self.m_bPositive = bPositive
end

function ASMJ_HandMJControl:SetScaleMin(iMinScaleX, iMinScaleY)
   self.m_fMinScaleX = iMinScaleX
   self.m_fMinScaleY = iMinScaleY
end

function ASMJ_HandMJControl:GetSendMJPoint()
    return cc.p(self.m_OriginMJPoint.x + self.m_iMJWidth*(#self.m_HandMJData), self.m_OriginMJPoint.y)
end

function ASMJ_HandMJControl:SetOriginControlPoint(iXPos, iYPos)
    self.m_OriginMJPoint = cc.p(iXPos, iYPos)
    self.m_CurrentMJPoint = self.m_OriginMJPoint

    local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_me_0.png")
    self.m_iMJWidth = (pMJBack:getContentSize().width-2)*self.m_fMinScaleX
end

function ASMJ_HandMJControl:GetHandMJIndex(cbMJ)
    for i=1,#self.m_HandMJData do
        if self.m_HandMJData[i].m_cbHandMJData == cbMJ then
            return i
        end
    end
    return INVALID_ITEM_316
end

function ASMJ_HandMJControl:DrawHandMJ(cbMJData, iMJCount, bCurrentMJ, bTouchMJ, bAction)

    local nXPos = self.m_CurrentMJPoint.x
    local nYPos = self.m_CurrentMJPoint.y
    local nCurrentMJCount = #self.m_HandMJData
    for i=1,nCurrentMJCount do
        nXPos = nXPos + (self.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().width - 2*self.m_fMinScaleX)
    end

    for i=1,iMJCount do

        local str = string.format("316_tile_me_%d%d.png", bit:_rshift(cbMJData[i], 4), bit:_and(cbMJData[i], 15))
        local pMJData = cc.Sprite:createWithSpriteFrameName(str)
        local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_me_0.png")

        pMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

        pMJBack:setAnchorPoint(cc.p(0, 0.5))
        pMJData:setAnchorPoint(cc.p(0.5, 0.5))

        if bCurrentMJ and i == iMJCount then
            nXPos = nXPos + 15*self.m_fMinScaleX
        end

        if bAction then
            self.m_bPositive = false
            pMJBack:setPosition(nXPos,nYPos+90*self.m_fMinScaleY)
            pMJData:setPosition(nXPos+(pMJBack:getContentSize().width/2)*self.m_fMinScaleX, nYPos-MY_MJ_DATA_EDGE_316*self.m_fMinScaleY+90*self.m_fMinScaleY)
        else
            pMJBack:setPosition(nXPos,nYPos)
            pMJData:setPosition(nXPos+(pMJBack:getContentSize().width/2)*self.m_fMinScaleX, nYPos-MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)
        end

        self:addChild(pMJBack, -1)
        self:addChild(pMJData)

        self.m_iMJIndex = self.m_iMJIndex + 1

        local pHandMJData = {}
        pHandMJData.m_bGray = false
        pHandMJData.m_bTouch = bTouchMJ
        pHandMJData.m_cbHandMJData = cbMJData[i]
        pHandMJData.m_pSpriteMJData = pMJData
        pHandMJData.m_pSpriteMJBack = pMJBack
        pHandMJData.m_bSelect = false
        pHandMJData.m_iMJIndex = self.m_iMJIndex
        table.insert(self.m_HandMJData, pHandMJData)

        if bAction then
            local moveAction = cc.MoveTo:create(0.5, cc.p(nXPos + (pMJBack:getContentSize().width/2)*self.m_fMinScaleX,nYPos-MY_MJ_DATA_EDGE_316*self.m_fMinScaleY))
            local easeAction = cc.EaseBounceOut:create(moveAction:clone())
            local seqAction = cc.Sequence:create(easeAction)

            local moveAction1 = cc.MoveTo:create(0.5, cc.p(nXPos,nYPos))
            local easeAction1 = cc.EaseBounceOut:create(moveAction1:clone())
            local seqAction1 = cc.Sequence:create(easeAction1, 
                cc.CallFunc:create(
                    function () 
                        local iHandMJCount = #self.m_HandMJData
                        if iHandMJCount > 0 then
                            self.m_HandMJData[iHandMJCount].m_pSpriteMJBack:setPositionY(self.m_CurrentMJPoint.y)
                            self.m_HandMJData[iHandMJCount].m_pSpriteMJData:setPositionY(self.m_CurrentMJPoint.y-MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)
                            self.m_bPositive = true
                        end
                    end)
                )
            pMJBack:runAction(seqAction1)
            pMJData:runAction(seqAction)
        end

        nXPos = nXPos + self.m_iMJWidth

    end
end

function ASMJ_HandMJControl:OrbitHandMJ()

    local iTagIndex = 1
    local iHandMJCount = #self.m_HandMJData

    for i=1,iHandMJCount do
        self.m_HandMJData[i].m_bTouch = false
        self.m_HandMJData[i].m_pSpriteMJData:runAction(cc.Hide:create())
        self.m_HandMJData[i].m_pSpriteMJBack:runAction(cc.Hide:create())

        local pMJDownBack = cc.Sprite:createWithSpriteFrameName("316_tileDown_me_0.png")
        pMJDownBack:setAnchorPoint(cc.p(0, 0.5))
        pMJDownBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pMJDownBack:setPosition(self.m_HandMJData[i].m_pSpriteMJBack:getPosition())
        self:addChild(pMJDownBack)

        local pMJDownBackSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function () pMJDownBack:removeFromParent() end))
        pMJDownBack:runAction(pMJDownBackSeq)
    end

    table.sort(self.m_HandMJData, 
        function(a,b) 
            if a.m_cbHandMJData==b.m_cbHandMJData then
                return a.m_iMJIndex < b.m_iMJIndex
            else
                return a.m_cbHandMJData<b.m_cbHandMJData
            end
        end)

    for i=1,iHandMJCount do
        local pMJSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.Show:create())
        local pMJBackSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.Show:create())

        self.m_HandMJData[i].m_pSpriteMJBack:setPositionX(self.m_OriginMJPoint.x + (i-1)*self.m_iMJWidth)
        self.m_HandMJData[i].m_pSpriteMJData:setPositionX(self.m_HandMJData[i].m_pSpriteMJBack:getPositionX()+(self.m_HandMJData[i].m_pSpriteMJBack:getContentSize().width/2)*self.m_fMinScaleX)

        if i == iHandMJCount and iHandMJCount % 3 == 2 then
            self.m_HandMJData[i].m_bTouch = true
            self.m_HandMJData[i].m_pSpriteMJBack:setPositionX(self.m_HandMJData[i].m_pSpriteMJBack:getPositionX() + 15*self.m_fMinScaleX)
            self.m_HandMJData[i].m_pSpriteMJData:setPositionX(self.m_HandMJData[i].m_pSpriteMJBack:getPositionX() + (self.m_HandMJData[i].m_pSpriteMJBack:getContentSize().width/2)*self.m_fMinScaleX)
        end

        self.m_HandMJData[i].m_pSpriteMJBack:runAction(pMJBackSeq)
        self.m_HandMJData[i].m_pSpriteMJData:runAction(pMJSeq)
    end

end

function ASMJ_HandMJControl:OrbitShowHandMJ(cbMJData, iMJCount, cbHuMJData)

    self:removeAllChildren()
    self.m_HandMJData = {}
    
    local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
    self.m_iMJWidth = (pMJBack:getContentSize().width-2)*self.m_fMinScaleX
    self.m_iOrbitStatus = true

    local nXPos = self.m_CurrentMJPoint.x
    local nYPos = 92 * self.m_fMinScaleY

    for i=1,iMJCount do
        local str = string.format("316_tile_me_%d%d.png", bit:_rshift(cbMJData[i], 4), bit:_and(cbMJData[i], 15))
        local pMJData = cc.Sprite:createWithSpriteFrameName(str)
        local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
        
        if i == iMJCount and cbHuMJData ~= 0 then
            nXPos = nXPos + 15*self.m_fMinScaleX
        end

        pMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

        pMJBack:setPosition(nXPos,nYPos)
        pMJData:setPosition(nXPos,nYPos+MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)

        self:addChild(pMJBack, -1)
        self:addChild(pMJData)

        nXPos = nXPos + self.m_iMJWidth
        
        self.m_HandMJData[i] = {}
        self.m_HandMJData[i].m_bGray = false
        self.m_HandMJData[i].m_bTouch = false
        self.m_HandMJData[i].m_bSelect = false
        self.m_HandMJData[i].m_cbHandMJData = cbMJData[i]
        self.m_HandMJData[i].m_pSpriteMJData = pMJData
        self.m_HandMJData[i].m_pSpriteMJBack = pMJBack
    end
end

function ASMJ_HandMJControl:SetSwayChichenColor(cbSwayData, cbSwayCount)

    for i=1,#self.m_HandMJData do
        for j=1,cbSwayCount do
            if self.m_HandMJData[i].m_cbHandMJData == 17 or self.m_HandMJData[i].m_cbHandMJData == cbSwayData[j] then
                self.m_HandMJData[i].m_pSpriteMJBack:setColor(cc.c3b(243,170,175))
                self.m_HandMJData[i].m_pSpriteMJData:setColor(cc.c3b(243,170,175))
            end
        end
    end
end

function ASMJ_HandMJControl:SetMJShoot(iBackIndex, bRt)

    local iHandMJCount = #self.m_HandMJData
    assert(iBackIndex <= iHandMJCount, "error touch mj index")

    if not self.m_bPositive  then
        return
    end

    for i=1,iHandMJCount do
        if self.m_HandMJData[i].m_pSpriteMJBack:getNumberOfRunningActions() > 0 then
            return
        end
    end

    bRt = bRt or false

    if self.m_HandMJData[iBackIndex].m_bSelect then
        
        if not bRt then
            self.m_HandMJData[iBackIndex].m_bSelect = false
            local pMJBack = self.m_HandMJData[iBackIndex].m_pSpriteMJBack
            local pMJData = self.m_HandMJData[iBackIndex].m_pSpriteMJData
            pMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            pMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            self:RectifyMJPoint(iBackIndex)
        end

    else

        self.m_HandMJData[iBackIndex].m_bSelect = true
        local pMJBack = self.m_HandMJData[iBackIndex].m_pSpriteMJBack
        local pMJData = self.m_HandMJData[iBackIndex].m_pSpriteMJData
        pMJBack:setScale(self.m_fMinScaleX*1.2, self.m_fMinScaleY*1.2)
        pMJData:setScale(self.m_fMinScaleX*1.2, self.m_fMinScaleY*1.2)
        self:RectifyMJPoint(iBackIndex, true)

    end
end

function ASMJ_HandMJControl:RectifyMJPoint(iBackIndex, bShoot)

    bShoot = bShoot or false 

    local iMJCount = #self.m_HandMJData

    local iXPos = self.m_CurrentMJPoint.x
    local iYPos = self.m_CurrentMJPoint.y

    local iXShootBack = bShoot and 20*self.m_fMinScaleY or 0
    local iXShootData = bShoot and 20*self.m_fMinScaleY - self.m_fMinScaleY*MY_MJ_DATA_EDGE_316 or -MY_MJ_DATA_EDGE_316*self.m_fMinScaleY

    local iWidth = 0
    local bCurrent = iMJCount % 3 == 2
    for i=1,iMJCount do

        if iBackIndex == i then
            self.m_HandMJData[i].m_pSpriteMJBack:setPositionY(iYPos + iXShootBack)
            self.m_HandMJData[i].m_pSpriteMJData:setPositionY(iYPos + iXShootData)
        end

        if i == iMJCount and bCurrent then
            iXPos = iXPos + 15*self.m_fMinScaleX
        end

        self.m_HandMJData[i].m_pSpriteMJBack:setPositionX(iXPos)
        self.m_HandMJData[i].m_pSpriteMJData:setPositionX(iXPos + self.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().width/2)

        iWidth = self.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().width-2*self.m_fMinScaleX
        iXPos = iXPos + iWidth

    end
end


function ASMJ_HandMJControl:DeleteMJData(cbMJData, cbMJTagIndex)

    local iHandMJCount = #self.m_HandMJData
    assert(cbMJTagIndex <= iHandMJCount, "error touch mj index")
    assert(self.m_HandMJData[cbMJTagIndex].m_cbHandMJData == cbMJData, "error handmj data")

    self.m_HandMJData[cbMJTagIndex].m_pSpriteMJData:removeFromParent()
    self.m_HandMJData[cbMJTagIndex].m_pSpriteMJBack:removeFromParent()

    table.remove(self.m_HandMJData, cbMJTagIndex) 
    table.sort(self.m_HandMJData, 
        function(a,b) 
            if a.m_cbHandMJData==b.m_cbHandMJData then
                return a.m_iMJIndex < b.m_iMJIndex
            else
                return a.m_cbHandMJData<b.m_cbHandMJData
            end
        end)

    local bInMove = false
    local iInMoveIndex = 1
    iHandMJCount = #self.m_HandMJData

    for i=1,iHandMJCount do

        if self.m_HandMJData[i].m_bTouch then
            if i == iHandMJCount then
               self.m_HandMJData[i].m_bTouch = false
            else
               bInMove = true
               iInMoveIndex = i
            end
            break
        end

        if self.m_HandMJData[i].m_bSelect then
            self.m_HandMJData[i].m_pSpriteMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            self.m_HandMJData[i].m_pSpriteMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        end

    end

    for i=1,iHandMJCount do
        if self.m_HandMJData[i].m_bGray then
            self.m_HandMJData[i].m_bGray = false
            self.m_HandMJData[i].m_pSpriteMJBack:setColor(cc.c3b(255,255,255))
            self.m_HandMJData[i].m_pSpriteMJData:setColor(cc.c3b(255,255,255))
        end

        if self.m_HandMJData[i].m_bTouch then
        else
            self.m_HandMJData[i].m_pSpriteMJBack:runAction(cc.MoveTo:create(0.2, cc.p(self.m_CurrentMJPoint.x+self.m_iMJWidth*(i-1), self.m_CurrentMJPoint.y)))
            self.m_HandMJData[i].m_pSpriteMJData:runAction(cc.MoveTo:create(0.2, cc.p(self.m_CurrentMJPoint.x+self.m_iMJWidth*(i-1)+(self.m_HandMJData[i].m_pSpriteMJBack:getContentSize().width/2)*self.m_fMinScaleX, self.m_CurrentMJPoint.y - MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)))
        end
    end


    if bInMove then
        local iTouchMoveIndex = iInMoveIndex - 1
        local pArrayBack = {
            cc.p(self.m_HandMJData[iInMoveIndex].m_pSpriteMJBack:getPosition()),
            cc.p(self.m_HandMJData[iInMoveIndex].m_pSpriteMJBack:getPositionX(), self.m_CurrentMJPoint.y + 90*self.m_fMinScaleY),
            cc.p(self.m_CurrentMJPoint.x + self.m_iMJWidth*iTouchMoveIndex, self.m_CurrentMJPoint.y + 90*self.m_fMinScaleY),
            cc.p(self.m_CurrentMJPoint.x+self.m_iMJWidth*iTouchMoveIndex, self.m_CurrentMJPoint.y)
        }

        local pArrayData = {
            cc.p(self.m_HandMJData[iInMoveIndex].m_pSpriteMJData:getPosition()),
            cc.p(self.m_HandMJData[iInMoveIndex].m_pSpriteMJData:getPositionX(), self.m_CurrentMJPoint.y + 90*self.m_fMinScaleY - MY_MJ_DATA_EDGE_316*self.m_fMinScaleY),
            cc.p(self.m_CurrentMJPoint.x + self.m_iMJWidth*iTouchMoveIndex+(self.m_HandMJData[iInMoveIndex].m_pSpriteMJBack:getContentSize().width/2)*self.m_fMinScaleX, self.m_CurrentMJPoint.y + 90*self.m_fMinScaleY - MY_MJ_DATA_EDGE_316*self.m_fMinScaleY),
            cc.p(self.m_CurrentMJPoint.x + self.m_iMJWidth*iTouchMoveIndex+(self.m_HandMJData[iInMoveIndex].m_pSpriteMJBack:getContentSize().width/2)*self.m_fMinScaleX, self.m_CurrentMJPoint.y - MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)
        }    

        local a = cc.DelayTime:create(0.2)
        local b = cc.CardinalSplineTo:create(0.4, pArrayBack, 1)
        local seqMJBack = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CardinalSplineTo:create(0.4, pArrayBack, 1))
        local seqMJData = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CardinalSplineTo:create(0.4, pArrayData, 1), cc.CallFunc:create(
            function ()
                if not self.m_iOrbitStatus  then
                    self.m_HandMJData[iInMoveIndex].m_pSpriteMJData:setPositionY(self.m_CurrentMJPoint.y - MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)
                    self.m_bPositive = true
                end
            end))

        self.m_HandMJData[iInMoveIndex].m_bTouch = false
        self.m_HandMJData[iInMoveIndex].m_pSpriteMJBack:runAction(seqMJBack)
        self.m_HandMJData[iInMoveIndex].m_pSpriteMJData:runAction(seqMJData)

    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(
            function ()
                iHandMJCount = #self.m_HandMJData
                if iHandMJCount > 0 and not self.m_iOrbitStatus then
                    self.m_HandMJData[iHandMJCount].m_pSpriteMJBack:setPositionY(self.m_CurrentMJPoint.y)
                    self.m_HandMJData[iHandMJCount].m_pSpriteMJData:setPositionY(self.m_CurrentMJPoint.y-MY_MJ_DATA_EDGE_316*self.m_fMinScaleY)
                end
                self.m_bPositive = true
            end)))
    end
end

function ASMJ_HandMJControl:DeleteMJData1(cbMJData, htType, ptCurrent)

    self.m_bPositive = false
    local iDeleteMJCount = 0
    local iHandMJCount = #self.m_HandMJData

    if htType == HT_PENG_316 then
        iDeleteMJCount = 2
    elseif htType == HT_MING_GANG_316 then
        iDeleteMJCount = 3
    elseif htType == HT_ZIMO_GANG_316 then
        iDeleteMJCount = 1
    elseif htType == HT_AN_GANG_316 then
        iDeleteMJCount = 4
    else
        assert(false, "error ASMJ_HandMJControl:DeleteMJData1")
    end

    local iSpendMJCount = 0
    for i=iHandMJCount,1,-1 do
        if iSpendMJCount >= iDeleteMJCount then
            break
        end

        if self.m_HandMJData[i].m_cbHandMJData == cbMJData then
            self.m_HandMJData[i].m_pSpriteMJBack:removeFromParent()
            self.m_HandMJData[i].m_pSpriteMJData:removeFromParent()
            table.remove(self.m_HandMJData, i) 

            iSpendMJCount = iSpendMJCount + 1
        end
    end

    assert(iSpendMJCount == iDeleteMJCount, "error delete1 icount is not enough")

    table.sort(self.m_HandMJData, 
        function(a,b) 
            if a.m_cbHandMJData==b.m_cbHandMJData then
                return a.m_iMJIndex < b.m_iMJIndex
            else
                return a.m_cbHandMJData<b.m_cbHandMJData
            end
        end)

    
    iHandMJCount = #self.m_HandMJData
    local bCurrentMJ = iHandMJCount % 3 == 2
    self.m_CurrentMJPoint.x = ptCurrent.x

    for i=1,iHandMJCount do
        self.m_HandMJData[i].m_bTouch = false
    end

    self:RectifyMJPoint(0, false)
    self.m_bPositive = true

    return
end
