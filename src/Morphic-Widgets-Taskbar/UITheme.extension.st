Extension { #name : #UITheme }

{ #category : #'*Morphic-Widgets-Taskbar' }
UITheme >> newBasicTaskbarButtonIn: aTaskbar for: aMorph [
	"Answer a taskbar button morph for the given window."

	|lm lab button labSize|

	labSize := (150 // (aTaskbar tasks size + 1) max: 10) min: 30.

	lab := (self buttonLabelForText: (aMorph taskbarLabel truncateWithElipsisTo: labSize)).

	aMorph taskbarButtonIsActive ifTrue: [ lab emphasis: 1 ].

	lm := self
		newRowIn: aTaskbar
		for: {((self iconNamed: aMorph taskbarIconName) ifNil: [^nil]) asMorph. lab}.

	lm cellInset: 2.

	button := self
		newButtonIn: aTaskbar
		for: aMorph
		getState: #taskbarButtonIsActive
		action: #taskbarButtonClicked
		arguments: #()
		getEnabled: nil
		label: lm
		help: nil.

	button
		useSquareCorners;
		wantsYellowButtonMenu: true;
		getMenuSelector: #taskbarButtonMenu:.


	^button
]

{ #category : #'*Morphic-Widgets-Taskbar' }
UITheme >> openTaskListIn: world from: aKeyboardEvent [

	| tasklistMorph |
	tasklistMorph := TaskListMorph from: aKeyboardEvent.
	tasklistMorph openInWorld: world
]
