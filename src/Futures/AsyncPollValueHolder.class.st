Class {
	#name : #AsyncPollValueHolder,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'value',
		'polled'
	],
	#category : #'Futures-Collections - Value'
}

{ #category : #controlling }
AsyncPollValueHolder >> ifSome: aSomeBlock [
	^ monitor critical: [ value ifSome: aSomeBlock ]
]

{ #category : #controlling }
AsyncPollValueHolder >> ifSome: aSomeBlock ifNone: aNoneBlock [
	^ monitor critical: [ value ifSome: aSomeBlock ifNone: aNoneBlock ]
]

{ #category : #initialization }
AsyncPollValueHolder >> initialize [
	super initialize.
	
	monitor := Monitor new.
	value := AsyncOptionalValue none.
	polled := false
]

{ #category : #accessing }
AsyncPollValueHolder >> poll [
	<return: #AsyncOptionalValue>

	^ monitor critical: [
		polled
			ifTrue: [ AsyncOptionalValue none ]
			ifFalse: [
				polled := true.
				value ] ]
]

{ #category : #accessing }
AsyncPollValueHolder >> value [
	<return: #AsyncOptionalValue>

	^ monitor critical: [ value ]
]

{ #category : #accessing }
AsyncPollValueHolder >> value: anObject [
	<return: #Boolean>

	^ monitor critical: [
		value ifSome: [ :aValue |
			aValue == anObject
				ifTrue: [ ^ false ] ].
		value := AsyncOptionalValue some: anObject.
		polled := false.
		true ]
]
