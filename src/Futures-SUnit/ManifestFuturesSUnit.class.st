"
I add support for executing examples in {{gtClass:TestExecutionEnvironment}}. 
"
Class {
	#name : #ManifestFuturesSUnit,
	#superclass : #PackageManifest,
	#category : #'Futures-SUnit-Manifest'
}

{ #category : #accessing }
ManifestFuturesSUnit class >> mustOnlyDependOn [
	^ {
		'Futures'.
		'Kernel'.
		'SUnit-Core'.
	}
]
