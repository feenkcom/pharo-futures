Class {
	#name : #AsyncAnnouncementStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'announcer',
		'announcement',
		'announcements',
		'waker'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncAnnouncementStream class >> forAnnouncer: anAnnouncer on: anAnnouncement [
	^ self new registerTo: anAnnouncer on: anAnnouncement
]

{ #category : #printing }
AsyncAnnouncementStream >> gtDisplayOn: aStream [
	self printOn: aStream.
	
	aStream
		nextPutAll: ' on ';
		print: announcement
]

{ #category : #'private - event handling' }
AsyncAnnouncementStream >> onAnnouncement: anAnnouncement [
	announcements lock: [ :theAnnouncements |
		theAnnouncements addLast: anAnnouncement.
		waker wakeUp ]
]

{ #category : #'api - stream' }
AsyncAnnouncementStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	^ announcements lock: [ :theAnnouncements |
		theAnnouncements
			ifEmpty: [
				waker register: anAsynchronousContext waker.
				AsyncPoll pending ]
			ifNotEmpty: [
				AsyncPoll ready: (AsyncOptionalValue some: theAnnouncements removeFirst) ] ]
]

{ #category : #'api - stream copy' }
AsyncAnnouncementStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self registerTo: announcer on: announcement
]

{ #category : #initialization }
AsyncAnnouncementStream >> registerTo: anAnnouncer on: anAnnouncement [
	announcements := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new.

	announcer := anAnnouncer.
	announcement := anAnnouncement.
	
	anAnnouncer weak
		when: anAnnouncement
		send: #onAnnouncement:
		to: self
]
