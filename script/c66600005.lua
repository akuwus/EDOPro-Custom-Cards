--Photon Galaxy by aku (https://www.youtube.com/c/akuwus)
local card_entity, id = GetID()

function card_entity.initial_effect(c)
	-- Activation (Field Spell)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    -- Tributing Cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_SZONE)
	e2:SetCost(card_entity.cost)
	e2:SetOperation(card_entity.activate)
    c:RegisterEffect(e2)
    
    -- Banish
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCountLimit(1)
	e3:SetOperation(card_entity.operation)
	c:RegisterEffect(e3)
end

-- E2

function card_entity.filter(c)
	return ( c:IsSetCard(0x55) or c:IsSetCard(0x7b) )
end

function card_entity.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end

function card_entity.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DECREASE_TRIBUTE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(aux.TargetBoolFunction(card_entity.filter))
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    e1:SetValue(0x2)
	e:GetHandler():RegisterEffect(e1)
end

-- E2 End

-- E3

function card_entity.operation(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	
	if #g>0 then
	    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- E3 End