"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestFutures,
	#superclass : #PackageManifest,
	#category : #'Futures-Manifest'
}

{ #category : #accessing }
ManifestFutures class >> mustOnlyDependOn [
	^ {
		'Announcements-Core'.
		'Beacon-Core'.
		'Collections-Abstract'.
		'Collections-Atomic'.
		'Collections-Sequenceable'.
		'Collections-Stack'.
		'Collections-Streams'.
		'Collections-Strings'.
		'Collections-Unordered'.
		'Collections-Weak'.
		'Kernel'.
		'System-Finalization'.
		'Transcript-NonInteractive'
	}
]
