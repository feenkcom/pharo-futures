Extension { #name : #AtomicQueueItem }

{ #category : #'*Futures' }
AtomicQueueItem >> isZombie [
	<gtPharoPatch: #Pharo>
	"Answer a boolean indicating that the receiver doesn't have a real object.
	This should really check that the object is the queue's dummy, but since the item doesn't know which queue it is part of, use the object class instead."

	^object class = self class
]

{ #category : #'*Futures' }
AtomicQueueItem >> printOn: aStream [
	<gtPharoPatch: #Pharo>
	
	aStream << 'an Item('.
	self isZombie ifTrue: 
		[ aStream << 'Zombie' ]
	ifFalse:
		[ object printOn: aStream ].
	"aStream 
		<< ', '."
	self isCircular ifTrue: 
		[ aStream << ', Circular' ].
	aStream
		"print: self identityHash;"
		<< ')'
]
