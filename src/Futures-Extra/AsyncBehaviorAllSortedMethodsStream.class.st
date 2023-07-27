Class {
	#name : #AsyncBehaviorAllSortedMethodsStream,
	#superclass : #AsyncBehaviorMethodStream,
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorAllSortedMethodsStream >> initializeStreams [
	instanceStream := AsyncBehaviorInstanceTraitedSortedMethodsStream
			forBehavior: behavior.
	classStream := AsyncBehaviorClassTraitedSortedMethodsStream
			forBehavior: behavior
]
