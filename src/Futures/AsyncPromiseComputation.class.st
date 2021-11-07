Class {
	#name : #AsyncPromiseComputation,
	#superclass : #Object,
	#instVars : [
		'computation',
		'isSynchronous'
	],
	#category : #'Futures-Utilities'
}

{ #category : #asserting }
AsyncPromiseComputation class >> assertNotPromise: aValue [
	[ self
		assert: [ aValue isAsyncPromise not ]
		description: [ 'Must not be a promise!' ] ] on: Error do: [ :anError |
			Smalltalk logStdOutDuring: [ :logger |
				logger
					nextPutAll: '*** EXCEPTION ***'; cr;
					nextPutAll: anError printString; cr;
					nextPutAll: (String
						streamContents: [ :stream | anError signalerContext errorReportOn: stream ]); cr ] ].
]

{ #category : #accessing }
AsyncPromiseComputation >> computation [

	^ computation
]

{ #category : #accessing }
AsyncPromiseComputation >> computation: anObject [

	computation := anObject
]

{ #category : #initialization }
AsyncPromiseComputation >> initialize [
	super initialize.
	
	computation := [ :aValue :isSynchronousComputation | "default" ].
	isSynchronous := false
]

{ #category : #accessing }
AsyncPromiseComputation >> isSynchronous [

	^ isSynchronous
]

{ #category : #accessing }
AsyncPromiseComputation >> isSynchronous: anObject [

	isSynchronous := anObject
]

{ #category : #generated }
AsyncPromiseComputation >> value: aValue [
	self class assertNotPromise: aValue.

	^ computation cull: aValue cull: isSynchronous
]
