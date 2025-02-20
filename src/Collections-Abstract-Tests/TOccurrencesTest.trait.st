"
A trait for test purposes
"
Trait {
	#name : #TOccurrencesTest,
	#category : #'Collections-Abstract-Tests-Traits'
}

{ #category : #requirements }
TOccurrencesTest >> collectionWithoutEqualElements [
	self explicitRequirement
]

{ #category : #requirements }
TOccurrencesTest >> elementNotInForOccurrences [
" return an element notIncluded in #collectionWithoutEqualElements"
	self explicitRequirement
]

{ #category : #requirements }
TOccurrencesTest >> empty [
	self explicitRequirement
]

{ #category : #'tests - fixture' }
TOccurrencesTest >> test0FixtureOccurrencesTest [
	| tmp |
	self empty.
	self assertEmpty: self empty.
	self collectionWithoutEqualElements.
	self denyEmpty: self collectionWithoutEqualElements.
	tmp := OrderedCollection new.
	self collectionWithoutEqualElements
		do: [ :each |
			self deny: (tmp includes: each).
			tmp add: each ].
	self elementNotInForOccurrences.
	self deny: (self collectionWithoutEqualElements includes: self elementNotInForOccurrences)
]

{ #category : #'tests - occurrencesOf' }
TOccurrencesTest >> testOccurrencesOf [
	| collection |
	collection := self collectionWithoutEqualElements .

	collection do: [ :each | self assert: (collection occurrencesOf: each) equals: 1 ]
]

{ #category : #'tests - occurrencesOf' }
TOccurrencesTest >> testOccurrencesOfEmpty [
	| result |
	result := self empty occurrencesOf: self collectionWithoutEqualElements anyOne.
	self assert: result equals: 0
]

{ #category : #'tests - occurrencesOf' }
TOccurrencesTest >> testOccurrencesOfNotIn [

	| result |
	result := self collectionWithoutEqualElements occurrencesOf: self elementNotInForOccurrences.
	self assert: result equals: 0
]
