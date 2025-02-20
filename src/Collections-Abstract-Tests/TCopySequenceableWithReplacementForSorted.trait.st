"
A trait for test purposes
"
Trait {
	#name : #TCopySequenceableWithReplacementForSorted,
	#category : #'Collections-Abstract-Tests-Traits'
}

{ #category : #requirements }
TCopySequenceableWithReplacementForSorted >> collectionOfSize5 [
" return a collection of size 5"
self explicitRequirement
]

{ #category : #requirements }
TCopySequenceableWithReplacementForSorted >> empty [
self explicitRequirement
]

{ #category : #requirements }
TCopySequenceableWithReplacementForSorted >> replacementCollection [
" return a collection including elements of type 'collectionOfSize5' elements'type"
self explicitRequirement
]

{ #category : #'tests - fixture' }
TCopySequenceableWithReplacementForSorted >> test0FixtureCopyWithReplacementForSorted [
	self collectionOfSize5.
	self assert: self collectionOfSize5 size = 5.
	self replacementCollection.
	self denyEmpty: self replacementCollection.
	self empty.
	self assertEmpty: self empty
]

{ #category : #'tests - copying with replacement for sorted' }
TCopySequenceableWithReplacementForSorted >> testCopyFromToWithForSorted [
	| collection result |
	collection := self collectionOfSize5.

	"Testing that elements to be replaced are removed from the copy :"
	result := collection copyReplaceFrom: 1 to: collection size with: self empty.
	self assertEmpty: result.

	"Testing that replacement elements  are all put into the copy :"
	result := collection copyReplaceFrom: 1 to: collection size with: self replacementCollection.
	self replacementCollection do: [ :each | self assert: (result occurrencesOf: each) equals: (self replacementCollection occurrencesOf: each) ].

	self assert: result size equals: self replacementCollection size
]

{ #category : #'tests - copying with replacement for sorted' }
TCopySequenceableWithReplacementForSorted >> testCopyReplaceAllWithForSorted [
	| collection result |
	collection := self collectionOfSize5.

	"Testing that elements to be replaced are removed from the copy :"
	result := collection copyReplaceAll: collection with: self empty.
	self assertEmpty: result.

	"Testing that replacement elements  are all put into the copy :"
	result := collection copyReplaceAll: collection with: self replacementCollection.
	self replacementCollection do: [ :each | self assert: (result occurrencesOf: each) equals: (self replacementCollection occurrencesOf: each) ].

	self assert: result size equals: self replacementCollection size
]
