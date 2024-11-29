Class {
	#name : #AsyncFutureCache,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'value'
	],
	#category : #'Futures-Collections - Value'
}

{ #category : #controlling }
AsyncFutureCache >> ifSome: aSomeBlock ifNone: aNoneBlock [
	^ monitor critical: [
		value
			ifSome: aSomeBlock
			ifNone: aNoneBlock ]
]

{ #category : #controlling }
AsyncFutureCache >> ifSome: aSomeBlock ifNonePut: aNoneBlock [
	^ monitor critical: [
		value
			ifSome: aSomeBlock
			ifNone: [
				| aValue |
				aValue := aNoneBlock value.
				value := AsyncOptionalValue some: aValue.
				aValue ] ]
]

{ #category : #controlling }
AsyncFutureCache >> ifSome: aSomeBlock ifNonePutPoll: aNoneBlock [
	^ monitor critical: [
		value
			ifSome: aSomeBlock
			ifNone: [
				aNoneBlock value
					ifReady: [ :aReadyPoll |
							value := AsyncOptionalValue some: aReadyPoll value.
							aReadyPoll ]
					ifPending: [ :aPendingPoll | aPendingPoll ] ] ]
]

{ #category : #initialization }
AsyncFutureCache >> initialize [
	super initialize.
	
	monitor := Monitor new.
	value := AsyncOptionalValue none
]

{ #category : #controlling }
AsyncFutureCache >> resetCache [
	^ monitor critical: [ value := AsyncOptionalValue none ]
]
