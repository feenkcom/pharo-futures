Class {
	#name : #AsyncCachedStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'buffer',
		'currentIndex',
		'collector'
	],
	#category : #'Futures-Base - Streams'
}
