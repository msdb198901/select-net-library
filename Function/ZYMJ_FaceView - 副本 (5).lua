local ASMJ_FaceView = class("ASMJ_FaceView", function() return CLayerEx:create() end)
--ASMJ_FaceView.__index = ASMJ_FaceView

--init()
function ASMJ_FaceView:init()
    cclog("ASMJ_FaceView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

    --face bg
    local m_faceBg = cc.Sprite:createWithSpriteFrameName("0_head_bg.png")
    self.m_faceImg = cc.Sprite:createWithSpriteFrameName("0_head_0.png")

    self:setContentSize(m_faceBg:getContentSize())

    --face ID
    m_faceBg:setPosition(m_faceBg:getContentSize().width / 2, m_faceBg:getContentSize().height / 2)
    self.m_faceImg:setPosition(m_faceBg:getContentSize().width / 2, m_faceBg:getContentSize().height / 2 + 3)

    self:addChild(m_faceBg, 0)
    self:addChild(self.m_faceImg, 1)
end

--function SetFaceID
function ASMJ_FaceView:SetFaceID(id)
    cclog("ASMJ_FaceView:SetFaceID")
    if id ~= self.m_iFaceID then
        self.m_iFaceID = id
        if self.m_iFaceID == -1 then
            if  self.m_faceImg == nil then
                self.m_faceImg = cc.Sprite:createWithSpriteFrame("0_head_0.png")
            else
                self.m_faceImg:setSpriteFrame("0_head_0.png")
            end
        else
            if not ((id >= 0 and id <= 3) or (id >=50 and id <=53) or (id >=100 and id <= 113) or (id >= 150 and id <= 163)) then
                id = 0
            end
            self.m_faceImg:setSpriteFrame(string.format("0_head_%d.png", id))
        end
    end
end

--ctor()
function ASMJ_FaceView:ctor()
    cclog("ASMJ_FaceView:ctor")

    self.m_iFaceID = -1
    self:setIgnoreAnchorPointForPosition(false)
    
    self:init()
end

--create( ... )
function ASMJ_FaceView_createLayer( ... )
    cclog("ASMJ_FaceView_createLayer")
    local layer = ASMJ_FaceView.new()
    return layer
end