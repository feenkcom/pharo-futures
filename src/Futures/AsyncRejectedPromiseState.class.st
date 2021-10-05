Class {
	#name : #AsyncRejectedPromiseState,
	#superclass : #AsyncPromiseState,
	#instVars : [
		'error'
	],
	#category : #'Futures-Utilities'
}

{ #category : #accessing }
AsyncRejectedPromiseState >> error [
	^ error
]

{ #category : #accessing }
AsyncRejectedPromiseState >> error: anError [
	error := anError
]

{ #category : #testing }
AsyncRejectedPromiseState >> isRejected [
	^ true
]
