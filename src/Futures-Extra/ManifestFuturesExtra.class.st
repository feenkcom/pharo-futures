Class {
	#name : #ManifestFuturesExtra,
	#superclass : #PackageManifest,
	#category : #'Futures-Extra-Manifest'
}

{ #category : #accessing }
ManifestFuturesExtra class >> mustNotDependOn [
	^ { 
		'Bloc'.
		'Brick'.
	}
]

{ #category : #accessing }
ManifestFuturesExtra class >> mustOnlyDependOn [
	^ {'Collections-Sequenceable'.
		'GToolkit-Utility-Basic'.
		'Futures'.
		'Iceberg'.
		'Kernel'}
		, (self forPharo12AndNewer: [ {'Kernel-CodeModel'} ] forPharo11: [ {} ])
]
