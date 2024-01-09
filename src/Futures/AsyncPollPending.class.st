Class {
	#name : #AsyncPollPending,
	#superclass : #AsyncPoll,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Futures-Utilities'
}

{ #category : #cleanup }
AsyncPollPending class >> cleanUp [
	uniqueInstance := nil
]

{ #category : #accessing }
AsyncPollPending class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #'operators-mapping' }
AsyncPollPending >> asStreamPoll [
	^ self
]

{ #category : #testing }
AsyncPollPending >> isPending [
	^ true
]

{ #category : #testing }
AsyncPollPending >> isReady [
	^ false
]

{ #category : #'operators-mapping' }
AsyncPollPending >> map: aBlock [
	"Changes the ready value of this Poll with the value computed."
	<return: #AsyncPoll>
	
	^ self
]

{ #category : #printing }
AsyncPollPending >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Pending poll'
]
