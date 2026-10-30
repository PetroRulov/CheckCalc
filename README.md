# CheckCalc

A small **checkout / basket pricing service** built with **Elixir and Phoenix**.
It calculates the total price of a shopping basket and applies product-specific pricing rules
(promotions and bulk discounts). All money calculations use `Decimal` — no floating-point arithmetic for prices.

## Pricing rules

| Code | Product      | Price  | Rule                                                              |
|------|--------------|--------|-------------------------------------------------------------------|
| GR1  | Green tea    | £3.11  | Buy one, get one free (BOGOF)                                     |
| SR1  | Strawberries | £5.00  | Bulk discount: 3 or more → price drops by 10% (£4.50 each)        |
| CF1  | Coffee       | £11.23 | Bulk discount: 3 or more → price drops to 2/3 of the original     |

Rules are data-driven: each product carries its own `bogof`, `discount_bulk` (minimum quantity)
and `discount` (multiplier) settings, so new products and promotions can be added without changing the calculation code.

## Architecture

```
Browser form ──► CalculatorController ──► CheckCalc.Service (GenServer)
                                              │
                                              ▼
                               Task.Supervisor (isolated task per calculation)
                                              │
                                              ▼
                                  CheckCalc.Calculator (pure functions)
                                              │
                                              ▼
                                  CheckCalc.Repo (product catalogue)
```

- `CheckCalc.Calculator` — pure, side-effect-free pricing logic: groups basket lines by product code and applies the rules.
- `CheckCalc.Service` — GenServer entry point; each calculation runs in a supervised task, so a failure does not take down the service.
- `CheckCalc.Repo` — in-memory product catalogue (stand-in for a database).
- `CheckCalc.Struct.Product` — typed product struct with `@type` specs.

## Tech stack

Elixir · Phoenix 1.6 · Decimal · GenServer · Task.Supervisor · ExUnit · StreamData (property-based testing) · ExCoveralls · Credo

## Getting started

Requirements: Erlang/OTP 24+, Elixir 1.12+, Node.js (for assets).

```bash
mix deps.get
cd assets && npm install && cd ..
iex -S mix phx.server
```

Open <http://localhost:4000/new_order> to compose a basket.

## Tests

```bash
mix test                 # unit, controller and property-based tests
mix coveralls.html       # coverage report in cover/excoveralls.html
mix credo                # static code analysis
```

The calculator is covered by **property-based tests** (StreamData generators produce random products and
verify the pricing invariants) and by controller tests for complete basket scenarios.

## Possible next steps

- Persist the catalogue in PostgreSQL via Ecto
- JSON API endpoint for the calculation
- Input validation with Ecto changesets
