-- Nyx, the Dream Mirror Shadow by aku (https://www.youtube.com/c/akuwus)
local card_entity, id = GetID()

-- Field Spells Globals
card_entity.listed_names={CARD_DREAM_MIRROR_JOY, CARD_DREAM_MIRROR_TERROR }

function card_entity.initial_effect(c)
    
    -- Fusion Summon
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x131),card_entity.matfilter)
    c:EnableReviveLimit()

    -- Must first be Fusion Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.fuslimit)
    c:RegisterEffect(e1)
    
    -- Card is Special Summoned.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(card_entity.target)
	e2:SetOperation(card_entity.operation)
    c:RegisterEffect(e2)

    -- Field Spells cannot be destroyed.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetValue(1)
    c:RegisterEffect(e3)
    
    -- Cannot be destroyed by Card Effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	e4:SetCondition(card_entity.indcon)
    c:RegisterEffect(e4)
    
    -- Cannot be destroyed by Battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	e5:SetCondition(card_entity.indconbattle)
	c:RegisterEffect(e5)
end

function card_entity.matfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp)
end

-- E2

function card_entity.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function card_entity.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and card_entity.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(card_entity.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,card_entity.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function card_entity.eqlimit(e,c)
	return e:GetOwner()==c
end
function card_entity.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
	end
end

-- E2 End

-- E4

function card_entity.indcon(e, tp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_TERROR),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

-- E4 End

-- E4

function card_entity.indconbattle(e, tp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_JOY),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

-- E4 End