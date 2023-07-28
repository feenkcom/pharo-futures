Class {
	#name : #AsyncBehaviorMethodStream,
	#superclass : #AsyncBehaviorStream,
	#instVars : [
		'instanceStream',
		'classStream'
	],
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorMethodStream >> behavior: aBehavior [
	behavior := aBehavior.
	self initializeStreams.
	stream := {instanceStream.
			classStream} asAsyncStream flatten
]

{ #category : #accessing }
AsyncBehaviorMethodStream >> initializeStreams [
	self subclassResponsibility
]
