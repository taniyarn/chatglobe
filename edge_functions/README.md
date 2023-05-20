# Supabase Edge Functions Example

This template demonstrates how to run a [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
application via Dart Edge.

## Getting Started

Install the dependencies:

```bash
dart pub get
```

Start the application via Dart Edge CLU & the [`supabase` CLI](https://supabase.com/docs/guides/cli):

```bash
supabase init
edge build supabase_functions --dev
supabase functions serve dart_edge --no-verify-jwt
```

For more information, see the [Dart Edge documentation](https://docs.dartedge.dev).

curl -X POST https://tskdqfuyhranwjcqcvxo.functions.supabase.co/dart_edge \
-H "Authorization: Bearer
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjg0NTg0NzY4LCJzdWIiOiIwNTU4ZjhkYy04YmE2LTQ1OGItOGU2Mi03MDc5NmE3ZjE3NTIiLCJlbWFpbCI6InR0b21vLmJiQGdtYWlsLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnt9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNjg0NTY2OTQ5fV0sInNlc3Npb25faWQiOiI4NDM5Y2UzZi0xMWEzLTRkNTItOTMzMC0wODgwMDA3M2JjMGUifQ.4MeDbrbcMAYNCUJKOVtIumBnNNhIt_r1Jbrl49mGFfE" \
-H "Content-Type: application/json" \
-d '{"language": "japanese","content": "こんちゃず！"}'

curl -X POST https://tskdqfuyhranwjcqcvxo.functions.supabase.co/dart_edge \
-H "Authorization: Bearer
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjg0NTg0NzY4LCJzdWIiOiIwNTU4ZjhkYy04YmE2LTQ1OGItOGU2Mi03MDc5NmE3ZjE3NTIiLCJlbWFpbCI6InR0b21vLmJiQGdtYWlsLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnt9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNjg0NTY2OTQ5fV0sInNlc3Npb25faWQiOiI4NDM5Y2UzZi0xMWEzLTRkNTItOTMzMC0wODgwMDA3M2JjMGUifQ.4MeDbrbcMAYNCUJKOVtIumBnNNhIt_r1Jbrl49mGFfE" \
-d '{"language": "japanese","content": "こんちゃず！"}'
