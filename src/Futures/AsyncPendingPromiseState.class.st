Class {
	#name : #AsyncPendingPromiseState,
	#superclass : #AsyncPromiseState,
	#category : #'Futures-Utilities'
}

{ #category : #testing }
AsyncPendingPromiseState >> isPending [
	^ true
]

{ #category : #testing }
AsyncPendingPromiseState >> isPendingIndefinitely [
	^ false
]
