import http from "node:http";

const port = Number(process.env.PORT || 8080);

function json(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const { method, url } = req;

  if (method === "POST" && url === "/ingestions") {
    return json(res, 202, {
      jobId: "ing-001",
      status: "accepted",
      submittedAt: new Date().toISOString()
    });
  }

  if (method === "POST" && url === "/validations") {
    return json(res, 202, {
      jobId: "val-001",
      status: "accepted",
      submittedAt: new Date().toISOString()
    });
  }

  if (method === "POST" && url === "/reports") {
    return json(res, 202, {
      jobId: "rep-001",
      status: "accepted",
      submittedAt: new Date().toISOString()
    });
  }

  if (method === "GET" && url && url.startsWith("/workflow/")) {
    return json(res, 200, {
      workflowId: url.split("/").pop(),
      step: "validation",
      completedSteps: ["ingestion"],
      nextAction: "Review compliance findings"
    });
  }

  if (method === "GET" && url && url.startsWith("/recommendations/")) {
    return json(res, 200, {
      items: [
        {
          id: "rec-001",
          severity: "high",
          text: "Add missing access URL for dataset distribution.",
          relatedRule: "mdcat-distribution-access-url"
        }
      ]
    });
  }

  return json(res, 404, { code: "not_found", message: "Route not implemented" });
});

server.listen(port, () => {
  console.log(`bff listening on :${port}`);
});
