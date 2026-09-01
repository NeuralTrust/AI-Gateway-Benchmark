# AI Gateway Benchmark Repository

This repository contains scripts and configuration files to benchmark various AI gateways, supporting the article "AI Gateway Benchmark: Comparing Performance."

## Overview

This benchmark compares the performance, scalability, and security of popular AI and API gateways that can be used for AI applications. The benchmarks measure key metrics including:
- Throughput (requests per second)
- Average latency (milliseconds)

## Gateways Included

The benchmark evaluates the following gateways:
- [TrustGate](https://neuraltrust.ai/ai-gateway) (AI-specific gateway)
- KrakenD
- Tyk
- Kong
- Apache APISIX

## Running the Benchmarks

Each gateway can be benchmarked independently. Make sure Docker is running and stop other gateways before testing a new one.

### Launching TrustGate

1. Clone TrustGate
```bash
cd TrustGate
docker compose up -d redis postgres
./scripts/run_local.sh
```

Open another terminal and run:
```bash
sudo chmod +x ./benchmark_trustgate.sh
./benchmark_trustgate.sh
```

### Launching KrakenD

```bash
docker run -p 8080:8080 -v $PWD:/etc/krakend/ devopsfaith/krakend run --config /gateway/krakend.json
./benchmark_krakend.sh
```

### Launching Tyk

```bash
git clone https://github.com/TykTechnologies/tyk-gateway-docker
cd tyk-gateway-docker
docker-compose up -d
```

Create Proxy Rule
```bash
curl -X POST http://localhost:8080/tyk/apis/ \
  -H "x-tyk-authorization: foo" \
  -H "Content-Type: application/json" \
  -d '{
    "definition": {
      "key": "version",
      "location": "header"
    },
    "name": "Test API",
    "api_id": "test-api",
    "slug": "test",
    "use_keyless": true,
    "proxy": {
      "listen_path": "/test/",
      "target_url": "http://localhost:8080/hello",
      "strip_listen_path": true
    },
    "version_data": {
      "not_versioned": true,
      "versions": {
        "Default": {
          "name": "Default"
        }
      }
    },
    "active": true
  }'

curl -X GET http://localhost:8080/tyk/reload \
  -H "x-tyk-authorization: foo"
```

In another terminal, run:
```bash
./benchmark_tyk.sh
```

### Launching Kong

```bash
curl -Ls https://get.konghq.com/quickstart | bash
```

Configure service 
```bash
curl -i -s -X POST http://localhost:8001/services \
--data name=benchmark \
--data url='http://localhost:8000'
```

Configure route
```bash
curl -i -X POST http://localhost:8001/services/benchmark/routes \
  --data 'paths[]=/mock'
```

Restart Docker Container
```bash
./benchmark_kong.sh
```

### Launching Apache APISIX

```bash
curl -sL https://run.api7.ai/apisix/quickstart | sh
```

Create Proxy Rule
```bash
curl -X PUT http://127.0.0.1:9180/apisix/admin/routes/1 \
     -H "X-API-KEY: $admin_key" \
     -H "Content-Type: application/json" \
     -d '{
       "methods": ["GET"],
       "uri": "/hello",
       "upstream": {
         "type": "roundrobin",
         "nodes": {
           "127.0.0.1:9180": 1
         }
       },
       "plugins": {
         "proxy-rewrite": {
           "uri": "/apisix/admin/routes/"
         }
       }
     }'
```

Run benchmark
```bash
./benchmark_apisix.sh
```

## Benchmark Methodology

The benchmarks use the `hey` HTTP load generator to simulate traffic to each gateway. Each test runs with 50 concurrent users for 30 seconds, measuring throughput and latency.

## Results

For detailed benchmark results and analysis, please refer to the accompanying article: "AI Gateway Benchmark: Comparing Performance."

## Further reading
 
- [The 10 Best AI Gateways for Enterprise AI Security in 2026](https://neuraltrust.ai/blog/best-ai-gateways)
- [vs. Kong](https://neuraltrust.ai/blog/neuraltrust-vs-kong)
- [vs. Apache APISIX](https://neuraltrust.ai/blog/neuraltrust-vs-apache-apisix)

## FAQ
 
**Why isn't LiteLLM/Portkey/Helicone in this benchmark?**
This benchmark focuses on infrastructure-layer gateways with
comparable data-plane architecture (Kong, Tyk, KrakenD, Apache
APISIX). LLM-routing gateways solve a different problem — see our
[comparison articles](https://neuraltrust.ai/blog/best-ai-gateways)
for that category.
 
**Isn't this biased since NeuralTrust builds TrustGate?**
The methodology, environment and scripts are public specifically so
anyone can re-run it and check.
[Open an issue](https://github.com/NeuralTrust/AI-Gateway-Benchmark/issues)
if your numbers differ.
 
**How do I reproduce this on my own hardware?**
See Running the benchmarks — one command, documented test
environment above.


## License
 
[MIT](LICENSE) — NeuralTrust

