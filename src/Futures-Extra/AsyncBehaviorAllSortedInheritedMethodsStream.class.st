Class {
	#name : #AsyncBehaviorAllSortedInheritedMethodsStream,
	#superclass : #AsyncBehaviorMethodStream,
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorAllSortedInheritedMethodsStream >> initializeStreams [
	instanceStream := AsyncBehaviorInstanceSortedInheritedMethodsStream
			forBehavior: behavior.
	classStream := AsyncBehaviorClassTraitedSortedMethodsStream
			forBehavior: behavior
]
