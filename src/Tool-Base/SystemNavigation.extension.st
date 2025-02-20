Extension { #name : #SystemNavigation }

{ #category : #'*Tool-Base' }
SystemNavigation >> allMethodsWithSourceString: aString matchCase: caseSensitive [
	"Answer a SortedCollection of all the methods that contain, in source code, aString as a substring.  Search the class comments also"

	| list addMethod addComment |
	list := OrderedCollection new.
	addMethod := [ :mrClass :mrSel | list add: (mrClass>>mrSel)].									
	addComment := [ :mrClass | list add: (RGCommentDefinition realClass: mrClass)].										
	self allBehaviorsDo: [:each |
		each selectorsDo: [:sel | 
			((each sourceCodeAt: sel) includesSubstring: aString caseSensitive: caseSensitive) 
					ifTrue: [ addMethod value: each value: sel ]].
			(each organization classComment asString includesSubstring: aString caseSensitive: caseSensitive) ifTrue: [ addComment value: each]	].
	^ list 
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllAccessesTo: instVarName from: aClass [
	"Create and schedule a Message Set browser for all the receiver's methods 
	or any methods of a subclass/superclass that refer to the instance variable name."

	"self new browseAllAccessesTo: 'x' from: Point."

	| methods slot |
	slot := aClass slotNamed: instVarName.
	methods := aClass allMethodsAccessingSlot: slot.
	
	^ self
		browseMessageList: methods
		name: 'Accesses to ' , instVarName
		autoSelect: instVarName
		refreshingBlock: [ :method | slot isAccessedIn: method ]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllCallsOnClass: aClass [
	"Create and schedule a message browser on each method that refers to 
	aClass. For example, SystemNavigation new browseAllCallsOnClass: Object."

	^ self
		browseMessageList: (aClass allCallsOnIn: self)
		name: 'Users of class ' , aClass instanceSide name
		autoSelect: aClass instanceSide name
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllImplementorsOf: selector [
	"Create and schedule a message browser on each method that implements 
	the message whose selector is the argument, selector. For example,  
	Smalltalk browseAllImplementorsOf: #at:put:."

	"Create and schedule a senders browser for aSelector."	

	^ self
		browseMessageList: (self allImplementorsOf: selector)
		name: 'Implementors of ' , selector asString
		autoSelect: selector
		refreshingBlock: [:message | message selector = selector ].
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllReferencesTo: aLiteral [ 
	"Create and schedule a message browser on each method that refers to 
	aLiteral. For example, SystemNavigation new browseAllSendersOf: #printOn:."

	^ self openBrowserFor: aLiteral withMethods: (self allCallsOn: aLiteral) 
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllSelect: aBlock [ 
	"Create and schedule a message browser on each method that, when used 
	as the block argument to aBlock gives a true result. For example,  
	SystemNavigation new browseAllSelect: [:method | method numLiterals >  
	10]."

	^ self
		browseMessageList: (self allMethodsSelect: aBlock)
		name: 'selected messages'
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllSelect: aBlock name: aName autoSelect: autoSelectString [ 
	"Create and schedule a message browser on each method that, when used 
	as the block argument to aBlock gives a true result."
	"self new browseAllSelect: [:method | method numLiterals > 10] name:  
	'Methods with more than 10 literals' autoSelect: 'isDigit'"
	
	^ self
		browseMessageList: (self allMethodsSelect: aBlock)
		name: aName
		autoSelect: autoSelectString
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllSendersOf: aLiteral [ 
	"Create and schedule a message browser on each method that refers to 
	aLiteral. For example, SystemNavigation new browseAllSendersOf: #printOn:."

	^ self openBrowserFor: aLiteral withMethods: (self allCallsOn: aLiteral) 
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllSendersOrUsersOf: aLiteralOrClass [ 
	"Create and schedule a message browser on each method that refers to 
	a literal or class name"
   | senders globalRefs |
   senders := self allCallsOn: aLiteralOrClass.
   globalRefs := self allGlobalRefsOn: aLiteralOrClass.
	^ self openBrowserFor: aLiteralOrClass withMethods: (senders, globalRefs)
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllStoresInto: instVarName from: aClass [
    "Create and schedule a Message Set browser for all the receiver's methods 
    or any methods of a subclass/superclass that refer to the instance variable name."

    "self new browseAllStoresInto: 'x' from: Point."

	| methods slot |
	slot := aClass slotNamed: instVarName.
	methods := aClass allMethodsWritingSlot: slot.
	
	^ self
		browseMessageList: methods
		name: 'Stores into ' , instVarName
		autoSelect: instVarName
		refreshingBlock: [ :method | slot isWrittenIn: method ]

]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseAllUsersOfTrait: aTrait [

	"Launch a class-list list browser on all classes or traits which import aTrait"

	^ self tools messageList browseClasses: aTrait traitUsers
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseClassCommentsWithString: aString matchCase: caseSensitive [
	"Smalltalk browseClassCommentsWithString: 'my instances' "
	"Launch a message list browser on all class comments containing aString as a substring."

	|  suffix list |
	suffix := caseSensitive 
		ifTrue: [' (case-sensitive)']
		ifFalse: [' (case-insensitive)'].
	list := Set new.
	Cursor wait showWhile: [
		self environment allClassesDo: [:class | 
			(class organization classComment asString 
							includesSubstring: aString caseSensitive: caseSensitive) ifTrue: [
								list add: (RGCommentDefinition realClass: class)
							]
		]
	].
	^ self 
		browseMessageList: list asSortedCollection
		name: 'Class comments containing ' , aString printString , suffix
		autoSelect: aString
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseClassVarRefs: aClass [
	"Put up a menu offering all class variable names; if the user chooses one, open up a message-list browser on all methods 
	that refer to the selected class variable"
	| lines labelStream allVars index owningClasses |
	
	"This method should be split into two -- one part that can be tested, and a wrapper that does the UI stuff."
	lines := OrderedCollection new.
	allVars := OrderedCollection new.
	owningClasses := OrderedCollection new.
	labelStream := (String new: 200) writeStream. "Why the heck is a writeStream needed?"
	aClass withAllSuperclasses reverseDo:
		[:class | | vars |
		vars := class classVarNames.
		vars do:
			[:var |
			labelStream nextPutAll: var; cr.
			allVars add: var.
			owningClasses add: class].
		vars isEmpty ifFalse: [lines add: allVars size]].
	labelStream contents isEmpty ifTrue: [^self inform: 'No class variables found']. "handle nil superclass better"
	labelStream skip: -1 "cut last CR".
	index := (UIManager default chooseFrom: (labelStream contents substrings) lines: lines).
	index = 0 ifTrue: [^ self].
	^ self browseAllReferencesTo:
		((owningClasses at: index) classPool associationAt: (allVars at: index))
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseClassVariables: aClass [

	^ aClass classPool inspectWithLabel: 'Class Variables in ' , aClass name
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseClassesWithNamesContaining: aString caseSensitive: caseSensitive [

	"Launch a class-list list browser on all classes whose names containg aString as a substring."

	"SystemNavigation default browseClassesWithNamesContaining: 'Morph' caseSensitive: true "

	| classes |
	classes := self environment allClasses select: [ :class | 
		           class name
			           includesSubstring: aString
			           caseSensitive: caseSensitive ].
	^ self tools messageList browseClasses: classes
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseHierarchy: aBehavior [

	^ self browseHierarchy: aBehavior selector: nil
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseHierarchy: aClass selector: aSelector [

	"Open a browser"

	aClass ifNil: [ ^ self ].
	^ self tools browser new
		  spawnHierarchyForClass: aClass selector: aSelector;
		  yourself
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseInstVarDefs: aClass [

	^ self chooseInstVarFrom: aClass thenDo: 
		[:aVar | self browseAllStoresInto: aVar from: aClass]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseInstVarRefs: aClass [
	
	^ self chooseInstVarFrom: aClass thenDo: 
		[:aVar | self browseAllAccessesTo: aVar from: aClass]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseMessageList: messageList name: label [ 
	"Create and schedule a MessageSet browser on messageList."

	^ self   
		browseMessageList: messageList 
		name: label 
		autoSelect: nil
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseMessageList: messageList name: labelString autoSelect: autoSelectString [
	"By default it never refreshes"
	^self browseMessageList: messageList name: labelString autoSelect: autoSelectString refreshingBlock: [ :method | false ]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseMessageList: messageList name: labelString autoSelect: autoSelectString refreshingBlock: aBlock [

	"Create and schedule a MessageSet browser on the message list."

	| methods |
	"Do not show trait methods"
	methods := messageList reject: [ :each | each isFromTrait ].
	methods isEmpty ifTrue: [ 
		^ self inform: 'There are no ' , String cr , labelString ].

	^ self tools messageList new
		  messages: methods;
		  title: labelString;
		  autoSelect: autoSelectString;
		  refreshingBlock: aBlock;
		  open
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseMethodsWhoseNamesContain: aString [
	"Launch a tool which shows all methods whose names contain the given 	string; case-insensitive."

	^ self browseAllSelect: [ :e | e selector includesSubstring: aString caseSensitive: false ].
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseMethodsWithSourceString: aString matchCase: caseSensitive [
	"SystemNavigation new browseMethodsWithSourceString: 'SourceString'"
	"Launch a browser on all methods whose source code, inluding string literals and comments, contains aString as a substring."
	| suffix |

	suffix := caseSensitive
				ifTrue: [' (case-sensitive)']
				ifFalse: [' (case-insensitive)'].
	^ self
		browseMessageList: (self allMethodsWithSourceString: aString matchCase: caseSensitive)
		name: 'Methods containing ' , aString printString , suffix
		autoSelect: aString
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseMethodsWithString: aString matchCase: caseSensitive [
	"Launch a browser on all methods that contain string literals with aString as a substring. Make the search case-sensitive or insensitive as dictated by the caseSensitive boolean parameter"

	^ self browseAllSelect:
			[:method |
				method  hasLiteralSuchThat: [:lit |
					lit isString and: [lit isSymbol not and: [  
					lit includesSubstring: aString caseSensitive: caseSensitive]]]]
		name:  'Methods with string ', aString printString, (caseSensitive ifTrue: [' (case-sensitive)'] ifFalse: [' (case-insensitive)'])
		autoSelect: aString.

]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseObsoleteReferences [
	<script>
	"Open a browser on all referenced behaviors that are obsolete"
	"SystemNavigation new browseObsoleteReferences"

	| list |
	list := self methodsReferencingObsoleteClasses.
	^ self 
		browseMessageList: list
		name: 'Method referencing obsoletes'
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseSendersOf: aSelector name: labelString autoSelect: autoSelectString [
	
	^ self
		browseMessageList: (self allCallsOn: aSelector)
		name: labelString
		autoSelect: autoSelectString
		refreshingBlock: [ :method | method hasSelector: aSelector ]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> browseUndeclaredReferences [
	"
	SystemNavigation new browseUndeclaredReferences
	"
	
	Undeclared removeUnreferencedKeys.
	Undeclared associations do: [:binding |
		self
			browseMessageList: (self allReferencesTo: binding )
			name: 'References to Undeclared: ', binding key printString ]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> chooseInstVarAlphabeticallyFrom: aClass thenDo: aBlock [
	| allVars index |
	"Put up a menu of all the instance variables in the receiver, presented in alphabetical order, and when the user chooses one, evaluate aBlock with the chosen variable as its parameter."

	allVars := aClass allInstVarNames sort.
	allVars isEmpty ifTrue: [^ self inform: 'There are no instance variables'].

	index := (UIManager default chooseFrom: allVars lines: #() title: 'Instance variables in ', aClass name).
	index = 0 ifTrue: [^ aClass].
	aBlock value: (allVars at: index)
]

{ #category : #'*Tool-Base' }
SystemNavigation >> chooseInstVarFrom: aClass thenDo: aBlock [ 
	"Put up a menu of all the instance variables in the receiver, and when
the user chooses one, evaluate aBlock with the chosen variable as its
parameter.  If the list is 6 or larger, then offer an alphabetical
formulation as an alternative. triggered by a 'show alphabetically' item
at the top of the list."

	| lines labelStream allVars index count offerAlpha |
	(count := aClass allInstVarNames size) = 0 ifTrue: 
		[^ self inform: 'There are no 
instance variables.'].

	allVars := OrderedCollection new.
	lines := OrderedCollection new.
	labelStream := (String new: 200) writeStream.
	(offerAlpha := count > 5)
		ifTrue:
			[lines add: 1.
			allVars add: 'show alphabetically'.
			labelStream nextPutAll: allVars first; cr].
	aClass withAllSuperclasses reverseDo:
		[:class | | vars |
		vars := class instVarNames.
		vars do:
			[:var |
			labelStream nextPutAll: var; cr.
			allVars add: var].
		vars isEmpty ifFalse: [lines add: allVars size]].
	labelStream skip: -1 "cut last CR".
	(lines notEmpty and: [lines last = allVars size]) ifTrue:
		[lines removeLast].  "dispense with inelegant line beneath last item"
	index := (UIManager default chooseFrom: (labelStream contents substrings: {Character cr}) lines: lines
title: 'Instance variables in ', aClass name).
	index = 0 ifTrue: [^ self].
	(index = 1 and: [offerAlpha]) ifTrue: [^ self
chooseInstVarAlphabeticallyFrom: aClass thenDo: aBlock].
	aBlock value: (allVars at: index)
]

{ #category : #'*Tool-Base' }
SystemNavigation >> classFromPattern: pattern withCaption: aCaption [
	"If there is a class whose name exactly given by pattern, return it.
	If there is only one class in the system whose name matches pattern, return it.
	Otherwise, put up a menu offering the names of all classes that match pattern, and return the class chosen, else nil if nothing chosen.
	This method ignores tab, space, & cr characters in the pattern"

	| toMatch potentialClassNames classNames exactMatch index |
	(toMatch := pattern
		copyWithoutAll:
			{(Character space).
			(Character cr).
			(Character tab)}) isEmpty
		ifTrue: [ ^ nil ].
	Symbol
		hasInterned: toMatch
		ifTrue: [ :patternSymbol | 
			self environment
				at: patternSymbol
				ifPresent: [ :maybeClass | 
					^ maybeClass isClassOrTrait 
						ifTrue: [ maybeClass ]
						ifFalse: [ maybeClass class ]
					]].
	toMatch := (toMatch copyWithout: $.) asLowercase.
	potentialClassNames := (self environment classNames , self environment traitNames) asOrderedCollection.
	classNames := pattern last = $.
		ifTrue: [ potentialClassNames select: [ :nm | nm asLowercase = toMatch ] ]
		ifFalse: [ potentialClassNames select: [ :n | n includesSubstring: toMatch caseSensitive: false ] ].
	classNames isEmpty
		ifTrue: [ ^ nil ].
	exactMatch := classNames detect: [ :each | each asLowercase = toMatch ] ifNone: [ nil ].
	index := classNames size = 1
		ifTrue: [ 1 ]
		ifFalse: [ 
			exactMatch
				ifNil: [ UIManager default chooseFrom: classNames lines: #() title: aCaption ]
				ifNotNil: [ 
					classNames addFirst: exactMatch.
					UIManager default chooseFrom: classNames lines: #(1) title: aCaption ] ].
	index = 0
		ifTrue: [ ^ nil ].
	^ self environment at: (classNames at: index) asSymbol	"
	self default classFromPattern: 'znak' withCaption: ''
	self default classFromPattern: 'orph' withCaption: ''
	self default classFromPattern: 'TCompil' withCaption: ''
"
]

{ #category : #'*Tool-Base' }
SystemNavigation >> confirmRemovalOf: aSelector on: aClass [ 
	"Determine if it is okay to remove the given selector. Answer 1 if it  
	should be removed, 2 if it should be removed followed by a senders  
	browse, and 3 if it should not be removed."
	
	| count answer caption allCalls |
	allCalls := self allCallsOn: aSelector.
	(count := allCalls size) = 0
		ifTrue: [^ 1].
	"no senders -- let the removal happen without warning"
	count = 1
		ifTrue: [(allCalls first actualClass == aClass
					and: [allCalls first selector == aSelector])
				ifTrue: [^ 1]].
	"only sender is itself"
	caption := 'The message ', aSelector printString ,' has ' , count printString , ' sender' asPluralBasedOn: count.
	
	answer := UIManager default 
		chooseFrom: #('Remove it'
				'Remove, then browse senders'
				'Don''t remove, but show me those senders'
				'Forget it -- do nothing -- sorry I asked') title: caption.
	answer = 3
		ifTrue: [self
				browseMessageList: allCalls
				name: 'Senders of ' , aSelector
				autoSelect: aSelector keywords first].
	answer = 0
		ifTrue: [answer := 3].
	"If user didn't answer, treat it as cancel"
	^ answer min: 3
]

{ #category : #'*Tool-Base' }
SystemNavigation >> methodHierarchyBrowserForClass: aClass selector: sel [
	"Create and schedule a message set browser on all implementors of the 
	currently selected message selector. Do nothing if no message is selected."
	
	| list |
	aClass ifNil: [^ self].
	aClass isTrait ifTrue: [^ self].
	sel ifNil: [^ self].
	list := OrderedCollection new.

	aClass allSuperclasses reverseDo: [:cl |
		(cl includesSelector: sel) ifTrue: [
			list addLast: (cl>>sel)]].
	aClass allSubclassesDo: [:cl | 
		(cl includesSelector: sel) ifTrue: [
			list addLast: (cl>>sel) ]].

	list addLast: (aClass>>sel).
	^ self browseMessageList: list name: 'Inheritance of ' , sel


]

{ #category : #'*Tool-Base' }
SystemNavigation >> openBrowserFor: aLiteral withMethods: aCollection [
	"Create and schedule a message sender browser for aCollection which normally should come from a query based on aLiteral (senders, implementors...). This method is usefull to avoid to call twice allCallsOn: in certain occasion.
	For example, 
		| sys |
		sys := SystemNavigation new.
		sys 
			openBrowserFor: #printOn: 
			withMethods: (sys allCallsOn: #printOn:) asSortedCollection"

	^ self headingAndAutoselectForLiteral: aLiteral do:
		[:label :autoSelect|
		self
			browseMessageList: aCollection
			name: label
			autoSelect: autoSelect
			refreshingBlock: [ :method | method hasSelector: aLiteral ] ]
]

{ #category : #'*Tool-Base' }
SystemNavigation >> tools [

	^ Smalltalk tools
]
