Class {
	#name : #AsyncCounter,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #'Futures-Utilities'
}

{ #category : #arithmetic }
AsyncCounter >> + aNumber [
	value := value + aNumber.
	^ self
]

{ #category : #initialization }
AsyncCounter >> initialize [
	value := 0
]
