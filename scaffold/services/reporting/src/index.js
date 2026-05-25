import http from "node:http";

const port = Number(process.env.PORT || 8082);

function json(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const { method, url } = req;

  if (method === "POST" && url === "/reports") {
    return json(res, 202, {
      reportId: "rep-2026-q2",
      status: "accepted",
      submittedAt: new Date().toISOString()
    });
  }

  if (method === "GET" && url && /^\/reports\/[^/]+$/.test(url)) {
    return json(res, 200, {
      reportId: url.split("/").pop(),
      status: "running",
      generatedAt: null,
      qualityGate: { passed: false, warnings: 1, errors: 0 }
    });
  }

  if (method === "GET" && url && /^\/reports\/[^/]+\/exports$/.test(url)) {
    const reportId = url.split("/")[2];
    return json(res, 200, {
      reportId,
      exports: [
        {
          format: "json",
          uri: `https://pilot.example.eu/reports/${reportId}.json`,
          sizeBytes: 1024
        }
      ]
    });
  }

  if (method === "GET" && url && /^\/reports\/[^/]+\/workflow$/.test(url)) {
    return json(res, 200, {
      reportId: url.split("/")[2],
      currentStep: "quality-review",
      completedSteps: ["data-collection", "kpi-mapping", "draft-generation"],
      nextAction: "Approve quality warnings"
    });
  }

  return json(res, 404, { code: "not_found", message: "Route not implemented" });
});

server.listen(port, () => {
  console.log(`reporting service listening on :${port}`);
});
