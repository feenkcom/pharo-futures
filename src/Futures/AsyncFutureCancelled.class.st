"
Is signalled when a future is canceled
"
Class {
	#name : #AsyncFutureCancelled,
	#superclass : #Error,
	#instVars : [
		'isSignalled'
	],
	#category : #'Futures-Utilities'
}

{ #category : #handling }
AsyncFutureCancelled >> debug [
	isSignalled
		ifTrue: [ super debug ]
]

{ #category : #handling }
AsyncFutureCancelled >> freeze [
	isSignalled
		ifTrue: [ super freeze ]
]

{ #category : #initialization }
AsyncFutureCancelled >> initialize [
	super initialize.
	
	isSignalled := false
]

{ #category : #signalling }
AsyncFutureCancelled >> signal [
	isSignalled := true.
	^ super signal
]
