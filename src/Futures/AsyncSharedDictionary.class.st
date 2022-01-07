"
#Shared Dictionary
Is a thread-safe {{gtClass:Dictionary}} that synchronises the api calls with the help of a {{gtClass:Monitor}}.
"
Class {
	#name : #AsyncSharedDictionary,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'dictionary'
	],
	#category : #'Futures-Collections'
}

{ #category : #accessing }
AsyncSharedDictionary >> at: aKey [
	^ monitor critical: [ dictionary at: aKey ]
]

{ #category : #accessing }
AsyncSharedDictionary >> at: aKey ifAbsent: aBlock [
	^ monitor critical: [ dictionary at: aKey ifAbsent: aBlock ]
]

{ #category : #accessing }
AsyncSharedDictionary >> at: aKey ifAbsentPut: aBlock [
	^ monitor critical: [ dictionary at: aKey ifAbsentPut: aBlock ]
]

{ #category : #accessing }
AsyncSharedDictionary >> at: aKey put: anObject [
	^ monitor critical: [ dictionary at: aKey put: anObject ]
]

{ #category : #enumerating }
AsyncSharedDictionary >> do: aBlock [
	monitor critical: [ dictionary do: aBlock ]
]

{ #category : #initialization }
AsyncSharedDictionary >> initialize [
	super initialize.
	
	monitor := Monitor new.
	dictionary := Dictionary new
]

{ #category : #accessing }
AsyncSharedDictionary >> remove: anObject ifAbsent: exceptionBlock [
	^ monitor critical: [ dictionary remove: anObject ifAbsent: exceptionBlock ]
]

{ #category : #accessing }
AsyncSharedDictionary >> removeAll [
	^ monitor critical: [ dictionary removeAll ]
]

{ #category : #enumerating }
AsyncSharedDictionary >> valuesDo: aBlock [
	monitor critical: [ dictionary valuesDo: aBlock ]
]
