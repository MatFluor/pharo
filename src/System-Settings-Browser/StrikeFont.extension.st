Extension { #name : #StrikeFont }

{ #category : #'*System-Settings-Browser' }
StrikeFont >> settingStoreOn: aStream [ 
	aStream nextPut: $(.
	aStream nextPutAll: self class name.
	aStream nextPut: Character space.
	aStream nextPutAll: 'familyName: ''', self familyName, ''' pointSize: ', self pointSize asString, ' emphasized: ', self emphasis asString.
	aStream nextPut: $)
]
