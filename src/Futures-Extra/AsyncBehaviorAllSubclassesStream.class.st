Class {
	#name : #AsyncBehaviorAllSubclassesStream,
	#superclass : #AsyncBehaviorStream,
	#category : #'Futures-Extra'
}

{ #category : #comparing }
AsyncBehaviorAllSubclassesStream >> = anObject [ 
	"Answer whether the receiver and the argument represent the same 
	object. If = is redefined in any subclass, consider also redefining the 
	message hash."

	^self == anObject
]

{ #category : #comparing }
AsyncBehaviorAllSubclassesStream >> hash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	May be overridden, and should be overridden in any classes that define = "

	^ self identityHash
]

{ #category : #initialization }
AsyncBehaviorAllSubclassesStream >> initializeStream [
	stream := {AsyncBehaviorSubclassesStream forBehavior: behavior.
			(((AsyncBehaviorSubclassesStream forBehavior: behavior)
				select: [ :eachBehavior | eachBehavior subclasses notEmpty ])
				collect: [ :eachBehavior | AsyncBehaviorAllSubclassesStream forBehavior: eachBehavior ])
				flatten} asAsyncStream flatten
]
