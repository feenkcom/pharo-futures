Class {
	#name : #AsyncImagePackagesStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream'
	],
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncImagePackagesStream class >> stream: aPackagesStream [
	^ self new stream: aPackagesStream
]

{ #category : #'api - queries' }
AsyncImagePackagesStream >> definedBehaviors [
	^ AsyncClassesStream stream: (self map: [ :eachPackage | AsyncPackageClassesStream package: eachPackage ]) flatten
]

{ #category : #'api - queries' }
AsyncImagePackagesStream >> deprecated [
	^ self class stream: (self filter: [ :each | each isDeprecated ])
]

{ #category : #initialization }
AsyncImagePackagesStream >> initialize [
	super initialize.
	
	stream := AsyncSequenceStream forCollection: [ RPackage organizer packages ] asAsyncFuture.
]

{ #category : #'api - stream' }
AsyncImagePackagesStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ stream pollNext: anAsynchronousContext
]

{ #category : #'api - stream' }
AsyncImagePackagesStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]

{ #category : #initialization }
AsyncImagePackagesStream >> stream: aStream [
	stream := aStream
]
