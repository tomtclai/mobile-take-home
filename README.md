# Premise

What you are most interested in is how the problem is worked through, also you will look at how unit tests are written and how the solution is structured / designed.

The 4 user stories are found in [instructions.md](instructions.md)

No third party libraries may be used.

# Building and Running

Requires Xcode 10.2.1

Open `Airport Routes/Airport Routes.xcodeproj`

## Focus

- App Architecture
- Maintainability
- Tests
- A working app
- UI

## Considerations
Some airports codes are in the routes.csv but not in airport.csv.. I was trying to fix it by adding blank airports at run time, but I don't even know what the UI would look like in that case, so I stopped doing that and ignored those routes instead. If it were real life, i'd be talking to the team. and maybe make ticket to fix the backend or wherever the data in the CSV is coming from.

I put in a [coordinator](http://khanlou.com/2015/01/the-coordinator/) so VCs don't know about other VCs. We only have one VC now so this is mostly for demo purpose.

[Tests are collocated](https://kickstarter.engineering/why-you-should-co-locate-your-xcode-tests-c69f79211411), this is a style preference -- I can be convinced otherwise. 

## Future Improvments
Test the dijkstra algorithem more thorouhly

Add unit tests for the viewmodel and viewcontroller, espc the error paths; snapshot tests for views

search controller to show suggestions as I type

a menu on the bottom with all the stops on the route, when I tap on it i want the map to zoom to that airport

Could potentially add a call out on the map pin - https://stackoverflow.com/a/33978778 



## Useful Routes for testing
- LAS PVG (1 stop)
- LAS HGH (2 stops)
- YYY HUX (2 stops)
- YYY SZX (3 stops)
- YYY ZUH (3 stops