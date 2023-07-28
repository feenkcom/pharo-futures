Class {
	#name : #AsyncBehaviorAllSubclassesStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'behavior'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorAllSubclassesStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #initialization }
AsyncBehaviorAllSubclassesStream >> behavior: aBehavior [
	behavior := aBehavior.
	stream := { AsyncBehaviorSubclassesStream forBehavior: behavior .
		(((AsyncBehaviorSubclassesStream forBehavior: behavior)
		select: [ :eachBehavior | eachBehavior subclasses notEmpty ])
		collect: [ :eachBehavior | AsyncBehaviorAllSubclassesStream forBehavior: eachBehavior ]) flatten } asAsyncStream flatten
]

{ #category : #'api - stream copy' }
AsyncBehaviorAllSubclassesStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self behavior: behavior
]
