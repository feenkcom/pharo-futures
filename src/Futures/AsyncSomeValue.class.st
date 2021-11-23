Class {
	#name : #AsyncSomeValue,
	#superclass : #AsyncOptionalValue,
	#instVars : [
		'value'
	],
	#category : #'Futures-Utilities'
}

{ #category : #'instance creation' }
AsyncSomeValue class >> value: anObject [
	^ self new value: anObject
]

{ #category : #comparing }
AsyncSomeValue >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ value = anObject value
]

{ #category : #'api - stream copy' }
AsyncSomeValue >> asyncSimilarCopy [
	^ self class some: self value asyncSimilarCopy
]

{ #category : #comparing }
AsyncSomeValue >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ self class hash bitXor: value hash
]

{ #category : #controlling }
AsyncSomeValue >> ifSome: aSomeBlock ifNone: aNoneBlock [
	^ aSomeBlock cull: self value
]

{ #category : #testing }
AsyncSomeValue >> isNone [
	^ false
]

{ #category : #testing }
AsyncSomeValue >> isSome [
	^ true
]

{ #category : #'api - future' }
AsyncSomeValue >> map: aBlock [
	^ self class value: (aBlock value: self value)
]

{ #category : #accessing }
AsyncSomeValue >> value [
	^ value
]

{ #category : #accessing }
AsyncSomeValue >> value: anObject [
	value := anObject
]
