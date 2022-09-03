"
#Buffer changed event
Is sent by {{gtClass:AsyncStreamBuffer}} when new items were loaded and added to the buffer. The event contains a collection of new items and the index at which those new items were added.
"
Class {
	#name : #AsyncStreamBufferChanged,
	#superclass : #Announcement,
	#instVars : [
		'newItems',
		'index'
	],
	#category : #'Futures-Buffer'
}

{ #category : #accessing }
AsyncStreamBufferChanged >> amountOfLoadedItems [
	^ newItems size
]

{ #category : #accessing }
AsyncStreamBufferChanged >> index [

	^ index
]

{ #category : #accessing }
AsyncStreamBufferChanged >> index: anObject [

	index := anObject
]

{ #category : #accessing }
AsyncStreamBufferChanged >> newItems [

	^ newItems
]

{ #category : #accessing }
AsyncStreamBufferChanged >> newItems: anObject [

	newItems := anObject
]
