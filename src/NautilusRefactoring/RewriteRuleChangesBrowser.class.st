"
A changes browser for the changes generated by the rewrite rule editor
"
Class {
	#name : #RewriteRuleChangesBrowser,
	#superclass : #SpPresenter,
	#instVars : [
		'#changes',
		'#selectedChanges',
		'#changeTree => ObservableSlot',
		'#diffView => ObservableSlot',
		'#buttonCancel => ObservableSlot',
		'#buttonOk => ObservableSlot'
	],
	#category : #'NautilusRefactoring-Utilities'
}

{ #category : #'instance creation' }
RewriteRuleChangesBrowser class >> changes: aCollection [

	^ self new
		changes: aCollection;
		yourself
]

{ #category : #layout }
RewriteRuleChangesBrowser class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: (SpPanedLayout newTopToBottom
			add: #changeTree;
			add: #diffView;
		yourself);
		add: (SpBoxLayout newLeftToRight
			addLast: #buttonCancel expand: false fill: true padding: 2;
			addLast: #buttonOk expand: false fill: false padding: 0;
			yourself)
		expand: false
		fill: false
		padding: 2;
		yourself
]

{ #category : #actions }
RewriteRuleChangesBrowser >> accept [
	self okToChange
		ifFalse: [ ^ self ].
	self selectedChanges isEmptyOrNil ifTrue: [ ^self ].
	[ self selectedChanges do: [ :change | RBRefactoryChangeManager instance performChange: change ] ] asJob
		title: 'Refactoring';
		run.
	self window delete
]

{ #category : #update }
RewriteRuleChangesBrowser >> buildDiffFor: aChange [

	^ aChange
		ifNil: [ '' ]
		ifNotNil: [
			diffView
				contextClass: aChange changeClass;
				leftText: aChange oldVersionTextToDisplay;
				rightText: aChange textToDisplay ]
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> buttonCancel [
	^ buttonCancel
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> buttonCancel: anObject [
	buttonCancel := anObject
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> buttonOk [
	^ buttonOk
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> buttonOk: anObject [
	buttonOk := anObject
]

{ #category : #actions }
RewriteRuleChangesBrowser >> cancel [
	self window delete
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> changeTree [
	^ changeTree
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> changeTree: anObject [
	changeTree := anObject
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> changes [
	^ changes
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> changes: anObject [
	changes := anObject.
	selectedChanges := OrderedCollection withAll: changes first changes.
	self updateChanges
]

{ #category : #initialization }
RewriteRuleChangesBrowser >> connectPresenters [
	changeTree children: [ :aChange |
		(aChange isNotNil and: [aChange changesSize > 1])
			ifTrue: [ aChange changes ]
			ifFalse: [#()]].
	buttonCancel action: [ self cancel ].
	buttonOk action: [ self accept ]
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> diffView [
	^ diffView
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> diffView: anObject [
	diffView := anObject
]

{ #category : #initialization }
RewriteRuleChangesBrowser >> initialize [
	changes := #().
	super initialize
]

{ #category : #initialization }
RewriteRuleChangesBrowser >> initializePresenters [
	changeTree := self newTreeTable.
	changeTree addColumn: (
		SpCompositeTableColumn new
			title: 'Changes';
			addColumn: ((SpCheckBoxTableColumn title: ' ' evaluated: [ :change | selectedChanges includes: change ])
				onActivation: [ :change |
					selectedChanges add: change];
				onDeactivation: [ :change |
					selectedChanges remove: change];
				width: 20;
				yourself);
			addColumn: (SpStringTableColumn evaluated: #nameToDisplay));
		whenActivatedDo: [ :selection | self buildDiffFor: selection selectedItem  ].
	diffView := self newDiff.
	diffView showOptions: true.
	buttonCancel := self newButton label: 'Cancel'.
	buttonOk := self newButton label: 'Ok'.
	self focusOrder
		add: buttonCancel;
		add: buttonOk
]

{ #category : #initialization }
RewriteRuleChangesBrowser >> initializeWindow: aWindowPresenter [
	| fontWidth rowHeight |
	fontWidth := (StandardFonts defaultFont widthOfString: 'M').
	rowHeight := self class inputTextHeight.
	aWindowPresenter
		title: self windowTitle;
		initialExtent: (70@20) * (fontWidth @ rowHeight)
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> selectedChanges [
	^ selectedChanges
]

{ #category : #accessing }
RewriteRuleChangesBrowser >> selectedChanges: anObject [
	selectedChanges := anObject
]

{ #category : #update }
RewriteRuleChangesBrowser >> updateChanges [
	| aCompositeChange |
	aCompositeChange := RBRefactoryChangeManager changeFactory
		compositeRefactoryChange.
	changes do: [ :each | aCompositeChange addChange: each ].

	"Later we could filter the shown changes depending on the selected scope"

	changeTree roots: (aCompositeChange whatToDisplayIn: self)
]

{ #category : #initialization }
RewriteRuleChangesBrowser >> windowTitle [

	^ 'Changes Browser'
]
