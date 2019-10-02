# elixir_http_api

Simple Elixir application that exposes a public HTTP API and serves football results from a CSV.

**Available resources**

| Resource | Action | URI | Filters | Documentation |
| --- | --- | --- | --- |:---:|
| match | List all matches. | /matches | league&season <br>date | [Open](docs/API.md#match-collection) |
| match-filter | List all filters<br>for which there are<br>matches available. | /match-filters |  | [Open](docs/API.md#match-filter-collection) |

**Filters and their data types**

| Filter | Type | Description / Possible values |
| --- | --- | --- |
| season (query) | String /YYYYYY/ | The start year (4 digits) and end year (2 digits) of a season<br>e.g. 201617 or 201516 |
| league (query) | String /[A-Z]+/ | Abbreviated league name<br>e.g. SP1 or SP2 |
| date (query) | String /[A-Z]+/ | [ asc \| desc ] |

## Installation

To build this application locally:

1. Make sure you have installed _Elixir_ and _Erlang_
1. Clone the repository
2. Change directory to the project root
3. Fetch all depencies with `$ mix deps.get`

Now you can:
- Run the app locally with `$ iex -S mix` and then visit [localhost:4000/api](http://localhost:4000/api) from your browser
- Run the test suite with `$ mix test`

## Containerization

To run this application in a containerized environment:

1. Make sure you have installed _Docker_ and _Docker Compose_
2. Build a docker image with `$ docker build -t http_api .`

Now you can:
- Run the release docker image with `$ docker run -p 4000:4000 http_api`
- Run three instances of the application with a HAProxy instance load balancing

  traffic between them with `$ docker-compose up`

Then visit [localhost:4000/api](http://localhost:4000/api) from your browser.
