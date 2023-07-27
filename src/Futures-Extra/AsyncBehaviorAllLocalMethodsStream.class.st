Class {
	#name : #AsyncBehaviorAllLocalMethodsStream,
	#superclass : #AsyncBehaviorMethodStream,
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorAllLocalMethodsStream >> initializeStreams [
	instanceStream := AsyncBehaviorInstanceLocalSortedMethodsStream
			forBehavior: behavior.
	classStream := AsyncBehaviorClassSortedMethodsStream forBehavior: behavior
]
