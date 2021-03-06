module Data.Nat

%default total

export
Uninhabited (Z = S n) where
  uninhabited Refl impossible

export
Uninhabited (S n = Z) where
  uninhabited Refl impossible

public export
isZero : Nat -> Bool
isZero Z     = True
isZero (S n) = False

public export
isSucc : Nat -> Bool
isSucc Z     = False
isSucc (S n) = True

public export
data IsSucc : (n : Nat) -> Type where
  ItIsSucc : IsSucc (S n)

export
Uninhabited (IsSucc Z) where
  uninhabited ItIsSucc impossible

public export
isItSucc : (n : Nat) -> Dec (IsSucc n)
isItSucc Z = No absurd
isItSucc (S n) = Yes ItIsSucc

public export
power : Nat -> Nat -> Nat
power base Z       = S Z
power base (S exp) = base * (power base exp)

public export
hyper : Nat -> Nat -> Nat -> Nat
hyper Z        a b      = S b
hyper (S Z)    a Z      = a
hyper (S(S Z)) a Z      = Z
hyper n        a Z      = S Z
hyper (S pn)   a (S pb) = hyper pn a (hyper (S pn) a pb)

public export
pred : Nat -> Nat
pred Z     = Z
pred (S n) = n

-- Comparisons

public export
data NotBothZero : (n, m : Nat) -> Type where
  LeftIsNotZero  : NotBothZero (S n) m
  RightIsNotZero : NotBothZero n     (S m)

public export
data LTE  : (n, m : Nat) -> Type where
  LTEZero : LTE Z    right
  LTESucc : LTE left right -> LTE (S left) (S right)

export
Uninhabited (LTE (S n) Z) where
  uninhabited LTEZero impossible

public export
GTE : Nat -> Nat -> Type
GTE left right = LTE right left

public export
LT : Nat -> Nat -> Type
LT left right = LTE (S left) right

public export
GT : Nat -> Nat -> Type
GT left right = LT right left

export
succNotLTEzero : Not (LTE (S m) Z)
succNotLTEzero LTEZero impossible

export
fromLteSucc : LTE (S m) (S n) -> LTE m n
fromLteSucc (LTESucc x) = x

export
isLTE : (m, n : Nat) -> Dec (LTE m n)
isLTE Z n = Yes LTEZero
isLTE (S k) Z = No succNotLTEzero
isLTE (S k) (S j)
    = case isLTE k j of
           No contra => No (contra . fromLteSucc)
           Yes prf => Yes (LTESucc prf)

export
lteRefl : {n : Nat} -> LTE n n
lteRefl {n = Z}   = LTEZero
lteRefl {n = S k} = LTESucc lteRefl

export
lteSuccRight : LTE n m -> LTE n (S m)
lteSuccRight LTEZero     = LTEZero
lteSuccRight (LTESucc x) = LTESucc (lteSuccRight x)

export
lteSuccLeft : LTE (S n) m -> LTE n m
lteSuccLeft (LTESucc x) = lteSuccRight x

export
lteTransitive : LTE n m -> LTE m p -> LTE n p
lteTransitive LTEZero y = LTEZero
lteTransitive (LTESucc x) (LTESucc y) = LTESucc (lteTransitive x y)

export
lteAddRight : (n : Nat) -> LTE n (n + m)
lteAddRight Z = LTEZero
lteAddRight (S k) {m} = LTESucc (lteAddRight {m} k)

export
notLTImpliesGTE : {a, b : _} -> Not (LT a b) -> GTE a b
notLTImpliesGTE {b = Z} _ = LTEZero
notLTImpliesGTE {a = Z} {b = S k} notLt = absurd (notLt (LTESucc LTEZero))
notLTImpliesGTE {a = S k} {b = S j} notLt = LTESucc (notLTImpliesGTE (notLt . LTESucc))

public export
lte : Nat -> Nat -> Bool
lte Z        right     = True
lte left     Z         = False
lte (S left) (S right) = lte left right

public export
gte : Nat -> Nat -> Bool
gte left right = lte right left

public export
lt : Nat -> Nat -> Bool
lt left right = lte (S left) right

public export
gt : Nat -> Nat -> Bool
gt left right = lt right left

public export
minimum : Nat -> Nat -> Nat
minimum Z m = Z
minimum (S n) Z = Z
minimum (S n) (S m) = S (minimum n m)

public export
maximum : Nat -> Nat -> Nat
maximum Z m = m
maximum (S n) Z = S n
maximum (S n) (S m) = S (maximum n m)

-- Proofs on S

export
eqSucc : (left, right : Nat) -> left = right -> S left = S right
eqSucc _ _ Refl = Refl

export
succInjective : (left, right : Nat) -> S left = S right -> left = right
succInjective _ _ Refl = Refl

export
SIsNotZ : (S x = Z) -> Void
SIsNotZ Refl impossible

export partial
modNatNZ : Nat -> (y: Nat) -> Not (y = Z) -> Nat
modNatNZ left Z         p = void (p Refl)
modNatNZ left (S right) _ = mod' left left right
  where
    mod' : Nat -> Nat -> Nat -> Nat
    mod' Z        centre right = centre
    mod' (S left) centre right =
      if lte centre right then
        centre
      else
        mod' left (minus centre (S right)) right

export partial
modNat : Nat -> Nat -> Nat
modNat left (S right) = modNatNZ left (S right) SIsNotZ

export partial
divNatNZ : Nat -> (y: Nat) -> Not (y = Z) -> Nat
divNatNZ left Z         p = void (p Refl)
divNatNZ left (S right) _ = div' left left right
  where
    div' : Nat -> Nat -> Nat -> Nat
    div' Z        centre right = Z
    div' (S left) centre right =
      if lte centre right then
        Z
      else
        S (div' left (minus centre (S right)) right)

export partial
divNat : Nat -> Nat -> Nat
divNat left (S right) = divNatNZ left (S right) SIsNotZ

export partial
divCeilNZ : Nat -> (y: Nat) -> Not (y = Z) -> Nat
divCeilNZ x y p = case (modNatNZ x y p) of
  Z   => divNatNZ x y p
  S _ => S (divNatNZ x y p)

export partial
divCeil : Nat -> Nat -> Nat
divCeil x (S y) = divCeilNZ x (S y) SIsNotZ

public export
Integral Nat where
  div = divNat
  mod = modNat

export partial
gcd : (a: Nat) -> (b: Nat) -> {auto ok: NotBothZero a b} -> Nat
gcd a Z     = a
gcd Z b     = b
gcd a (S b) = gcd (S b) (modNatNZ a (S b) SIsNotZ)

export partial
lcm : Nat -> Nat -> Nat
lcm _ Z     = Z
lcm Z _     = Z
lcm a (S b) = divNat (a * (S b)) (gcd a (S b))

--------------------------------------------------------------------------------
-- An informative comparison view
--------------------------------------------------------------------------------
public export
data CmpNat : Nat -> Nat -> Type where
     CmpLT : (y : _) -> CmpNat x (x + S y)
     CmpEQ : CmpNat x x
     CmpGT : (x : _) -> CmpNat (y + S x) y

export
total cmp : (x, y : Nat) -> CmpNat x y
cmp Z Z     = CmpEQ
cmp Z (S k) = CmpLT _
cmp (S k) Z = CmpGT _
cmp (S x) (S y) with (cmp x y)
  cmp (S x) (S (x + (S k))) | CmpLT k = CmpLT k
  cmp (S x) (S x)           | CmpEQ   = CmpEQ
  cmp (S (y + (S k))) (S y) | CmpGT k = CmpGT k

-- Proofs on +

export
plusZeroLeftNeutral : (right : Nat) -> 0 + right = right
plusZeroLeftNeutral _ = Refl

export
plusZeroRightNeutral : (left : Nat) -> left + 0 = left
plusZeroRightNeutral Z     = Refl
plusZeroRightNeutral (S n) = rewrite plusZeroRightNeutral n in Refl

export
plusSuccRightSucc : (left, right : Nat) -> S (left + right) = left + (S right)
plusSuccRightSucc Z _ = Refl
plusSuccRightSucc (S left) right = rewrite plusSuccRightSucc left right in Refl

export
plusCommutative : (left, right : Nat) -> left + right = right + left
plusCommutative Z right = rewrite plusZeroRightNeutral right in Refl
plusCommutative (S left) right =
  rewrite plusCommutative left right in
    rewrite plusSuccRightSucc right left in
      Refl

export
plusAssociative : (left, centre, right : Nat) ->
  left + (centre + right) = (left + centre) + right
plusAssociative Z _ _ = Refl
plusAssociative (S left) centre right =
    rewrite plusAssociative left centre right in Refl

export
plusConstantRight : (left, right, c : Nat) -> left = right ->
  left + c = right + c
plusConstantRight _ _ _ Refl = Refl

export
plusConstantLeft : (left, right, c : Nat) -> left = right ->
  c + left = c + right
plusConstantLeft _ _ _ Refl = Refl

export
plusOneSucc : (right : Nat) -> 1 + right = S right
plusOneSucc _ = Refl

export
plusLeftCancel : (left, right, right' : Nat) ->
  left + right = left + right' -> right = right'
plusLeftCancel Z _ _ p = p
plusLeftCancel (S left) right right' p =
    plusLeftCancel left right right' (succInjective _ _ p)

export
plusRightCancel : (left, left', right : Nat) ->
  left + right = left' + right -> left = left'
plusRightCancel left left' right p =
  plusLeftCancel right left left' $
    rewrite plusCommutative right left in
      rewrite plusCommutative right left' in
        p

export
plusLeftLeftRightZero : (left, right : Nat) ->
  left + right = left -> right = Z
plusLeftLeftRightZero left right p =
  plusLeftCancel left right Z $
    rewrite plusZeroRightNeutral left in
      p

-- Proofs on *

export
multZeroLeftZero : (right : Nat) -> Z * right = Z
multZeroLeftZero _ = Refl

export
multZeroRightZero : (left : Nat) -> left * Z = Z
multZeroRightZero Z        = Refl
multZeroRightZero (S left) = multZeroRightZero left

export
multRightSuccPlus : (left, right : Nat) ->
  left * (S right) = left + (left * right)
multRightSuccPlus Z _ = Refl
multRightSuccPlus (S left) right =
  rewrite multRightSuccPlus left right in
  rewrite plusAssociative left right (left * right) in
  rewrite plusAssociative right left (left * right) in
  rewrite plusCommutative right left in
          Refl

export
multLeftSuccPlus : (left, right : Nat) ->
  (S left) * right = right + (left * right)
multLeftSuccPlus _ _ = Refl

export
multCommutative : (left, right : Nat) -> left * right = right * left
multCommutative Z right = rewrite multZeroRightZero right in Refl
multCommutative (S left) right =
  rewrite multCommutative left right in
  rewrite multRightSuccPlus right left in
          Refl

export
multDistributesOverPlusLeft : (left, centre, right : Nat) ->
  (left + centre) * right = (left * right) + (centre * right)
multDistributesOverPlusLeft Z _ _ = Refl
multDistributesOverPlusLeft (S k) centre right =
  rewrite multDistributesOverPlusLeft k centre right in
    rewrite plusAssociative right (k * right) (centre * right) in
      Refl

export
multDistributesOverPlusRight : (left, centre, right : Nat) ->
  left * (centre + right) = (left * centre) + (left * right)
multDistributesOverPlusRight left centre right =
  rewrite multCommutative left (centre + right) in
    rewrite multCommutative left centre in
      rewrite multCommutative left right in
  multDistributesOverPlusLeft centre right left

export
multAssociative : (left, centre, right : Nat) ->
  left * (centre * right) = (left * centre) * right
multAssociative Z _ _ = Refl
multAssociative (S left) centre right =
  rewrite multAssociative left centre right in
    rewrite multDistributesOverPlusLeft centre (mult left centre) right in
      Refl

export
multOneLeftNeutral : (right : Nat) -> 1 * right = right
multOneLeftNeutral right = plusZeroRightNeutral right

export
multOneRightNeutral : (left : Nat) -> left * 1 = left
multOneRightNeutral left = rewrite multCommutative left 1 in multOneLeftNeutral left


-- Proofs on minus

export
minusSuccSucc : (left, right : Nat) ->
  minus (S left) (S right) = minus left right
minusSuccSucc _ _ = Refl

export
minusZeroLeft : (right : Nat) -> minus 0 right = Z
minusZeroLeft _ = Refl

export
minusZeroRight : (left : Nat) -> minus left 0 = left
minusZeroRight Z     = Refl
minusZeroRight (S _) = Refl

export
minusZeroN : (n : Nat) -> Z = minus n n
minusZeroN Z     = Refl
minusZeroN (S n) = minusZeroN n

export
minusOneSuccN : (n : Nat) -> S Z = minus (S n) n
minusOneSuccN Z     = Refl
minusOneSuccN (S n) = minusOneSuccN n

export
minusSuccOne : (n : Nat) -> minus (S n) 1 = n
minusSuccOne Z     = Refl
minusSuccOne (S _) = Refl

export
minusPlusZero : (n, m : Nat) -> minus n (n + m) = Z
minusPlusZero Z     _ = Refl
minusPlusZero (S n) m = minusPlusZero n m

export
minusMinusMinusPlus : (left, centre, right : Nat) ->
  minus (minus left centre) right = minus left (centre + right)
minusMinusMinusPlus Z Z _ = Refl
minusMinusMinusPlus (S _) Z _ = Refl
minusMinusMinusPlus Z (S _) _ = Refl
minusMinusMinusPlus (S left) (S centre) right =
  rewrite minusMinusMinusPlus left centre right in Refl

export
plusMinusLeftCancel : (left, right : Nat) -> (right' : Nat) ->
  minus (left + right) (left + right') = minus right right'
plusMinusLeftCancel Z _ _ = Refl
plusMinusLeftCancel (S left) right right' =
  rewrite plusMinusLeftCancel left right right' in Refl

export
multDistributesOverMinusLeft : (left, centre, right : Nat) ->
  (minus left centre) * right = minus (left * right) (centre * right)
multDistributesOverMinusLeft Z Z _ = Refl
multDistributesOverMinusLeft (S left) Z right =
  rewrite minusZeroRight (right + (left * right)) in Refl
multDistributesOverMinusLeft Z (S _) _ = Refl
multDistributesOverMinusLeft (S left) (S centre) right =
  rewrite multDistributesOverMinusLeft left centre right in
  rewrite plusMinusLeftCancel right (left * right) (centre * right) in
          Refl

export
multDistributesOverMinusRight : (left, centre, right : Nat) ->
  left * (minus centre right) = minus (left * centre) (left * right)
multDistributesOverMinusRight left centre right =
    rewrite multCommutative left (minus centre right) in
    rewrite multDistributesOverMinusLeft centre right left in
    rewrite multCommutative centre left in
    rewrite multCommutative right left in
            Refl

-- power proofs

multPowerPowerPlus : (base, exp, exp' : Nat) ->
  power base (exp + exp') = (power base exp) * (power base exp')
-- multPowerPowerPlus base Z       exp' =
--     rewrite sym $ plusZeroRightNeutral (power base exp') in Refl
-- multPowerPowerPlus base (S exp) exp' =
--   rewrite multPowerPowerPlus base exp exp' in
--     rewrite sym $ multAssociative base (power base exp) (power base exp') in
--       Refl

powerOneNeutral : (base : Nat) -> power base 1 = base
powerOneNeutral base = rewrite multCommutative base 1 in multOneLeftNeutral base

powerOneSuccOne : (exp : Nat) -> power 1 exp = 1
powerOneSuccOne Z       = Refl
powerOneSuccOne (S exp) = rewrite powerOneSuccOne exp in Refl

powerPowerMultPower : (base, exp, exp' : Nat) ->
  power (power base exp) exp' = power base (exp * exp')
powerPowerMultPower _ exp Z = rewrite multZeroRightZero exp in Refl
powerPowerMultPower base exp (S exp') =
  rewrite powerPowerMultPower base exp exp' in
  rewrite multRightSuccPlus exp exp' in
  rewrite sym $ multPowerPowerPlus base exp (exp * exp') in
          Refl

-- minimum / maximum proofs

maximumAssociative : (l, c, r : Nat) ->
  maximum l (maximum c r) = maximum (maximum l c) r
maximumAssociative Z _ _ = Refl
maximumAssociative (S _) Z _ = Refl
maximumAssociative (S _) (S _) Z = Refl
maximumAssociative (S k) (S j) (S i) = rewrite maximumAssociative k j i in Refl

maximumCommutative : (l, r : Nat) -> maximum l r = maximum r l
maximumCommutative Z Z = Refl
maximumCommutative Z (S _) = Refl
maximumCommutative (S _) Z = Refl
maximumCommutative (S k) (S j) = rewrite maximumCommutative k j in Refl

maximumIdempotent : (n : Nat) -> maximum n n = n
-- maximumIdempotent Z = Refl
-- maximumIdempotent (S k) = cong $ maximumIdempotent k

minimumAssociative : (l, c, r : Nat) ->
  minimum l (minimum c r) = minimum (minimum l c) r
minimumAssociative Z _ _ = Refl
minimumAssociative (S _) Z _ = Refl
minimumAssociative (S _) (S _) Z = Refl
minimumAssociative (S k) (S j) (S i) = rewrite minimumAssociative k j i in Refl

minimumCommutative : (l, r : Nat) -> minimum l r = minimum r l
minimumCommutative Z Z = Refl
minimumCommutative Z (S _) = Refl
minimumCommutative (S _) Z = Refl
minimumCommutative (S k) (S j) = rewrite minimumCommutative k j in Refl

minimumIdempotent : (n : Nat) -> minimum n n = n
-- minimumIdempotent Z = Refl
-- minimumIdempotent (S k) = cong (minimumIdempotent k)

minimumZeroZeroLeft : (left : Nat) -> minimum left 0 = Z
minimumZeroZeroLeft left = rewrite minimumCommutative left 0 in Refl

minimumSuccSucc : (left, right : Nat) ->
  minimum (S left) (S right) = S (minimum left right)
minimumSuccSucc _ _ = Refl

maximumZeroNLeft : (left : Nat) -> maximum left Z = left
maximumZeroNLeft left = rewrite maximumCommutative left Z in Refl

maximumSuccSucc : (left, right : Nat) ->
  S (maximum left right) = maximum (S left) (S right)
maximumSuccSucc _ _ = Refl

sucMaxL : (l : Nat) -> maximum (S l) l = (S l)
-- sucMaxL Z = Refl
-- sucMaxL (S l) = cong $ sucMaxL l

sucMaxR : (l : Nat) -> maximum l (S l) = (S l)
-- sucMaxR Z = Refl
-- sucMaxR (S l) = cong $ sucMaxR l

sucMinL : (l : Nat) -> minimum (S l) l = l
-- sucMinL Z = Refl
-- sucMinL (S l) = cong $ sucMinL l

sucMinR : (l : Nat) -> minimum l (S l) = l
-- sucMinR Z = Refl
-- sucMinR (S l) = cong $ sucMinR l
