-- Galaxy-Eyes Alternative Photon Dragon by aku (https://www.youtube.com/c/akuwus)
local card_entity, id = GetID()
local galaxy_eyes_photon_dragon_id = 93717133

function card_entity.initial_effect(c)
    c:EnableUnsummonable()
    
    -- Treated as Galaxy-Eyes Photon Dragon.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(galaxy_eyes_photon_dragon_id)
    c:RegisterEffect(e1)
    
    -- Special Summon from Hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
    e2:SetCondition(card_entity.spcon)
    e2:SetTarget(card_entity.sptg)
	e2:SetOperation(card_entity.spop)
    c:RegisterEffect(e2)
    
    -- Special Summon search.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetTarget(card_entity.srtg)
	e3:SetOperation(card_entity.srop)
    c:RegisterEffect(e3)
    
    -- XYZ Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(card_entity.spxyztg)
	e4:SetOperation(card_entity.sxyzpop)
	c:RegisterEffect(e4)
end

-- E2

function card_entity.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,galaxy_eyes_photon_dragon_id)
end

function card_entity.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,true,true,true,c,nil,nil,false,e:GetHandler(),galaxy_eyes_photon_dragon_id)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function card_entity.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

-- E2 End

-- E3

function card_entity.filter(c)
	return ( c:IsSetCard(0x55) or c:IsSetCard(0x7b) ) and c:IsAbleToHand()
end
function card_entity.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(card_entity.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function card_entity.srop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,card_entity.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- E3 End

-- E4

function card_entity.spfilter(c,e,tp,mc,pg)
	return c:IsType(TYPE_XYZ) and ( c:IsSetCard(0x55) or c:IsSetCard(0x7b) ) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
		and mc:IsCanBeXyzMaterial(c,tp)	and (#pg<=0 or pg:IsContains(mc)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function card_entity.spxyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return #pg<=1 and Duel.IsExistingMatchingCard(card_entity.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler(),pg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function card_entity.sxyzpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,card_entity.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,pg)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if #mg~=0 then
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			Duel.Overlay(sc,Group.FromCards(c))
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
		end
	end
end

-- E4 End