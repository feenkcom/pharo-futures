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

{ #category : #accessing }
AsyncFutureCancelled >> defaultAction [
	"Do nothing, this is a special error that is injected into the stack of the process being cancelled.
	We do not want to spawn a debugger on this error"
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
