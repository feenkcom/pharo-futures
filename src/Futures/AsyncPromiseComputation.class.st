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
	self
		assert: [ aValue isAsyncPromise not ]
		description: [ 'Must not be a promise: ', aValue printString ]
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

{ #category : #generated }
AsyncPromiseComputation >> value: aValue ifSuccess: aSuccessBlock ifError: anErrorBlock ifPromise: aPromiseBlock [
	self class assertNotPromise: aValue.

	^ [
			| aResultValue |
			aResultValue := computation cull: aValue cull: isSynchronous.
			aResultValue isAsyncPromise
				ifTrue: [ aPromiseBlock value: aResultValue ]
				ifFalse: [ aSuccessBlock value: aResultValue ] ]
		on: Error
		do: [ :anError | anErrorBlock value: anError ]
]
