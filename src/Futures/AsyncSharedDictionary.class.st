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
	#category : #'Futures-Collections - Dictionary'
}

{ #category : #accessing }
AsyncSharedDictionary >> associations [
	^ monitor critical: [ dictionary associations ]
]

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
AsyncSharedDictionary >> at: aKey ifPresent: aBlock [
	^ monitor critical: [ dictionary at: aKey ifPresent: aBlock ]
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
	
	monitor := Mutex new.
	dictionary := self newDictionary
]

{ #category : #accessing }
AsyncSharedDictionary >> keys [
	^ monitor critical: [ dictionary keys ]
]

{ #category : #enumerating }
AsyncSharedDictionary >> keysAndValuesDo: aBlock [
	"
	Evaluate aBlock for each of the receiver's keys and values. The block must accept two 
	inputs, the first being the key and the second being the value. See keysDo: or valuesDo: 
	if you only need to evaluate one or the other. Also see associationsDo: for a similar 
	selector where the block accepts a single agrument.
	"

	monitor critical: [ dictionary keysAndValuesDo: aBlock ]
]

{ #category : #initialization }
AsyncSharedDictionary >> newDictionary [
	^ Dictionary new
]

{ #category : #accessing }
AsyncSharedDictionary >> remove: anObject ifAbsent: exceptionBlock [
	^ self
		removeKey: anObject
		ifAbsent: exceptionBlock
]

{ #category : #accessing }
AsyncSharedDictionary >> removeAll [
	^ monitor critical: [ dictionary removeAll ]
]

{ #category : #accessing }
AsyncSharedDictionary >> removeKey: anObject ifAbsent: exceptionBlock [
	^ monitor critical: [ dictionary removeKey: anObject ifAbsent: exceptionBlock ]
]

{ #category : #enumerating }
AsyncSharedDictionary >> valuesDo: aBlock [
	monitor critical: [ dictionary valuesDo: aBlock ]
]
