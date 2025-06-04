"
# Manual promise
Is a promise without an explicit computation. It should be fulfilled or rejected manually. 
"
Class {
	#name : #AsyncManualPromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'definingMethod'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'as yet unclassified' }
AsyncManualPromise class >> new [
	^ self basicNew
		initialize;
		definingMethod: thisContext sender blocDefiningMethod;
		yourself
]

{ #category : #accessing }
AsyncManualPromise >> definingMethod [
	^ definingMethod
]

{ #category : #accessing }
AsyncManualPromise >> definingMethod: anObject [
	definingMethod := anObject
]

{ #category : #'private - state' }
AsyncManualPromise >> fulfillWithValue: aValue [
	aValue isAsyncPromise
		ifTrue: [ aValue asyncThen: [ :aPromiseValue | self fulfillWithValue: aPromiseValue ] ]
		ifFalse: [ self fulfillWithTransformedValue: aValue ]
]

{ #category : #'as yet unclassified' }
AsyncManualPromise >> gtDefiningMethodFor: aView [
	<gtView>
	self definingMethod ifNil: [ ^ aView empty ].
	
	^ aView forward
		title: 'Source';
		priority: 1;
		object: [ self definingMethod ];
		view: #gtSourceCodeFor:
]

{ #category : #'private - state' }
AsyncManualPromise >> rejectWithError: anError [
	self rejectWithTransformedError: anError
]
