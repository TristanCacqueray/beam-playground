-- Instructions:
--
-- 1. Make sure to delete the `persist` folder before starting the test
-- 2. Start the system in prod environment: MIX_ENV=prod iex -S mix
-- 3. In a separate shell, invoke wrk
--    The command I've used: wrk -t4 -c20 -d30s --latency -s wrk.lua http://localhost:5454

counter = 0

request = function()
  pr = math.random(1000)
  if math.random(5) < 5 then
    wrk.method = "GET"
    path = "/events?pr="..pr
  else
    wrk.method = "POST"
    path = "/add_event?pr="..pr.."&comment=hello"
  end
  return wrk.format(nil, path)
end
