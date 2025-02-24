Class {
	#name : #BaselineOfFuturesTelemetry,
	#superclass : #BaselineOf,
	#category : #BaselineOfFuturesTelemetry
}

{ #category : #'as yet unclassified' }
BaselineOfFuturesTelemetry class >> gtDependencyAnalysisPreloadedBaselines [
	^ super gtDependencyAnalysisPreloadedBaselines
		, {BaselineOfBrick.
				BaselineOfGToolkitPhlow.
				BaselineOfGToolkitVisualizer}
]

{ #category : #'as yet unclassified' }
BaselineOfFuturesTelemetry >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec baseline: 'Futures' with: [
			spec repository: 'github://feenkcom/pharo-futures/src:main' ].
		spec 
			package: 'Futures-Telemetry' with: [ spec requires: #(Futures) ] ].
]
