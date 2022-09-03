Class {
	#name : #AsyncStreamBufferStartedLoading,
	#superclass : #Announcement,
	#instVars : [
		'bufferLoadingPromise',
		'initialAmountOfItems'
	],
	#category : #'Futures-Buffer'
}

{ #category : #accessing }
AsyncStreamBufferStartedLoading >> bufferLoadingPromise [

	^ bufferLoadingPromise
]

{ #category : #accessing }
AsyncStreamBufferStartedLoading >> bufferLoadingPromise: anObject [

	bufferLoadingPromise := anObject
]

{ #category : #accessing }
AsyncStreamBufferStartedLoading >> initialAmountOfItems [

	^ initialAmountOfItems
]

{ #category : #accessing }
AsyncStreamBufferStartedLoading >> initialAmountOfItems: aNumber [
	initialAmountOfItems := aNumber
]
