"
#Split stream

Splits a stream of items into a stream of collections of items based on a separator block closure.
##Example
{{gtExample:AsyncSplitStreamExamples>>#splitWithSeparatorInTheMiddle}}
"
Class {
	#name : #AsyncSplitStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'separatorCondition',
		'currentGroup'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncSplitStream class >> split: aStream by: aBlock [
	^ self new
		stream: aStream
		separatorCondition: aBlock
]

{ #category : #initialization }
AsyncSplitStream >> initialize [
	super initialize.

	currentGroup := nil
]

{ #category : #'api - stream' }
AsyncSplitStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	[ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			aReadyPoll value
				ifSome: [ :aNextObject | 
					currentGroup ifNil: [ currentGroup := WriteStream on: (Array new: 10) ].

					(separatorCondition value: aNextObject)
						ifTrue: [
							| aGroup |
							aGroup := currentGroup contents.
							currentGroup reset.
							^ AsyncPoll ready: (AsyncOptionalValue some: aGroup) ]
						ifFalse: [ currentGroup nextPut: aNextObject ] ]
				ifNone: [
					^ currentGroup
						ifNil: [ AsyncPoll ready: AsyncOptionalValue none ]
						ifNotNil: [
							| aGroup |
							aGroup := currentGroup contents.
							currentGroup := nil.
							AsyncPoll ready: (AsyncOptionalValue some: aGroup) ] ] ]
		ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] repeat
]

{ #category : #'api - stream copy' }
AsyncSplitStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	currentGroup := nil.
]

{ #category : #initialization }
AsyncSplitStream >> stream: aStream separatorCondition: aBlock [
	stream := aStream.
	separatorCondition := aBlock
]
