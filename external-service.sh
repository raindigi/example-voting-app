curl -X PUT -d '{"Datacenter": "aero-cluster", "Node": "quote",
   "Address": "http://quotes.rest",
   "Service": {"Service": "quotes", "Port": 80}}'
   http://127.0.0.1:8500/v1/catalog/register