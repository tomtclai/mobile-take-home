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
Some airports codes are in the routes.csv but not in airport.csv.. I was trying to fix it by adding blank airports, but I don't even know what the UI would look like in that case. So I stopped doing that. If it were real life, i'd be talking to the team. and maybe make ticket to fix the backend or wherever the data in the CSV is coming from.

## Future Improvments

Right now, when search is tapped, the map is zoomed so that the route fits on the display. But there is little to no padding - the line touches the edge of the screen.

I would display the entire route (stops in the middle) on the map

## Useful Routes for testing
- LAS PVG (1 stop)
- PDX PVG (1 stop)
- PVG NRT (1 Stop)
- SYD NRT (1 stop)