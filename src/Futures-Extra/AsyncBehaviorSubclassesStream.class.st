Class {
	#name : #AsyncBehaviorSubclassesStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'behavior'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorSubclassesStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #initialization }
AsyncBehaviorSubclassesStream >> behavior: aBehavior [
	behavior := aBehavior.
	stream := aBehavior subclasses asAsyncStream
]

{ #category : #'api - stream copy' }
AsyncBehaviorSubclassesStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self behavior: behavior
]
