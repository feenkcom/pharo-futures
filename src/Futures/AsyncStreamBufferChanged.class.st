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
