Class {
	#name : #AsyncStreamSizeHint,
	#superclass : #Object,
	#instVars : [
		'lowerBound',
		'higherBound'
	],
	#classInstVars : [
		'unknown'
	],
	#category : #'Futures-Utilities'
}

{ #category : #cleanup }
AsyncStreamSizeHint class >> cleanUp [
	unknown := nil
]

{ #category : #'instance creation' }
AsyncStreamSizeHint class >> lowerBound: aLowerBound [
	^ self
		lowerBound: aLowerBound
		higherBound: nil
]

{ #category : #'instance creation' }
AsyncStreamSizeHint class >> lowerBound: aLowerBound higherBound: aHigherBound [
	^ self new lowerBound: aLowerBound higherBound: aHigherBound
]

{ #category : #'instance creation' }
AsyncStreamSizeHint class >> unknown [
	^ unknown ifNil: [ unknown := self new ]
]

{ #category : #accessing }
AsyncStreamSizeHint >> approximateAmount [
	^ self hasHigherBound
		ifTrue: [ self higherBound ]
		ifFalse: [ self lowerBound ]
]

{ #category : #testing }
AsyncStreamSizeHint >> hasHigherBound [
	^ higherBound notNil
]

{ #category : #accessing }
AsyncStreamSizeHint >> higherBound [

	^ higherBound
]

{ #category : #initialization }
AsyncStreamSizeHint >> initialize [
	super initialize.
	
	lowerBound := 0.
	higherBound := nil
]

{ #category : #accessing }
AsyncStreamSizeHint >> lowerBound [

	^ lowerBound
]

{ #category : #accessing }
AsyncStreamSizeHint >> lowerBound: aLowerBound higherBound: aHigherBound [
	lowerBound := aLowerBound.
	higherBound := aHigherBound
]
