Class {
	#name : #AsyncStreamBufferStartedLoading,
	#superclass : #Announcement,
	#instVars : [
		'bufferLoadingPromise'
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
