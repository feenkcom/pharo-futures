Class {
	#name : #AsyncBehaviorAllSortedInheritedMethodsStream,
	#superclass : #AsyncBehaviorMethodStream,
	#category : #'Futures-Extra'
}

{ #category : #examples }
AsyncBehaviorAllSortedInheritedMethodsStream class >> behaviorExample [
	<gtExample>
	| stream methods |
	stream := self new behavior: Behavior.
	methods := stream asyncSimilarCopy toArray wait.
	self assert: methods size = methods asSet size.
	^ stream
]

{ #category : #accessing }
AsyncBehaviorAllSortedInheritedMethodsStream >> behavior: aBehavior [
	behavior := aBehavior.
	self initializeStreams.
	stream := (instanceStream merge: classStream) withoutDuplicates
]

{ #category : #accessing }
AsyncBehaviorAllSortedInheritedMethodsStream >> initializeStreams [
	instanceStream := AsyncBehaviorInstanceSortedInheritedMethodsStream
			forBehavior: behavior.
	classStream := AsyncBehaviorSortedInheritedClassMethodsStream
			forBehavior: behavior
]
