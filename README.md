# Asynchronous Futures & Streams
Abstractions for asynchronous programming in Pharo.

## Futures

Ready:
```smalltalk
42 asFuture wait = 42
```

Computation:
```smalltalk
[ 2 seconds wait . 42 ] asFuture wait = 42 
```

Map:
```smalltalk
([ 2 ] asFuture map: [ :x | x + 40 ]) wait = 42
```

Join all:
```
(AsyncJoinAllFuture futures: { 
   [ 42 ] asFuture.
   3.14 asFuture.
   9 asFuture map: [ :x | x * x ].
}) wait = #(42 3.14 81)
```

## Streams & combinators
Sequence:
```smalltalk
(1 to: 5) asAsyncStream collect wait = #(1 2 3 4 5)
```

Map:
```smalltalk
((1 to: 3) asAsyncStream map: [ :x | x * 2]) collect wait = #(2 4 6)
```

Take:
```smalltalk
((1 to: 10) asAsyncStream take: 3) collect wait = #(1 2 3)
```

Filter:
```smalltalk
((1 to: 6) asAsyncStream filter: [ :x | x even ]) collect wait = #(2 4 6)
```
