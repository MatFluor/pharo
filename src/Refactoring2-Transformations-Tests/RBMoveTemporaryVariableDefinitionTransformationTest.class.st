Class {
	#name : #RBMoveTemporaryVariableDefinitionTransformationTest,
	#superclass : #RBTransformationTest,
	#category : #'Refactoring2-Transformations-Tests-Test'
}

{ #category : #tests }
RBMoveTemporaryVariableDefinitionTransformationTest >> testMethodDoesNotExist [

	self shouldFail: (RBMoveTemporaryVariableDefinitionTransformation
							variable: #temp
							inMethod: #name1
							inClass: #RBDummyLintRuleTest)
]

{ #category : #tests }
RBMoveTemporaryVariableDefinitionTransformationTest >> testMoveDefinition [

	| transformation class |
	transformation := (RBMoveTemporaryVariableDefinitionTransformation
							variable: #temp
							inMethod: #moveDefinition
							inClass: #RBDummyRefactoryTestDataApp)
							transform.

	class := transformation model classNamed: #RBDummyRefactoryTestDataApp.
	self assert: (class parseTreeForSelector: #moveDefinition)
		  equals: (self parseMethod: 'moveDefinition
								^(self collect:
										[:each |
										| temp |
										temp := each printString.
										temp , temp])
									select:
										[:each |
										| temp |
										temp := each size.
										temp odd]')
]

{ #category : #tests }
RBMoveTemporaryVariableDefinitionTransformationTest >> testMoveDefinitionIntoBlockThatIsAReceiverOfACascadedMessage [

	| transformation class |
	transformation := (RBMoveTemporaryVariableDefinitionTransformation
							variable: #association
							inMethod: #referencesConditionFor:
							inClass: #RBDummyRefactoryTestDataApp)
							asRefactoring transform.

	class := transformation model classNamed: #RBDummyRefactoryTestDataApp.
	self assert: (class parseTreeForSelector: #referencesConditionFor:)
		  equals: (self parseMethod: 'referencesConditionFor: aClass
						| environment  |
						^(RBCondition withBlock:
								[| association |association := Smalltalk associationAt: aClass name
											ifAbsent: [self refactoringError: ''Could not find class''].
								environment := (self environment referencesTo: association)
											| (self environment referencesTo: aClass name).
								environment isEmpty])
							errorMacro: aClass , '' is referenced.<n>Browse references?'';
							errorBlock: [environment openEditor];
							yourself')
]

{ #category : #tests }
RBMoveTemporaryVariableDefinitionTransformationTest >> testNowhereToMove [

	| transformation |
	transformation := (RBMoveTemporaryVariableDefinitionTransformation
							variable: #temp
							inMethod: #noMoveDefinition
							inClass: #RBDummyRefactoryTestDataApp).
	self assert: transformation model changes changes size equals: 0.

	self shouldFail: (RBMoveTemporaryVariableDefinitionTransformation
							variable: #temp
							inMethod: #noMoveDefinition
							inClass: #RBDummyRefactoryTestDataApp)
							asRefactoring
]

{ #category : #tests }
RBMoveTemporaryVariableDefinitionTransformationTest >> testVariableDoesNotExist [

	self shouldFail: (RBMoveTemporaryVariableDefinitionTransformation
							variable: #temp
							inMethod: #displayName
							inClass: #RBDummyLintRuleTest).
	self shouldFail: (RBMoveTemporaryVariableDefinitionTransformation
							variable: #temp
							inMethod: #displayName
							inClass: #RBDummyLintRuleTest)
							asRefactoring
]
