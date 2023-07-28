Class {
	#name : #AsyncBehaviorInstanceTraitedMethodsStream,
	#superclass : #AsyncBehaviorStream,
	#category : #'Futures-Extra'
}

{ #category : #initialization }
AsyncBehaviorInstanceTraitedMethodsStream >> initializeStream [
	stream := AsyncSequenceStream forCollection: [ behavior methods ] asAsyncFuture
]
