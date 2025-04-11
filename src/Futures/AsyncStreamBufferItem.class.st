Class {
	#name : #AsyncStreamBufferItem,
	#superclass : #Object,
	#instVars : [
		'item',
		'index'
	],
	#category : #'Futures-Buffer'
}

{ #category : #'as yet unclassified' }
AsyncStreamBufferItem class >> notFound [
	^ self new
		index: 0;
		item: nil
]

{ #category : #accessing }
AsyncStreamBufferItem >> index [

	^ index
]

{ #category : #accessing }
AsyncStreamBufferItem >> index: anObject [

	index := anObject
]

{ #category : #'as yet unclassified' }
AsyncStreamBufferItem >> isFound [
	^ index > 0
]

{ #category : #'as yet unclassified' }
AsyncStreamBufferItem >> isNotFound [
	^ index isZero
]

{ #category : #accessing }
AsyncStreamBufferItem >> item [

	^ item
]

{ #category : #accessing }
AsyncStreamBufferItem >> item: anObject [

	item := anObject
]
