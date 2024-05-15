Class {
	#name : #AsyncFutureDetailedTranscriptLogger,
	#superclass : #Object,
	#traits : 'TAsyncFutureLogger',
	#classTraits : 'TAsyncFutureLogger classTrait',
	#instVars : [
		'transcript'
	],
	#category : #'Futures-Executor - Logger'
}

{ #category : #accessing }
AsyncFutureDetailedTranscriptLogger >> initialize [
	super initialize.
	transcript := NonInteractiveTranscript stdout
]

{ #category : #private }
AsyncFutureDetailedTranscriptLogger >> pendingItem: aPendingTask indent: anIndent [
	| aDescription |
	anIndent
		timesRepeat: [ transcript
				space;
				space ].
	aDescription := [ aPendingTask gtCompositionDescription asString ]
			on: Error
			do: [ :anError | anError return: aPendingTask className , ' ' , anError printString ].
	aDescription lines
		do: [ :eachLine | 
			transcript
				nextPutAll: eachLine trimBoth;
				space ].
	transcript newLine
]

{ #category : #private }
AsyncFutureDetailedTranscriptLogger >> pendingItems: someAsyncObjects indent: anIndent [
	someAsyncObjects
		do: [ :eachAsyncObject | 
			self pendingItem: eachAsyncObject indent: anIndent.
			self
				pendingItems: eachAsyncObject gtCompositionChildren
				indent: anIndent + 1 ]
]

{ #category : #logging }
AsyncFutureDetailedTranscriptLogger >> pendingTask: aPendingTask [
	self pendingItems: {aPendingTask} indent: 0
]

{ #category : #accessing }
AsyncFutureDetailedTranscriptLogger >> transcript [
	^ transcript ifNil: [ transcript := NonInteractiveTranscript stdout ]
]

{ #category : #accessing }
AsyncFutureDetailedTranscriptLogger >> transcript: anObject [
	transcript := anObject
]
