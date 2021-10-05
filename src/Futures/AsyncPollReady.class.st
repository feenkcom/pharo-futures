Class {
	#name : #AsyncPollReady,
	#superclass : #AsyncPoll,
	#instVars : [
		'value'
	],
	#category : 'Futures-Utilities'
}

{ #category : #generated }
AsyncPollReady class >> value: anObject [
	^ self new value: anObject
]

{ #category : #testing }
AsyncPollReady >> isPending [
	^ false
]

{ #category : #testing }
AsyncPollReady >> isReady [
	^ true
]

{ #category : #'operators-mapping' }
AsyncPollReady >> map: aBlock [
	"Changes the ready value of this Poll with the value computed."
	<return: #AsyncPoll>
	
	^ self class value: (aBlock cull: self value)
]

{ #category : #accessing }
AsyncPollReady >> value [
	^ value
]

{ #category : #accessing }
AsyncPollReady >> value: anObject [

	value := anObject
]
