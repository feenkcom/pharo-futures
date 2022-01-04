"
#Shared OrderedCollection
Is a thread-safe {{gtClass:OrderedCollection}} that synchronises the api calls with the help of a {{gtClass:Monitor}}.
"
Class {
	#name : #AsyncSharedOrderedCollection,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'collection'
	],
	#category : #'Futures-Collections'
}

{ #category : #'adding / removing' }
AsyncSharedOrderedCollection >> add: anObject [
	^ monitor critical: [ self privateAdd: anObject ]
]

{ #category : #converting }
AsyncSharedOrderedCollection >> asArray [
	^ monitor critical: [ collection asArray ]
]

{ #category : #accessing }
AsyncSharedOrderedCollection >> at: anIndex [
	^ monitor critical: [ self privateAt: anIndex ]
]

{ #category : #'mutual exclusion' }
AsyncSharedOrderedCollection >> critical: aBlock [
	^ monitor critical: aBlock
]

{ #category : #enumerating }
AsyncSharedOrderedCollection >> do: aBlock [ 
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
AsyncSharedOrderedCollection >> initialize [
	super initialize.
	
	monitor := Monitor new.
	collection := OrderedCollection new
]

{ #category : #'private - adding / removing' }
AsyncSharedOrderedCollection >> privateAdd: anObject [
	collection add: anObject
]

{ #category : #'private - adding / removing' }
AsyncSharedOrderedCollection >> privateAt: anIndex [
	^ collection
		at: anIndex
		ifAbsent: [ nil ]
]

{ #category : #'private - adding / removing' }
AsyncSharedOrderedCollection >> privateRemoveAll [
	collection removeAll
]

{ #category : #'adding / removing' }
AsyncSharedOrderedCollection >> removeAll [
	monitor critical: [ self privateRemoveAll ]
]

{ #category : #accessing }
AsyncSharedOrderedCollection >> size [
	^ monitor critical: [ collection size ]
]
