Class {
	#name : #AsyncFutureThreadPool,
	#superclass : #Object,
	#instVars : [
		'workers'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #ui }
AsyncFutureThreadPool >> gtWorkersFor: aView [
	<gtView>
	
	^ aView list
		title: 'Workers';
		priority: 10;
		items: [ workers ]
]

{ #category : #initialization }
AsyncFutureThreadPool >> initialize [
	super initialize.
	
	workers := AsyncSharedOrderedCollection new
]

{ #category : #accessing }
AsyncFutureThreadPool >> workers [
]
