---
name: "ci-cd-agent"
description: "Automated GitHub agent that analyzes PR diffs, suggests CI and infra optimizations, and produces actionable cost and performance reports."
author: "Grim"
version: "0.1.0"
capabilities:
  - pr_analysis
  - ci_optimization
  - cost_forecasting
  - auto_comments
  - metrics_tagging
rules:
  auto_apply: false
  require_human_approval_for_merge: true
runbook:
  triggers:
    - pull_request: [opened, synchronize, reopened]
    - push: [branches: main]
  steps:
    - name: fetch_pr_diff
      description: "Fetch git diff between target branch and head"
      action: "git fetch origin && git diff origin/main...HEAD --name-only"
    - name: static_analysis
      description: "Run linters and unit tests. Exit nonzero does not block, only flags."
      action: "bandit -r . || true; black --check . || true; pytest -q || true"
    - name: ai_review
      description: "Send diff to LLM. Receive JSON recommendations."
      action: "python .github/agents/scripts/ai_review.py --input diff.txt --output recommendations.json"
    - name: cost_forecast
      description: "If infra changes detected run Infracost and produce cost delta."
      action: "infracost breakdown --path=. --format=json > infracost.json || true; python .github/agents/scripts/ai_cost_advisor.py infracost.json"
acceptance_criteria:
  - "Comments must include explanation, file, line or hunk reference, and confidence score."
  - "Cost recommendations must include estimated monthly delta and suggested alternative."
  - "Agent must never auto-merge when auto_apply is false. It must create a PR for any code changes."
notes:
  secrets_required:
    - OPENAI_API_KEY
    - INFRACOST_API_KEY
  github_permissions_required:
    - contents: read
    - pull_requests: write
  monitoring:
    - "Log events to actions artifact and to Influx/Grafana if present."
---
# CI/CD Agent: ci-cd-agent

This descriptor file defines capabilities and the runbook for automated reviews and cost analysis. It is advisory by default. To move to automated changes set `rules.auto_apply: true` only after you trust the recommendations for 30+ runs.
