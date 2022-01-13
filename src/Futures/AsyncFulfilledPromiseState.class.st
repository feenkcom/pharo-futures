Class {
	#name : #AsyncFulfilledPromiseState,
	#superclass : #AsyncPromiseState,
	#instVars : [
		'value'
	],
	#category : #'Futures-Utilities'
}

{ #category : #testing }
AsyncFulfilledPromiseState >> isFulfilled [
	^ true
]

{ #category : #printing }
AsyncFulfilledPromiseState >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Fulfilled with ';
		print: value
]

{ #category : #accessing }
AsyncFulfilledPromiseState >> value [
	^ value
]

{ #category : #accessing }
AsyncFulfilledPromiseState >> value: anObject [

	value := anObject
]
