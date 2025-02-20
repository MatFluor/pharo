"
the announcement will be emitted when removing a class or a trait using:  
	=> removeFromSystem
"
Class {
	#name : #ClassRemoved,
	#superclass : #ClassAnnouncement,
	#instVars : [
		'categoryName',
		'classRemoved',
		'ownerPackage'
	],
	#category : #'System-Announcements-System-Classes'
}

{ #category : #'instance creation' }
ClassRemoved class >> class: aClass category: aCategoryName [
	^self new
			classRemoved: aClass;
			categoryName: aCategoryName;
			yourself.
]

{ #category : #testing }
ClassRemoved >> affectsMethod: aMethod [
	^classRemoved == aMethod origin
]

{ #category : #testing }
ClassRemoved >> affectsMethods [
	"methods are removed together with removed class"
	^true
]

{ #category : #testing }
ClassRemoved >> affectsMethodsDefinedInClass: aClass [

	^classRemoved == aClass
]

{ #category : #testing }
ClassRemoved >> affectsMethodsDefinedInPackage: aPackage [

	^ownerPackage == aPackage
]

{ #category : #testing }
ClassRemoved >> affectsMethodsTaggedWith: tagName [
	^classRemoved tagsForMethods includes: tagName
]

{ #category : #accessing }
ClassRemoved >> categoryName [
	
	^ categoryName
]

{ #category : #accessing }
ClassRemoved >> categoryName: anObject [
	
	categoryName := anObject
]

{ #category : #accessing }
ClassRemoved >> classAffected [
	^self classRemoved
]

{ #category : #accessing }
ClassRemoved >> classRemoved [
	
	^ classRemoved
]

{ #category : #accessing }
ClassRemoved >> classRemoved: aClass [
	
	classRemoved := aClass.
	ownerPackage := aClass package
]

{ #category : #accessing }
ClassRemoved >> classTagAffected [
	^ownerPackage toTagName: categoryName
]

{ #category : #accessing }
ClassRemoved >> packageAffected [
	^ownerPackage
]
