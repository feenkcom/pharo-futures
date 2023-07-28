Class {
	#name : #AsyncBehaviorSubclassesStream,
	#superclass : #AsyncBehaviorStream,
	#category : #'Futures-Extra'
}

{ #category : #initialization }
AsyncBehaviorSubclassesStream >> initializeStream [
	stream := behavior subclasses asAsyncStream
]
