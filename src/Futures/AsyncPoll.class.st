Class {
	#name : #AsyncPoll,
	#superclass : #Object,
	#category : #'Futures-Utilities'
}

{ #category : #accessing }
AsyncPoll class >> indefinitelyPending [
	^ AsyncPollIndefinitelyPending uniqueInstance
]

{ #category : #accessing }
AsyncPoll class >> pending [
	^ AsyncPollPending uniqueInstance
]

{ #category : #accessing }
AsyncPoll class >> ready: anObject [
	^ AsyncPollReady value: anObject
]

{ #category : #'operators-mapping' }
AsyncPoll >> ifPending: aPendingBlock [
	^ self isReady
		ifTrue: [ self ]
		ifFalse: [ aPendingBlock cull: self ]
]

{ #category : #'operators-mapping' }
AsyncPoll >> ifReady: aReadyBlock [
	^ self isReady
		ifTrue: [ aReadyBlock cull: self ]
		ifFalse: [ self ]
]

{ #category : #'operators-mapping' }
AsyncPoll >> ifReady: aReadyBlock ifPending: aPendingBlock [
	^ self isReady
		ifTrue: [ aReadyBlock cull: self ]
		ifFalse: [ aPendingBlock cull: self ]
]

{ #category : #testing }
AsyncPoll >> isPending [
	^ self subclassResponsibility
]

{ #category : #testing }
AsyncPoll >> isReady [
	^ self subclassResponsibility
]

{ #category : #'operators-mapping' }
AsyncPoll >> map: aBlock [
	"Changes the ready value of this Poll with the value computed."
	<return: #AsyncPoll>
	
	^ self subclassResponsibility
]
