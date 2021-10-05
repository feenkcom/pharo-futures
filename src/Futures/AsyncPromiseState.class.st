Class {
	#name : #AsyncPromiseState,
	#superclass : #Object,
	#category : #'Futures-Utilities'
}

{ #category : #testing }
AsyncPromiseState >> isFulfilled [
	^ false
]

{ #category : #testing }
AsyncPromiseState >> isPending [
	^ false
]

{ #category : #testing }
AsyncPromiseState >> isRejected [
	^ false
]
