Class {
	#name : #AsyncSharedWeakIdentityKeyDictionary,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'dictionary'
	],
	#category : #'Futures-Collections - Dictionary'
}

{ #category : #accessing }
AsyncSharedWeakIdentityKeyDictionary >> at: aKey ifAbsent: aBlock [
	^ monitor critical: [ dictionary at: aKey ifAbsent: aBlock ]
]

{ #category : #accessing }
AsyncSharedWeakIdentityKeyDictionary >> at: aKey ifAbsentPut: aBlock [
	^ monitor critical: [ dictionary at: aKey ifAbsentPut: aBlock ]
]

{ #category : #accessing }
AsyncSharedWeakIdentityKeyDictionary >> at: aKey ifPresent: aPresentBlock ifAbsent: aBlock [
	^ monitor critical: [ dictionary at: aKey ifPresent: aPresentBlock ifAbsent: aBlock ]
]

{ #category : #accessing }
AsyncSharedWeakIdentityKeyDictionary >> at: aKey ifPresent: aPresentBlock ifAbsentPut: aBlock [
	^ monitor critical: [ dictionary at: aKey ifPresent: aPresentBlock ifAbsentPut: aBlock ]
]

{ #category : #accessing }
AsyncSharedWeakIdentityKeyDictionary >> at: key put: anObject [
	^ monitor critical: [ dictionary at: key put: anObject ]
]

{ #category : #initialization }
AsyncSharedWeakIdentityKeyDictionary >> initialize [
	super initialize.

	monitor := Monitor new.
	dictionary := WeakIdentityKeyDictionary new
]

{ #category : #accessing }
AsyncSharedWeakIdentityKeyDictionary >> removeKey: key ifAbsent: aBlock [
	"Remove key (and its associated value) from the receiver. If key is not in 
	the receiver, answer the result of evaluating aBlock. Otherwise, answer 
	the value externally named by key."

	^ monitor critical: [ dictionary removeKey: key ifAbsent: aBlock ]
]
