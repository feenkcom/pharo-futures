Class {
	#name : #AsyncForkedFutureError,
	#superclass : #Error,
	#instVars : [
		'sourceError'
	],
	#category : #'Futures-Error Handler'
}

{ #category : #accessing }
AsyncForkedFutureError >> description [
	^ sourceError description
]

{ #category : #accessing }
AsyncForkedFutureError >> gtStackFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Stack';
		priority: 10000;
		object: [ sourceError ];
		view: #gtStackFor:
]

{ #category : #accessing }
AsyncForkedFutureError >> sourceError [
	^ sourceError
]

{ #category : #accessing }
AsyncForkedFutureError >> sourceError: anObject [
	sourceError := anObject
]
