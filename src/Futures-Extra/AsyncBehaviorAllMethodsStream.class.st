Class {
	#name : #AsyncBehaviorAllMethodsStream,
	#superclass : #AsyncBehaviorMethodStream,
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorAllMethodsStream >> initializeStreams [
	instanceStream := AsyncBehaviorInstanceTraitedMethodsStream
			forBehavior: behavior.
	classStream := AsyncBehaviorClassTraitedMethodsStream forBehavior: behavior
]
