"
Checks for literal arrays that contain the #, symbol. The user may have thought that it was a separator.
"
Class {
	#name : #ReLiteralArrayContainsCommaRule,
	#superclass : #ReNodeBasedRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #accessing }
ReLiteralArrayContainsCommaRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"

	^'LiteralArrayContainsCommaRule'
]

{ #category : #running }
ReLiteralArrayContainsCommaRule >> basicCheck: aNode [

	aNode isLiteralArray ifFalse: [ ^ false ].

	"ffiCall: parameters and other UFFI call variants contain a $, so do not warn in this case"
	(aNode parent parent isMessage and: [
		 FFICompilerPlugin ffiCalloutSelectors includes: aNode parent parent selector ]) ifTrue: [ ^ false ].

	^ aNode value includes: #,
]

{ #category : #accessing }
ReLiteralArrayContainsCommaRule >> group [
	^ 'Coding Idiom Violation'
]

{ #category : #accessing }
ReLiteralArrayContainsCommaRule >> name [
	^ 'Literal array contains a #,'
]
