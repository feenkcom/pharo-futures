Class {
	#name : #AsyncFutureTranscriptLogger,
	#superclass : #Object,
	#traits : 'TAsyncFutureLogger',
	#classTraits : 'TAsyncFutureLogger classTrait',
	#instVars : [
		'transcript'
	],
	#category : #'Futures-Executor - Logger'
}

{ #category : #accessing }
AsyncFutureTranscriptLogger >> initialize [
	super initialize.
	transcript := NonInteractiveTranscript stdout
]

{ #category : #logging }
AsyncFutureTranscriptLogger >> pendingTask: aPendingTask [
	transcript
		nextPutAll: aPendingTask printString;
		cr
]

{ #category : #accessing }
AsyncFutureTranscriptLogger >> transcript [
	^ transcript ifNil: [ transcript := NonInteractiveTranscript stdout ]
]

{ #category : #accessing }
AsyncFutureTranscriptLogger >> transcript: anObject [
	transcript := anObject
]
