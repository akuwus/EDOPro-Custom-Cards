--Redeyeclipse World by aku (https://www.youtube.com/c/akuwus)

local s, id = GetID()
function s.initial_effect(c)
    aux.AddFieldSkillProcedure(c,2,false)

    -- Activate
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_ACTIVATE)
	ea:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(ea)

    -- Attack Decrease
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_FZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetValue(-1000)
	c:RegisterEffect(e0)

    -- Attack Boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(1000)
	c:RegisterEffect(e1)

    -- Save a Red-Eyes Card.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.target)
	e2:SetValue(1)
    c:RegisterEffect(e2)
    
	-- Once per turn: Negate an Attack.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    
    -- Card is untouchable.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetCondition(s.econ)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
end

---

function s.econ(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

---

function s.op(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PREDRAW)
        e1:SetCondition(s.flipcon)
        e1:SetOperation(s.flipop)
        Duel.RegisterEffect(e1,tp)
    end
    e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    --condition
    return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
end

---

function s.target(e,c)
	return c:IsSetCard(0x3b) and c:IsFaceup()
end

---

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
