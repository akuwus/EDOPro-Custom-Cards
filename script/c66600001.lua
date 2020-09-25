--Medusa, the Dream Mirror Gorgon by aku (https://www.youtube.com/c/akuwus)
local card_entity, id = GetID()

-- Field Spells Globals
card_entity.listed_names={CARD_DREAM_MIRROR_JOY, CARD_DREAM_MIRROR_TERROR }

function card_entity.initial_effect(c)

    -- Link Summoning Conditions
    Link.AddProcedure(c, aux.FilterBoolFunctionEx( Card.IsSetCard, 0x131), 2, 2, card_entity.lcheck)
    c:EnableReviveLimit()

    -- Card is Special Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(card_entity.sptg)
	e1:SetOperation(card_entity.spop)
    c:RegisterEffect(e1)

    -- Dream Mirror of Joy
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(card_entity.dspcon)
	e2:SetCost(card_entity.dspcost)
	e2:SetTarget(card_entity.dsptg)
	e2:SetOperation(card_entity.dspop)
    c:RegisterEffect(e2)
    
    -- Dream Mirror of Terror
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(card_entity.joydspcon)
	e3:SetCost(card_entity.joydspcost)
	e3:SetTarget(card_entity.joydsptg)
	e3:SetOperation(card_entity.joydspop)
    c:RegisterEffect(e3)
end

-- E1

function card_entity.filter(c,tp)
	return c:IsCode(CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR)
end

function card_entity.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(card_entity.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
end 

function card_entity.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(card_entity.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if g:GetClassCount(Card.GetCode)<1 then return end

	local tg1=g:Select(tp,1,1,nil)

    aux.PlayFieldSpell(tg1:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
end 

-- E1 End

-- E2

function card_entity.dspcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_JOY),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end

function card_entity.dspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function card_entity.dspfilter(c,e,tp)
	return c:IsSetCard(0xcf)
end

function card_entity.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(card_entity.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function card_entity.dspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,card_entity.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then 
        Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end
end

-- E2 End

-- E3

function card_entity.joydspcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_TERROR),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end

function card_entity.joydspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function card_entity.joydspfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x131) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function card_entity.joydsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(card_entity.joydspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function card_entity.joydspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,card_entity.joydspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then 
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- E3 End