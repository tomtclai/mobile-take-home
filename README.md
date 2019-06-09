# Premise

What you are most interested in is how the problem is worked through, also you will look at how unit tests are written and how the solution is structured / designed.

The 4 user stories are found in [instruction.md](instruction.md)

No third party libraries may be used.

You need instructions on how to run the solution.

## Focus

- App Architecture
- Maintainability
- Tests
- A working app
- UI

## Considerations
Some airports codes are in the routes.csv but not in airport.csv.. I was trying to fix it by adding blank airports at run time, but I don't even know what the UI would look like in that case, so I stopped doing that. If it were real life, i'd be talking to the team. and maybe make ticket to fix the backend or wherever the data in the CSV is coming from.

I put in a [coordinator](http://khanlou.com/2015/01/the-coordinator/) to show architecture, so VCs don't know about other VCs. We only have one VC now so this is mostly for demo purpose.

[Tests are collocated](https://kickstarter.engineering/why-you-should-co-locate-your-xcode-tests-c69f79211411), this is a style preference -- I can be convinced otherwise. 

## Future Improvments

Add unit tests for the viewmodel and viewcontroller; snapshot tests for views

Could potentially add a call out on the map pin - https://stackoverflow.com/a/33978778 

## Useful Routes for testing
- LAS PVG (1 stop)
- PDX PVG (1 stop)
- PVG NRT (1 Stop)
- SYD NRT (1 stop)