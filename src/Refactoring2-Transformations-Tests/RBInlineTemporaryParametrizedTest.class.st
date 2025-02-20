Class {
	#name : #RBInlineTemporaryParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBInlineTemporaryParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBInlineTemporaryRefactoring };
		addCase: { #rbClass -> RBInlineTemporaryTransformation };
		yourself
]

{ #category : #accessing }
RBInlineTemporaryParametrizedTest >> constructor [
	^ #inline:from:in:
]

{ #category : #tests }
RBInlineTemporaryParametrizedTest >> testInlineTemporary [
	| refactoring |
	refactoring := self createRefactoringWithArguments:
		{ (24 to: 72) . #inlineMethod . RBRefactoryTestDataApp }.

	self executeRefactoring: refactoring.

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeForSelector: #inlineMethod) equals: (self parseMethod: 'inlineMethod
										^self
													foo;
													inlineMethod;
													bar')
]

{ #category : #'failure tests' }
RBInlineTemporaryParametrizedTest >> testInlineTemporaryBadInterval [
	self shouldFail: (self createRefactoringWithArguments:
		{ (29 to: 100) . #moveDefinition . RBRefactoryTestDataApp })
]

{ #category : #'failure tests' }
RBInlineTemporaryParametrizedTest >> testInlineTemporaryMutlipleAssignment [
	self shouldFail: (self createRefactoringWithArguments:
		{ (58 to: 81) . #moveDefinition . RBRefactoryTestDataApp })
]

{ #category : #'failure tests' }
RBInlineTemporaryParametrizedTest >> testInlineTemporaryReadBeforeWritten [
	self shouldFail: (self createRefactoringWithArguments:
		{ (48 to: 56) . #inlineTemporary . RBRefactoryTestDataApp })
]
