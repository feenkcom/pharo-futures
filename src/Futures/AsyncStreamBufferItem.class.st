Class {
	#name : #AsyncStreamBufferItem,
	#superclass : #Object,
	#instVars : [
		'item',
		'index'
	],
	#category : #'Futures-Buffer'
}

{ #category : #accessing }
AsyncStreamBufferItem >> index [

	^ index
]

{ #category : #accessing }
AsyncStreamBufferItem >> index: anObject [

	index := anObject
]

{ #category : #accessing }
AsyncStreamBufferItem >> item [

	^ item
]

{ #category : #accessing }
AsyncStreamBufferItem >> item: anObject [

	item := anObject
]
