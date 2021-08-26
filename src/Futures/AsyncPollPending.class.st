Class {
	#name : 'AsyncPollPending',
	#superclass : 'AsyncPoll',
	#classInstVars : [
		'uniqueInstance'
	],
	#category : 'Futures-Base'
}

{ #category : 'cleanup' }
AsyncPollPending class >> cleanUp [
	uniqueInstance := nil
]

{ #category : 'accessing' }
AsyncPollPending class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'testing' }
AsyncPollPending >> isPending [
	^ true
]

{ #category : 'testing' }
AsyncPollPending >> isReady [
	^ false
]

{ #category : 'operators-mapping' }
AsyncPollPending >> map: aBlock [
	"Changes the ready value of this Poll with the value computed."
	<return: #AsyncPoll>
	
	^ self
]
