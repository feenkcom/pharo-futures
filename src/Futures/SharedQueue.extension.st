Extension { #name : #SharedQueue }

{ #category : #'*Futures' }
SharedQueue >> itemArray [
	^ monitor critical: [ items asArray ]
]

{ #category : #'*Futures' }
SharedQueue >> nextAllOrEmpty [
	^ monitor critical: [
		items
			ifEmpty: [ #() ]
			ifNotEmpty: [ :theItems |
				| allItems |
				allItems := theItems asArray.
				theItems removeAll.
				allItems ] ]
]
