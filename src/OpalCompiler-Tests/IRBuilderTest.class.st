Class {
	#name : #IRBuilderTest,
	#superclass : #AbstractEnvironmentTestCase,
	#classVars : [
		'TestToPush'
	],
	#category : #'OpalCompiler-Tests-IR'
}

{ #category : #accessing }
IRBuilderTest class >> compilerClass [
	^ OpalCompiler
]

{ #category : #accessing }
IRBuilderTest class >> testToPush [
	^TestToPush
]

{ #category : #accessing }
IRBuilderTest class >> testToPush: anObject [

	TestToPush := anObject
]

{ #category : #'tests - builder' }
IRBuilderTest >> testBuildMethod [
	|  aCompiledMethod |

	aCompiledMethod := IRBuilder buildMethod: [ : builder |
		builder pushLiteral: 3;
		pushDup;
		send: #=;
		returnTop].

	self assert: (aCompiledMethod isKindOf: CompiledMethod)
]

{ #category : #tests }
IRBuilderTest >> testDup [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder buildIR: [ : builder |
		builder pushLiteral: 3;
		pushDup;
		send: #=;
		returnTop].

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
  	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #() ).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testInstVar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushInstVar: 1;
		pushInstVar: 2;
		send: #+;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: 3 @ 4 arguments: #()) equals: 7.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testJumpAheadTo [
	| iRMethod aCompiledMethod iRBuilder |
	iRBuilder := IRBuilder new.
	iRMethod := iRBuilder
		pushLiteral: 2;
		pushLiteral: 1;
		send: #+;
		jumpAheadTo: #end;
		pushLiteral: 3;
		jumpAheadTarget: #end;
		returnTop;
		ir.


	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 3.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testJumpAheadToIf [

	| iRMethod aCompiledMethod |

	iRMethod := IRBuilder new
		pushReceiver;
		pushLiteral: true;
		jumpAheadTo: #end if: true;
		returnTop;
		jumpAheadTarget: #end;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
 	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) isNil).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testJumpBackTo [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushLiteral: false;
		jumpBackTarget: #begin;
		jumpAheadTo: #end if: true;
		pushLiteral: true;
		jumpBackTo: #begin;
		jumpAheadTarget: #end;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) isNil).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralArray [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: #(test 4 you);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: #(test 4 you).
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralBoolean [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: true;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() )).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralCharacter [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: $e;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: $e.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralFloat [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 2.0;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
 	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) closeTo: 2.0).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralInteger [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 2;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralNil [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: nil;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
     self assert: ((aCompiledMethod valueWithReceiver: 4 arguments: #() ) isNil).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralString [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 'hello';
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 'hello'.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralSymbol [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: #you;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: #you.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralVariableClass [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteralVariable: Object binding;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: Object.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralVariableClassVariable [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteralVariable: (OCOpalExamples classVariableNamed: #ExampleClassVariable);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	OCOpalExamples new classVariable: #tag.
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: #tag.
	OCOpalExamples reset.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testLiteralVariableGlobale [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteralVariable: (testingEnvironment associationAt: #Smalltalk);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: Smalltalk.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPopTop [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushLiteral: false;
		popTop;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) isNil).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushConsArray [
	| iRMethod aCompiledMethod receiver |
	iRMethod := IRBuilder new
		pushReceiver;
		pushConsArray: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	receiver := 5 @ 8.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: receiver arguments: #()) first identicalTo: receiver.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushConsArray2 [
	| iRMethod aCompiledMethod receiver |
	iRMethod := IRBuilder new
		pushLiteral: 'hi!';
		pushConsArray: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	receiver := 5 @ 8.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: receiver arguments: #()) equals: #('hi!').
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushNewArray [

	| iRMethod aCompiledMethod receiver |
	iRMethod := IRBuilder new

		pushNewArray: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	receiver :=  (5@8).

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: receiver arguments: #()) first isNil).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushSelf [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		send: #class;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) identicalTo: UndefinedObject.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushTempArgument [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		numArgs: 2;
		addTemps: #(a b);
		pushTemp: #a;
		pushTemp: #b;
		send: #+;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #(2 8)) equals: 10.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushTempTemp [

	| iRMethod aCompiledMethod  |
	iRMethod := IRBuilder new
		addTemps: #(a);
		pushTemp: #a;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
     self assert: ((aCompiledMethod valueWithReceiver: 5 arguments: #() ) isNil).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushThisContext [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushThisContext;
		send: #receiver;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: 5 arguments: #()) equals: 5.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testPushThisProcess [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushThisProcess;
		send: #class;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: Process.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testReturnInstVar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushInstVar: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: 3 @ 4 arguments: #()) equals: 3.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testReturnTop [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: false;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self deny: (aCompiledMethod valueWithReceiver: nil arguments: #()).
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testSendSuper [

	| iRMethod aCompiledMethod  |
	iRMethod := IRBuilder new
		pushReceiver;
		send: #isThisEverCalled toSuperOf: self class;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
     self should: [(aCompiledMethod valueWithReceiver: (self class new) arguments: #())] raise: Error.
	^iRMethod
]

{ #category : #tests }
IRBuilderTest >> testStoreIntoVariable [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 4;
		storeIntoLiteralVariable: (self class bindingOf: #TestToPush);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	aCompiledMethod valueWithReceiver: nil arguments: #().
	self assert: self class testToPush equals: 4.
	self class testToPush: nil.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testStoreIvar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 34;
		storeInstVar: 2;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: self arguments: #()) equals: 34.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testStorePopIntoVariable [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 4;
		storeIntoLiteralVariable: (self class bindingOf: #TestToPush);
		popTop;
		pushLiteralVariable: (self class bindingOf: #TestToPush);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	aCompiledMethod valueWithReceiver: nil arguments: #().
	self assert: self class testToPush equals: 4.
	self class testToPush: nil.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testStorePopIvar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 34;
		storeInstVar: 2;
		popTop;
		pushInstVar: 2;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: self arguments: #()) equals: 34.
	^ iRMethod
]

{ #category : #tests }
IRBuilderTest >> testStoreTemp [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(a);
		pushLiteral: 34;
		storeTemp: #a;
		popTop;
		pushTemp: #a;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 34.
	^ iRMethod
]
