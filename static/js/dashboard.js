// Shared helpers used across all dashboard pages.

async function apiGet(url) {
  const res = await fetch(url);
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || "Request failed");
  return data;
}

async function apiSend(url, method, body) {
  const res = await fetch(url, {
    method,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body || {}),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || "Request failed");
  return data;
}

function badge(value) {
  if (value === null || value === undefined || value === "") return "";
  return `<span class="badge ${String(value).replace(/\s/g, "")}">${value}</span>`;
}

function themeColor(token, fallback) {
  const value = getComputedStyle(document.body).getPropertyValue(token).trim();
  return value || fallback;
}

// Renders an array-of-objects into a <table> given column definitions:
// columns = [{key:'name', label:'Name', render: fn(optional)}]
function renderTable(containerId, rows, columns, pageSize = 10) {
  const container = document.getElementById(containerId);
  if (!rows || rows.length === 0) {
    container.innerHTML = '<p style="color:var(--muted)">No records found.</p>';
    return;
  }
  let page = 1;
  const totalPages = Math.max(1, Math.ceil(rows.length / pageSize));

  function draw() {
    const start = (page - 1) * pageSize;
    const pageRows = rows.slice(start, start + pageSize);
    let html = "<table><thead><tr>";
    columns.forEach((c) => (html += `<th>${c.label}</th>`));
    html += "</tr></thead><tbody>";
    pageRows.forEach((row) => {
      html += "<tr>";
      columns.forEach((c) => {
        const val = c.render ? c.render(row) : (row[c.key] ?? "");
        html += `<td>${val}</td>`;
      });
      html += "</tr>";
    });
    html += "</tbody></table>";
    html += `<div class="pagination">
      <button class="secondary" ${page === 1 ? "disabled" : ""} onclick="window.__pg_prev_${containerId}()">Prev</button>
      <span style="align-self:center;color:var(--muted);font-size:12px;">Page ${page} / ${totalPages}</span>
      <button class="secondary" ${page === totalPages ? "disabled" : ""} onclick="window.__pg_next_${containerId}()">Next</button>
    </div>`;
    container.innerHTML = html;
  }
  window[`__pg_prev_${containerId}`] = () => { if (page > 1) { page--; draw(); } };
  window[`__pg_next_${containerId}`] = () => { if (page < totalPages) { page++; draw(); } };
  draw();
}

function makeBarChart(ctx, labels, data, label, color = themeColor("--primary", "#3157d5")) {
  if (typeof Chart === "undefined") {
    return renderFallbackChart(ctx, labels, data, label, color);
  }
  return new Chart(ctx, {
    type: "bar",
    data: { labels, datasets: [{ label, data, backgroundColor: color }] },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: themeColor("--text-secondary", "#64748b") }, grid: { color: themeColor("--border", "#e1e8f2") } },
        y: { ticks: { color: themeColor("--text-secondary", "#64748b") }, grid: { color: themeColor("--border", "#e1e8f2") } },
      },
    },
  });
}

function makePieChart(ctx, labels, data, colors) {
  if (typeof Chart === "undefined") {
    return renderFallbackChart(ctx, labels, data, "Distribution", colors[0] || themeColor("--primary", "#3157d5"));
  }
  return new Chart(ctx, {
    type: "doughnut",
    data: { labels, datasets: [{ data, backgroundColor: colors }] },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: "bottom", labels: { color: themeColor("--text-secondary", "#64748b") } } },
    },
  });
}

function makeLineChart(ctx, labels, data, label, color = themeColor("--primary", "#3157d5")) {
  if (typeof Chart === "undefined") {
    return renderFallbackChart(ctx, labels, data, label, color);
  }
  return new Chart(ctx, {
    type: "line",
    data: { labels, datasets: [{ label, data, borderColor: color, backgroundColor: color, tension: 0.3 }] },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: themeColor("--text-secondary", "#64748b") }, grid: { color: themeColor("--border", "#e1e8f2") } },
        y: { ticks: { color: themeColor("--text-secondary", "#64748b") }, grid: { color: themeColor("--border", "#e1e8f2") } },
      },
    },
  });
}

function renderFallbackChart(ctx, labels, data, label, color) {
  const max = Math.max(...data.map(Number), 1);
  const parent = ctx.parentElement;
  parent.innerHTML = `<div class="fallback-chart" aria-label="${escapeHtml(label)} chart">` +
    labels.map((item, index) => {
      const value = Number(data[index]) || 0;
      const width = Math.max(2, (value / max) * 100);
      return `<div class="fallback-row">
        <div class="fallback-label" title="${escapeHtml(item)}">${escapeHtml(item)}</div>
        <div class="fallback-track"><div class="fallback-bar" style="width:${width}%;background:${color}"></div></div>
        <strong class="fallback-value">${value}</strong>
      </div>`;
    }).join("") +
    (labels.length ? "" : '<p class="loading">No chart data available.</p>') +
    "</div>";
  return parent;
}

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>"']/g, (character) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[character]));
}

function showMsg(containerId, text, type = "success") {
  const el = document.getElementById(containerId);
  if (!el) return;
  el.innerHTML = `<div class="msg ${type}">${text}</div>`;
  setTimeout(() => (el.innerHTML = ""), 5000);
}
