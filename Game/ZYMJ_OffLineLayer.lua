local ASMJ_OffLineLayer = class("ASMJ_OffLineLayer", function() return cc.Layer:create() end)

--ctor()
function ASMJ_OffLineLayer:ctor()
    print("ASMJ_OffLineLayer:ctor")
    self:init()
end

--create( ... )
function ASMJ_OffLineLayer_create()
    print("ASMJ_OffLineLayer_create")
    local layer = ASMJ_OffLineLayer.new()
    return layer
end

function ASMJ_OffLineLayer:onAcitonEnd()
    self:removeFromParent()
end

--init()
function ASMJ_OffLineLayer:init()

    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    self:setPosition(0, 0)

    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,128),visibleSize.width,visibleSize.height)
    self:addChild(layerColor, 0)

    local pRound = cc.Sprite:create("316_offline_round.png")
    pRound:setScale(scalex, scaley)
    pRound:setPosition(visibleSize.width/2, visibleSize.height/2)
    self:addChild(pRound, 1)
    pRound:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))

end
