"
In Smalltalk, methods like ifTrue: are inlined an there is no Block for the arguments of these message sends.
To be consistent, these blocks need nevertheless a scope.


"
Class {
	#name : #OCOptimizedBlockScope,
	#superclass : #OCBlockScope,
	#instVars : [
		'isInlinedLoop'
	],
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #initialization }
OCOptimizedBlockScope >> initialize [
	super initialize.
	isInlinedLoop := false
]

{ #category : #testing }
OCOptimizedBlockScope >> isInsideOptimizedLoop [
	^ isInlinedLoop
		ifTrue: [true]
		ifFalse: [self outerScope isInsideOptimizedLoop]
]

{ #category : #testing }
OCOptimizedBlockScope >> isOptimized [

	^ true
]

{ #category : #mark }
OCOptimizedBlockScope >> markInlinedLoop [
	isInlinedLoop := true
]

{ #category : #lookup }
OCOptimizedBlockScope >> nextOuterScopeContextOf: aContext [

	"Returns the next context to lookup a variable name from within outer scope.

	For inlined BlockClosure which I represent it will be same context because inlined blocks do not produce extra contexts on stack"
	^ aContext
]

{ #category : #accessing }
OCOptimizedBlockScope >> outerNotOptimizedScope [
	^self outerScope outerNotOptimizedScope
]
