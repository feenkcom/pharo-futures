"
#Repeating stream
Create a stream which produces the same item repeatedly.
The stream never terminates. Note that you likely want to avoid usage of `collect` or such on the returned stream as it will exhaust available memory as it tries to just fill up all RAM.

##Example
{{gtExample:AsyncStreamExamples>>repeat}}
"
Class {
	#name : #AsyncRepeatStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'item'
	],
	#category : 'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncRepeatStream class >> item: anItem [
	^ self new item: anItem
]

{ #category : #initialization }
AsyncRepeatStream >> item: anObject [

	item := anObject
]

{ #category : #'api - stream' }
AsyncRepeatStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ AsyncPoll ready: (AsyncOptionalValue some: item copy)
]

{ #category : #'api - stream' }
AsyncRepeatStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ AsyncStreamSizeHint lowerBound: SmallInteger maxVal
]
