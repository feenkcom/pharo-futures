"
#Forward Stream Future
A {{gtClass:TAsyncFuture}} that completes after the given {{gtClass:TAsyncStream}} has been fully processed into the sink and the {{gtClass:TAsyncSink}} has been flushed and closed.
This future will drive the stream to keep producing items until it is exhausted, sending each item to the sink. It will complete once the stream is exhausted, the sink has received and flushed all items, and the sink is closed.

#Example
{{gtExample:AsyncStreamExamples>>#forward}}
"
Class {
	#name : #AsyncStreamForwardFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'sink',
		'bufferedItem'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncStreamForwardFuture class >> forStream: anAsynStream sink: anAsyncSink [
	^ self new stream: anAsynStream sink: anAsyncSink
]

{ #category : #'api - future' }
AsyncStreamForwardFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>
	| aWeakSink aSink |
	
	aWeakSink := sink
		ifSome: #yourself
		ifNone: [ self error: 'Polled Forward after completion' ].

	aSink := (aWeakSink at: 1)
		"Sink was garbage collected"
		ifNil: [
			bufferedItem := AsyncOptionalValue none.
			sink := AsyncOptionalValue none.
			^ AsyncPoll ready: true ].

	[ 
		"If we've got an item buffered already, we need to write it to the sink before we can do anything else"
		bufferedItem ifSome: [ :anItem |
			(aSink pollReady: anAsynchronousContext)
				ifPending: [ :aPendingPoll | ^ aPendingPoll ].
			bufferedItem := AsyncOptionalValue none.
			aSink startSend: anItem ].
		
		(stream pollNext: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ :anItem | bufferedItem := AsyncOptionalValue some: anItem ]
					ifNone: [
						(aSink pollClose: anAsynchronousContext)
							ifReady: [ :aReadyClosePoll |
								sink := AsyncOptionalValue none.
								^ AsyncPoll ready: true ]
							ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] ]
			ifPending: [ :aPendingPoll |
				aSink pollFlush: anAsynchronousContext.
				^ aPendingPoll ]
	] repeat
]

{ #category : #initialization }
AsyncStreamForwardFuture >> stream: anAsynStream sink: anAsyncSink [
	stream := AsyncFuseStream forStream: anAsynStream.
	sink := AsyncOptionalValue some: anAsyncSink asWeakReference.
	bufferedItem := AsyncOptionalValue none
]
