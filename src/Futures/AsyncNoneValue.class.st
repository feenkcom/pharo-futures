Class {
	#name : 'AsyncNoneValue',
	#superclass : 'AsyncOptionalValue',
	#classInstVars : [
		'uniqueInstance'
	],
	#category : 'Futures-Utilities'
}

{ #category : 'instance creation' }
AsyncNoneValue class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'comparing' }
AsyncNoneValue >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	^ self class = anObject class
]

{ #category : 'comparing' }
AsyncNoneValue >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ self class hash
]

{ #category : 'controlling' }
AsyncNoneValue >> ifSome: aSomeBlock ifNone: aNoneBlock [
	^ aNoneBlock value
]

{ #category : 'testing' }
AsyncNoneValue >> isNone [
	^ true
]

{ #category : 'testing' }
AsyncNoneValue >> isSome [
	^ false
]

{ #category : 'api - future' }
AsyncNoneValue >> map: aBlock [
	^ self
]
