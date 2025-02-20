"
I am an abstract superclass for objects that can resolve origins into references. Such objects use the Chain of Responsibility pattern, and when unable to resolve a particular origin, delegate that resolution request to the next resolver in the list.

To add your own origin, implement a method in one of my subclasses, which is annotated with <origin> and returns aFileReference. See my subclasses' ""origin"" procotol for examples. If necessary, you could also create your own subclass and add it to the list with something like this:


```
MyCustomFileSystemResolver class >> initialize [
	SessionManager default registerSystemClassNamed: self name atPriority: 100. ""After FileLocator""
	self startUp: true.
	]
```

```	
MyCustomFileSystemResolver class >> startUp: resuming [
	resuming ifFalse: [ ^ self ].
	FileLocator addResolver: self new
	]
```

### Implementation

next
	The next resolver in the list, or nil

"
Class {
	#name : #FileSystemResolver,
	#superclass : #Object,
	#instVars : [
		'next'
	],
	#category : #'FileSystem-Core-Base-Resolver'
}

{ #category : #accessing }
FileSystemResolver >> addResolver: aResolver [
	next
		ifNil: [next := aResolver]
		ifNotNil: [next addResolver: aResolver]
]

{ #category : #resolving }
FileSystemResolver >> canResolve: aSymbol [
	^ self supportedOrigins includes: aSymbol
]

{ #category : #accessing }
FileSystemResolver >> flushCaches [
	self flushLocalCache.
	next ifNotNil: [next flushCaches]
]

{ #category : #accessing }
FileSystemResolver >> flushLocalCache [
]

{ #category : #accessing }
FileSystemResolver >> next [
	^ next
]

{ #category : #resolving }
FileSystemResolver >> resolve: aSymbol [
	^ (self canResolve: aSymbol)
		ifTrue: [self perform: aSymbol]
		ifFalse: [self unknownOrigin: aSymbol]
]

{ #category : #resolving }
FileSystemResolver >> resolveString: aString [
	| fs |
	fs := FileSystem disk.
	^ FileReference
		fileSystem: fs
		path: (fs pathFromString: aString)
]

{ #category : #resolving }
FileSystemResolver >> supportedOrigins [
	^ (Pragma allNamed: #origin from: self class to: FileSystemResolver) collect: [:each | each methodSelector]
]

{ #category : #resolving }
FileSystemResolver >> unknownOrigin: aSymbol [
	^ next ifNotNil: [next resolve: aSymbol]
]
