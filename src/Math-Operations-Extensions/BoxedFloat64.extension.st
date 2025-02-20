Extension { #name : #BoxedFloat64 }

{ #category : #'*Math-Operations-Extensions' }
BoxedFloat64 >> arcTan [
	"Answer the angle in radians.
	 Optional. See Object documentation whatIsAPrimitive."

	| theta eps step sinTheta cosTheta |
	<primitive: 57>

	"Newton-Raphson"
	self < 0.0 ifTrue: [ ^ 0.0 - (0.0 - self) arcTan ].

	"first guess"
	theta := (self * Halfpi) / (self + 1.0).

	"iterate"
	eps := Halfpi * MathApproximationEpsilon.
	step := theta.
	[(step * step) > eps] whileTrue: [
		sinTheta := theta sin.
		cosTheta := theta cos.
		step := (sinTheta * cosTheta) - (self * cosTheta * cosTheta).
		theta := theta - step].
	^ theta
]

{ #category : #'*Math-Operations-Extensions' }
BoxedFloat64 >> sin [
	"Answer the sine of the receiver taken as an angle in radians.
	 Optional. See Object documentation whatIsAPrimitive."

	| sum delta self2 i |
	<primitive: 56>

	"Taylor series"
	"normalize to the range [0..Pi/2]"
	self < 0.0 ifTrue: [^ (0.0 - ((0.0 - self) sin))].
	self > Twopi ifTrue: [^ (self \\ Twopi) sin].
	self > Pi ifTrue: [^ (0.0 - (self - Pi) sin)].
	self > Halfpi ifTrue: [^ (Pi - self) sin].

	"unroll loop to avoid use of abs"
	sum := delta := self.
	self2 := 0.0 - (self * self).
	i := 2.0.
	[delta > MathApproximationEpsilon] whileTrue: [
		"once"
		delta := (delta * self2) / (i * (i + 1.0)).
		i := i + 2.0.
		sum := sum + delta.
		"twice"
		delta := (delta * self2) / (i * (i + 1.0)).
		i := i + 2.0.
		sum := sum + delta].
	^ sum
]

{ #category : #'*Math-Operations-Extensions' }
BoxedFloat64 >> sqrt [
	"Answer the square root of the receiver.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 55>
	| exp guess eps delta |
	self <= 0.0
		ifTrue: [ ^ self = 0.0
				ifTrue: [ 0.0 ]
				ifFalse: [ "v Chg" DomainError signal: 'sqrt undefined for number less than zero.' ] ].
	"Newton-Raphson"
	"first guess is half the exponent"
	exp := self exponent // 2.
	guess := self timesTwoPower: 0 - exp.
	"get eps value"
	eps := guess * MathApproximationEpsilon.
	eps := eps * eps.
	delta := (self - (guess * guess)) / (guess * 2.0).
	[ delta * delta > eps ]
		whileTrue: [ guess := guess + delta.
			delta := (self - (guess * guess)) / (guess * 2.0) ].
	^ guess
]
