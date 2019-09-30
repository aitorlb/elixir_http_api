# Match

**Contain information about a football match result.**

| Attribute | Description |
| --- | --- |
| AwayTeam | Away Team |
| Date | Match Date (dd/mm/yyyy) |
| Div | League Division |
| FTAG | Full Time Away Team Goals |
| FTHG | Full Time Home Team Goals |
| FTR | Full Time Result (H=Home Win, D=Draw, A=Away Win) |
| HTAG | Half Time Away Team Goals |
| HTHG | Half Time Home Team Goals |
| HTR | Half Time Result (H=Home Win, D=Draw, A=Away Win) |
| HomeTeam | Home Team |
| Season | Start year (4 digits) and end year (2 digits) of season (yyyyyy) |

See [Protobuf schema](../priv/football_results.proto) for the specified field types.

# Match Collection

**List all matches**

Return a JSON-encoded response by default. Return a Protocol Buffers-encoded response if the request header specifies `Accept: application/x-protobuf`.

## URL

`/macthes/`

## Method

`GET`

## URL Params

**Optional:**

`league=[string]&season=[string]` (must be queried together)

`date=[string]`

## Success Response

**Code:** 200

**Content:**
```
{
  "matches": [
    {
      "Season": "201617",
      "HomeTeam": "Sp Gijon",
      "HTR": "A",
      "HTHG": 0,
      "HTAG": 1,
      "FTR": "A",
      "FTHG": 0,
      "FTAG": 1,
      "Div": "SP1",
      "Date": "05/03/2017",
      "AwayTeam": "La Coruna"
    },
    ...
  ]
}
```

## Error Response

**Code:** 400

**Content:** `{ error : "Bad request" }`

## Sample Requests

```
$ curl http://localhost:4000/api/matches

$ curl "http://localhost:4000/api/matches?date=asc"

$ curl "http://localhost:4000/api/matches?date=desc"

$ curl "http://localhost:4000/api/matches?league=SP2&season=201516"

$ curl "http://localhost:4000/api/matches?season=201516&league=SP2"

$ curl "http://localhost:4000/api/matches?season=201516&date=asc&league=SP2"
```

### Protocol Buffers

Same calls as above but using `curl -H "Accept: application/x-protobuf"` instead.

# Match filter Collection

**List all filters for which there are matches available.**

Return a JSON-encoded response.

## URL

`/macth-filters/`

## Method

`GET`

## URL Params

None

## Success Response

**Code:** 200

**Content:**
```
{
  "match_filters": {
    "league_and_season": [
      {
        "season": "201617",
        "league": "SP2"
      },
      ...
    ],
    "date": [
      "asc",
      "desc"
    ]
  }
}
```

## Error Response

**Code:** 400

**Content:** `{ error : "Bad request" }`

## Sample Requests

```
$ curl http://localhost:4000/api/match-filters
```