Class {
	#name : #AsyncFutureExecutionError,
	#superclass : #Error,
	#instVars : [
		'exception'
	],
	#category : #'Futures-Utilities'
}

{ #category : #signalling }
AsyncFutureExecutionError class >> signalForException: anError [

	^ self new
		exception: anError;
		signal
]

{ #category : #accessing }
AsyncFutureExecutionError >> exception [

	^ exception
]

{ #category : #accessing }
AsyncFutureExecutionError >> exception: anObject [

	exception := anObject
]
