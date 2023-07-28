Class {
	#name : #AsyncBehaviorSuperclassesStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'behavior'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorSuperclassesStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #accessing }
AsyncBehaviorSuperclassesStream >> behavior: aBehavior [
	behavior := aBehavior.
	stream := aBehavior allSuperclasses  asAsyncStream
]
