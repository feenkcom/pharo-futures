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

{ #category : #printing }
AsyncRejectedPromiseState >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Rejected with ';
		print: error
]
