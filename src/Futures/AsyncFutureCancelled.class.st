"
Is signalled when a future is canceled
"
Class {
	#name : #AsyncFutureCancelled,
	#superclass : #Object,
	#category : #'Futures-Utilities'
}

{ #category : #handling }
AsyncFutureCancelled >> debug [
]

{ #category : #handling }
AsyncFutureCancelled >> freeze [
	
]

{ #category : #signalling }
AsyncFutureCancelled >> signalContext [
	^ nil
]
