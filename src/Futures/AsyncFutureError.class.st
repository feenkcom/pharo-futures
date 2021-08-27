Class {
	#name : 'AsyncFutureError',
	#superclass : 'Error',
	#instVars : [
		'exception'
	],
	#category : 'Futures-Utilities'
}

{ #category : 'signalling' }
AsyncFutureError class >> signalForException: anError [

	^ self new
		exception: anError;
		signal
]

{ #category : 'accessing' }
AsyncFutureError >> exception [

	^ exception
]

{ #category : 'accessing' }
AsyncFutureError >> exception: anObject [

	exception := anObject
]
