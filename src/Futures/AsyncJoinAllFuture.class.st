"
#Join all future
Creates a future which represents a collection of the outputs of the futures given.
The returned future will drive execution for all of its underlying futures, collecting the results into a destination Collection in the same order as they were provided.

##Example
{{gtExample:AsyncFutureExamples>>joinAll}}
"
Class {
	#name : #AsyncJoinAllFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'futures'
	],
	#category : 'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncJoinAllFuture class >> futures: aCollectionOfFutures [
	^ self new futures: aCollectionOfFutures
]

{ #category : #initialization }
AsyncJoinAllFuture >> futures: aCollectionOfFutures [
	futures := aCollectionOfFutures collect: [ :eachFuture | AsyncMaybeDoneFuture future: eachFuture ] as: Array
]

{ #category : #'api - future' }
AsyncJoinAllFuture >> poll: anAsynchronousContext [
	| allDone |
	
	allDone := true.
	futures do: [ :eachFuture | 
		(eachFuture poll: anAsynchronousContext) isPending ifTrue: [ 
			allDone := false ] ].

	^ allDone
		  ifTrue: [ 
			  AsyncPoll ready: (futures
					   collect: [ :eachMaybeDoneFuture | 
					   eachMaybeDoneFuture takeOutput ]
					   as: Array) ]
		  ifFalse: [ AsyncPoll pending ]
]
