Class {
	#name : #AsyncPromiseComputation,
	#superclass : #Object,
	#instVars : [
		'computation',
		'isSynchronous'
	],
	#category : #'Futures-Utilities'
}

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
	^ computation cull: aValue cull: isSynchronous
]
