"
#Fold Sink
The fold (or inject) sink applies a function to the first item (or initial value) sent to the sink and then feeds the result of the function back into the function along with the second item recevied by the sink. The process then continues for all items.

##Examples
When injecting the initial value, the fold function is called for the first received item with the initial value as an argument:
{{gtExample:AsyncSinkExamples>>#injectIntoSink}}
When folding without an initial value, the function is called with the first item as an argument together with the second item:
{{gtExample:AsyncSinkExamples>>#foldSink}}
"
Class {
	#name : #AsyncFoldSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'foldBlock',
		'initialValue',
		'accumulator'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #initialization }
AsyncFoldSink class >> fold: aFoldBlock [
	^ self new
		inject: AsyncOptionalValue none
		into: aFoldBlock
]

{ #category : #initialization }
AsyncFoldSink class >> inject: anObject into: aFoldBlock [
	^ self new
		inject: (AsyncOptionalValue some: anObject)
		into: aFoldBlock
]

{ #category : #'api - accessing' }
AsyncFoldSink >> accumulator [
	"Return the current accumulated object, it is changing over time"
	<return: #AsyncOptionalValue>

	^ accumulator
]

{ #category : #'api - sink' }
AsyncFoldSink >> cleanSink [
	"Resets the sink to its original state"
	
	accumulator := initialValue
]

{ #category : #initialization }
AsyncFoldSink >> inject: anAsyncOptionalValue into: aFoldBlock [
	initialValue := anAsyncOptionalValue.
	accumulator := anAsyncOptionalValue.
	foldBlock := aFoldBlock
]

{ #category : #'api - sink' }
AsyncFoldSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	
	accumulator
		ifSome: [ :anAccumulator | accumulator := AsyncOptionalValue some: (foldBlock value: anAccumulator value: anObject) ]
		ifNone: [ accumulator := AsyncOptionalValue some: anObject ]
]

{ #category : #'api - accessing' }
AsyncFoldSink >> value [
	"Return the current accumulated object, it is changing over time.
	Return nil if the accumulator is not yet initialized"
	<return: #Object or: nil>

	^ accumulator
		ifSome: [ :aValue | aValue ]
		ifNone: [ nil ]
]
