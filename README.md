# TAHA ABDELAZIZ
### Senior DevSecOps Engineer
*Platform Engineering · Multi-Cloud Kubernetes · DevSecOps*

Email: [taha.abdalzez26@gmail.com](mailto:taha.abdalzez26@gmail.com) - [LinkedIn](https://linkedin.com/in/taha-abdelaziz/)

Phone: [+20 1068 394 574](tel:+201068394574) - [github](https://github.com/0xtaha)

Location: Cairo, Egypt · Open to EU relocation (visa sponsorship required)

---

## SUMMARY

Senior DevSecOps and platform engineer with nearly 5 years operating production, multi-cloud Kubernetes for compliance-sensitive, multi-client deployments. Owns critical infrastructure end to end — cluster operations, GitLab CI/CD with security gates, Terraform IaC governance, secrets and identity (HashiCorp Vault, IAM, network policies), and full observability. Leads incident response from the front and follows up with systemic fixes: the engineer who walks into a P1, drives the response, and leaves the system measurably better. Bridges development, operations, and security, and mentors engineers along the way.

---

## EXPERIENCE

### Senior DevSecOps & Build Engineer — Luxoft
*June 2026 – Present*

- Own the CI/CD security posture — multi-stage GitLab-style pipelines with SAST, DAST (automated OWASP ZAP, Burp Suite), SCA, and supply-chain gates (image scanning with Trivy/Grype, artefact signing with Cosign, SBOMs via Syft) that block non-compliant changes before merge.
- Operate a scalable, multi-language build system (Bazel, CMake, Maven, Poetry, UV) with hermetic builds, dependency-graph management, and caching to accelerate delivery across teams.
- Operate the Kubernetes / container platform and run GitOps-based deployments — automated rollouts, rollbacks, and release orchestration across environments.
- Own observability and incident response — instrumentation, alerting, and on-call across build/release and platform services, driving issues to root-cause fixes.
- Building an LLM-driven agentic workflow that analyses logs and alerts, investigates incidents by correlating signals across the stack, and attempts automated remediation of recurring issues.
- Automate secure infrastructure provisioning with Terraform (reusable modules with compliance guardrails, remote state, team-wide governance) and Ansible; maintain OS/Docker golden images — non-root, minimal, standardised for security compliance.
- Build secure integrations across Jira, GitHub, and codebeamer for delivery, tracking, and end-to-end traceability.

### Senior Platform Engineer — Orange Cyberdefense
*January 2025 – May 2026*

- Operated and continuously improved a multi-cloud Kubernetes estate (EKS, AKS, GKE, self-managed/on-prem on VMware vSphere) — hundreds of clusters serving single-tenant, per-client deployments under GDPR and strict data-residency requirements — RBAC, network policies, Helm, HPA, pod disruption budgets, and day-2 operations at scale.
- Operated the underlying on-prem infrastructure — VMware vSphere virtualization, VM provisioning and lifecycle — and the network layer beneath the platform (load balancing, DNS, TLS/mTLS, and overlay/CNI networking).
- Ran GitOps through ArgoCD with canary and blue/green rollouts, disruption-aware deployments, and automated rollbacks; extended Kubernetes with custom operators and controllers.
- Embedded SAST, secrets, and policy-as-code scanning into CI/CD (Semgrep, SonarQube, Gitleaks, OPA/Conftest), surfacing vulnerabilities at merge time and blocking insecure changes before production.
- Owned platform security end to end: IAM, secrets in HashiCorp Vault, Kubernetes network policies, and automated compliance scanning across cloud and on-prem.
- Brought Terraform IaC to full coverage on Azure and GCP — module design, remote backends, state management — with zero config drift between dev, staging, and production.
- Built the self-service provisioning flow (secure environment setup, database registration, deployment) that took infrastructure off product teams' critical path — cutting environment setup from 2–3 days to under 10 minutes.
- Designed the HA architecture (active-active, circuit breakers, retries, bulkhead isolation) and validated disaster recovery against committed RPO/RTO targets, reducing production outages 72%.
- Instrumented metrics, logs, and distributed tracing (Prometheus, Grafana, Loki, Tempo, OpenTelemetry, ELK) across 100+ services, giving on-call teams unified production visibility.
- Mentored 5 mid-level engineers and set platform standards across the division.

> **Monitoring Platform Excellence Award** — for the division-wide platform build.

### Software & DevOps Engineer — Orange Cyberdefense
*June 2023 – December 2024*

- Wrote Python and Go backend services for cybersecurity monitoring, serving 100+ enterprise clients.
- Standardised CI/CD pipelines with automated tests and quality gates, cutting deployment failures roughly in half and tightening release cadence from weekly to near-daily.
- Carried on-call across app, platform, and infra layers — triaging ~15–25 P1/P2 incidents a quarter with root-cause analysis and post-incident reviews driven to closure.
- Added health checks, liveness/readiness probes, and graceful shutdown to contain failures and prevent cascading outages.
- Standardised infrastructure with Ansible playbooks and Terraform modules across all environments; built secure integrations into Jira, ServiceNow, codebeamer, and Slack.

> **Change Maker Award** — for rapid delivery of the CyberSecure initiative.

### Junior Software Engineer — Elsewedy Electric
*October 2021 – May 2023*

- Introduced Terraform IaC standards on GCP, making deployments reproducible and eliminating recurring environment inconsistencies.
- Built the platform's first production monitoring from scratch on the ITS project (Elastic Stack, OpenTelemetry) — the full pipeline from ingestion through dashboards and alerting.
- Built and maintained backend and frontend apps for industrial-scale IoT device workflows, keeping CI/CD pipelines running across environments.

---

## SKILLS

- **Kubernetes & Orchestration:** Multi-cloud Kubernetes (EKS, AKS, self-managed/on-prem), RBAC, network policies, Helm, HPA, pod disruption budgets, day-2 operations at scale, custom operators/controllers, Kustomize, GitOps (ArgoCD), canary & blue/green rollouts, automated rollbacks
- **Cloud & Networking:** AWS, Azure, GCP, VMware vSphere — multi-account architecture, virtualization & VM lifecycle, IAM, VPC design, VPN, load balancers, DNS, network protocols (TCP/IP, TLS/mTLS, HTTP/gRPC), cloud & network security best practices
- **CI/CD:** GitLab CI/CD (complex multi-stage pipelines, security gates, caching strategies, artefact management), GitHub Actions
- **Infrastructure as Code:** Terraform / OpenTofu (module design, state management, remote backends, team-wide governance), Ansible
- **Security & DevSecOps:** vulnerability scanning, SAST, DAST (automated OWASP ZAP, Burp Suite), SCA, secrets management (HashiCorp Vault / OpenBao), IAM, policy-as-code (OPA/Conftest), Kubernetes network policies, DevSecOps integration, secure/hardened images, supply-chain security (Trivy, Grype, Cosign, Syft/SBOM), GDPR compliance
- **Observability:** Prometheus, Grafana, Loki, Tempo, OpenTelemetry, ELK — monitoring, alerting, distributed tracing
- **Reliability & Incident Management:** on-call rotations, P1/P2 escalation, root cause analysis, post-incident reviews, high availability & DR (RPO/RTO), event-driven architecture
- **Languages & Scripting:** Python (automation, tooling, backend services), Go, Bash
- **AI & Automation:** LLM-driven agentic workflows (log/alert analysis, automated incident remediation), AI-assisted build/release pipelines, systems integration (Jira, GitHub, codebeamer)

---

## EDUCATION

**B.Sc. Computer Engineering** — Faculty of Engineering, Benha University
*September 2016 – August 2021 · GPA 3.2 / 4.0*

---

## LANGUAGES

English (fluent) · Arabic (native) · Spanish & German (in progress)
