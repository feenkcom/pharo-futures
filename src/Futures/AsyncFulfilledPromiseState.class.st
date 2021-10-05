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

{ #category : #accessing }
AsyncFulfilledPromiseState >> value [
	^ value
]

{ #category : #accessing }
AsyncFulfilledPromiseState >> value: anObject [

	value := anObject
]
