Class {
	#name : #AsyncPromiseExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #examples }
AsyncPromiseExamples >> promiseResolvingToString [
	<gtExample>
	
	^ [ 1 second wait. 'Promised value' ] asAsyncPromise
]
