"
An OmNullStoreTest is a test class for testing the behavior of OmNullStore
"
Class {
	#name : #OmStoreFactoryTest,
	#superclass : #TestCase,
	#category : #'Ombu-Tests'
}

{ #category : #resources }
OmStoreFactoryTest >> aStoreName [

	^ 'aTestGlobalName'
]

{ #category : #tests }
OmStoreFactoryTest >> testNullStore [
	| factory store |
	factory := OmStoreFactory new.
	store := factory null.
	self assertEmpty: store entries.
	self assert: factory null == store description: 'Singleton'
]

{ #category : #tests }
OmStoreFactoryTest >> testStoreNamed [

	| factory store storeAgain anEntry |
	factory := OmStoreFactory new.
	store := factory named: self aStoreName.
	storeAgain := factory named: self aStoreName.
	self assert: storeAgain == store description: 'Singleton'.

	anEntry := OmEntry content: 42.
	store newEntry: anEntry.
	self assert: (store entries includes: anEntry).

	"tearDown in test"
	store flush.
	store ensureDeleteFile
]
