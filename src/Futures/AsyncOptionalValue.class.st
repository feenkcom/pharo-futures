Class {
	#name : #AsyncOptionalValue,
	#superclass : #Object,
	#category : #'Futures-Utilities'
}

{ #category : #'instance creation' }
AsyncOptionalValue class >> none [
	^ AsyncNoneValue uniqueInstance
]

{ #category : #'instance creation' }
AsyncOptionalValue class >> some: anObject [
	^ AsyncSomeValue value: anObject
]

{ #category : #controlling }
AsyncOptionalValue >> ifNone: aNoneBlock [
	^ self
		ifSome: [ nil ]
		ifNone: aNoneBlock
]

{ #category : #controlling }
AsyncOptionalValue >> ifSome: aSomeBlock [
	^ self
		ifSome: aSomeBlock
		ifNone: [ nil ]
]

{ #category : #controlling }
AsyncOptionalValue >> ifSome: aSomeBlock ifNone: aNoneBlock [
	^ self subclassResponsibility
]

{ #category : #testing }
AsyncOptionalValue >> isNone [
	^ self subclassResponsibility
]

{ #category : #testing }
AsyncOptionalValue >> isSome [
	^ self subclassResponsibility
]

{ #category : #'api - future' }
AsyncOptionalValue >> map: aBlock [
	^ self subclassResponsibility
]
