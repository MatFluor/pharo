"
I build a tree with the testsResult created by comments listed in groups: 
- Errors
- Failures
- Passed test
I am used in DrTestsUI to show the results in a orderly manner.
"
Class {
	#name : #DTCommentToTestResult,
	#superclass : #DTPluginResult,
	#instVars : [
		'testsResult'
	],
	#category : #'DrTests-CommentsToTests-Base'
}

{ #category : #accessing }
DTCommentToTestResult >> buildTreeForUI [
	<dtCommentToTestResultTreeNamed: 'Grouped by type of result' order: 1>

	^ DTTreeNode new
		subResults: {
			(DTTreeNode new
				name: 'Errors';
				subResults: (self testResults errors collect: [:each | each asResultForDrTest ]);
				startExpanded;
				displayColorIfNotEmpty: self theme testColorError;
				yourself).
			(DTTreeNode new
				name: 'Failures';
				subResults: (self testResults failures
					collect:  [:each | each asResultForDrTest]
					as: OrderedCollection);
				startExpanded;
				displayColorIfNotEmpty: self theme testColorFailure;
				yourself).
			(DTTreeNode new
				name: 'Passed tests';
				subResults: (self testResults passed collect:  [:each | each asResultForDrTest] );
				displayColorIfNotEmpty: self theme testColorPassing;
				yourself) };
		yourself
]

{ #category : #accessing }
DTCommentToTestResult >> testResults [
	^ testsResult
]

{ #category : #accessing }
DTCommentToTestResult >> testResults: anObject [
	testsResult := anObject
]
