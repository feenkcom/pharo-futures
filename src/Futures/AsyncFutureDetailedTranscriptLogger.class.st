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

{ #category : #private }
AsyncFutureDetailedTranscriptLogger >> compositionChildrenFor: anAsyncObject indent: anIndent [
	^ [ anAsyncObject gtCompositionChildren ]
		on: Error
		do: [ :anError | 
			self
				reportObject: anAsyncObject
				getCompositionChildrenError: anError
				indent: anIndent + 1.
			anError return: #() ]
]

{ #category : #accessing }
AsyncFutureDetailedTranscriptLogger >> initialize [
	super initialize.
	transcript := NonInteractiveTranscript stdout
]

{ #category : #private }
AsyncFutureDetailedTranscriptLogger >> pendingItem: aPendingTask indent: anIndent [
	| aDescription |
	self printIndent: anIndent.
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
				pendingItems: (self compositionChildrenFor: eachAsyncObject indent: anIndent + 1)
				indent: anIndent + 1 ]
]

{ #category : #logging }
AsyncFutureDetailedTranscriptLogger >> pendingTask: aPendingTask [
	self pendingItems: {aPendingTask} indent: 0
]

{ #category : #private }
AsyncFutureDetailedTranscriptLogger >> printIndent: anIndent [
	anIndent
		timesRepeat: [ transcript
				space;
				space ]
]

{ #category : #private }
AsyncFutureDetailedTranscriptLogger >> reportObject: anObject getCompositionChildrenError: anError indent: anIndent [
	self printIndent: anIndent.
	transcript
		nextPutAll: 'ERROR: ';
		print: anObject class;
		nextPutAll: ' does not understand #';
		nextPutAll: #gtCompositionChildren;
		nextPutAll: ': ';
		print: anError
]

{ #category : #accessing }
AsyncFutureDetailedTranscriptLogger >> transcript [
	^ transcript ifNil: [ transcript := NonInteractiveTranscript stdout ]
]

{ #category : #accessing }
AsyncFutureDetailedTranscriptLogger >> transcript: anObject [
	transcript := anObject
]
