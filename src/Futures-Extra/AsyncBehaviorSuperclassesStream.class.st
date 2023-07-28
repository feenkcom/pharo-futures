Class {
	#name : #AsyncBehaviorSuperclassesStream,
	#superclass : #AsyncBehaviorStream,
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorSuperclassesStream >> initializeStream [
	stream := behavior allSuperclasses asAsyncStream
]
