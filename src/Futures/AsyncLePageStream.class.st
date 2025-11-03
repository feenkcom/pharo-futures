"
I wrap a stream of LePages so that views and actions can be added to spotter results for pages.
The actual results displayed will be an instance of {{gtClass:name=AsyncLePageCachedStream}}.

"
Class {
	#name : #AsyncLePageStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #conversion }
AsyncLePageStream >> asAsyncPageStream [
	^ self
]

{ #category : #'api - stream' }
AsyncLePageStream >> cached [
	<return: #TAsyncStream>
	^ AsyncLePageCachedStream forStream: self
]

{ #category : #'api - stream' }
AsyncLePageStream >> pollNext: anAsynchronousContext [
	^ self stream pollNext: anAsynchronousContext
]

{ #category : #accessing }
AsyncLePageStream >> stream [
	^ stream
]

{ #category : #accessing }
AsyncLePageStream >> stream: anObject [
	stream := anObject
]
