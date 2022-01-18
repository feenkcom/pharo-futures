Class {
	#name : #AsyncAbstractOrderedCollection,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'collection'
	],
	#category : #'Futures-Collections'
}

{ #category : #accessing }
AsyncAbstractOrderedCollection class >> collectionType [
	^ self subclassResponsibility
]

{ #category : #'adding / removing' }
AsyncAbstractOrderedCollection >> add: anObject [
	^ monitor critical: [ self privateAdd: anObject ]
]

{ #category : #converting }
AsyncAbstractOrderedCollection >> asArray [
	^ monitor critical: [ collection asArray ]
]

{ #category : #accessing }
AsyncAbstractOrderedCollection >> at: anIndex [
	^ monitor critical: [ self privateAt: anIndex ]
]

{ #category : #'mutual exclusion' }
AsyncAbstractOrderedCollection >> critical: aBlock [
	^ monitor critical: aBlock
]

{ #category : #enumerating }
AsyncAbstractOrderedCollection >> detect: aBlock ifFound: aFoundBlock ifNone: aNoneBlock [
	^ monitor critical: [
		collection
			detect: aBlock
			ifFound: aFoundBlock
			ifNone: aNoneBlock ]
]

{ #category : #enumerating }
AsyncAbstractOrderedCollection >> detectMin: aBlock [
	^ monitor critical: [
		collection detectMin: aBlock ]
]

{ #category : #enumerating }
AsyncAbstractOrderedCollection >> do: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument."
	| anIndex |
	
	anIndex := 1.
	[
		| eachItem |
		eachItem := monitor critical: [ collection at: anIndex ifAbsent: [ ^ self ] ].
		anIndex := anIndex + 1.
		aBlock value: eachItem.
	] repeat
]

{ #category : #initialization }
AsyncAbstractOrderedCollection >> initialize [
	super initialize.
	
	monitor := Monitor new.
	collection := self class collectionType new
]

{ #category : #'private - adding / removing' }
AsyncAbstractOrderedCollection >> privateAdd: anObject [
	collection add: anObject
]

{ #category : #'private - adding / removing' }
AsyncAbstractOrderedCollection >> privateAt: anIndex [
	^ collection
		at: anIndex
		ifAbsent: [ nil ]
]

{ #category : #'private - adding / removing' }
AsyncAbstractOrderedCollection >> privateRemoveAll [
	collection removeAll
]

{ #category : #'adding / removing' }
AsyncAbstractOrderedCollection >> removeAll [
	monitor critical: [ self privateRemoveAll ]
]

{ #category : #enumerating }
AsyncAbstractOrderedCollection >> select: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument."

	^ self asArray select: aBlock 
]

{ #category : #accessing }
AsyncAbstractOrderedCollection >> size [
	^ monitor critical: [ collection size ]
]

{ #category : #enumerating }
AsyncAbstractOrderedCollection >> sorted: aBlock [
	^ self asArray sorted: aBlock
]
