# Premise

What you are most interested in is how the problem is worked through, also you will look at how unit tests are written and how the solution is structured / designed.

The 4 user stories are found in [instruction.md](instruction.md)

No third party libraries may be used.

You need instructions on how to run the solution.

## Focus

- App Architecture
- Maintainability
- Tests

## Considerations
Some airports have no IATA3 code and they have `\N` in the field instead, since the user use this code to lookup airports, there will be no way of getting those airports to show up correctly.