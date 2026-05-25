import http from "node:http";

const port = Number(process.env.PORT || 8081);

function json(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const { method, url } = req;

  if (method === "POST" && url === "/jobs") {
    return json(res, 202, {
      jobId: "val-job-001",
      status: "accepted",
      submittedAt: new Date().toISOString()
    });
  }

  if (method === "GET" && url && /^\/jobs\/[^/]+$/.test(url)) {
    return json(res, 200, {
      jobId: url.split("/").pop(),
      status: "running",
      score: 82,
      counts: { info: 5, warning: 2, error: 1 },
      startedAt: new Date().toISOString(),
      finishedAt: null
    });
  }

  if (method === "GET" && url && /^\/jobs\/[^/]+\/findings/.test(url)) {
    return json(res, 200, {
      items: [
        {
          id: "finding-001",
          code: "MDCAT-001",
          severity: "error",
          message: "Required property is missing.",
          ruleVersion: "mobilitydcat-ap-2.0.0",
          targetPath: "dataset.distribution.accessURL",
          recommendation: "Provide a valid access URL."
        }
      ],
      page: 1,
      pageSize: 50,
      total: 1
    });
  }

  return json(res, 404, { code: "not_found", message: "Route not implemented" });
});

server.listen(port, () => {
  console.log(`validation service listening on :${port}`);
});
