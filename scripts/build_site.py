#!/usr/bin/env python3
"""
Compila a especificação profile.md para HTML estático em site/index.html
e sincroniza os arquivos brutos profile.md e kollontai.md em site/.
"""

import os
import shutil
import markdown

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_MD = os.path.join(ROOT, "profile.md")
SITE_DIR = os.path.join(ROOT, "site")
OUT_HTML = os.path.join(SITE_DIR, "index.html")

os.makedirs(SITE_DIR, exist_ok=True)

# 1. Sincronizar arquivos raw para acesso via CLI / curl
shutil.copy2(SRC_MD, os.path.join(SITE_DIR, "profile.md"))
shutil.copy2(SRC_MD, os.path.join(SITE_DIR, "kollontai.md"))

with open(SRC_MD, "r", encoding="utf-8") as f:
    md_content = f.read()

# Configuração do compilador Markdown
md = markdown.Markdown(extensions=[
    "extra",
    "tables",
    "fenced_code",
    "toc",
    "nl2br",
    "sane_lists"
])

html_body = md.convert(md_content)

html_template = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Perfil de Implementação Kollontai — GOST</title>
  <meta name="description" content="Especificação canônica de infraestrutura, CI/CD, testes e ferramentas do perfil Kollontai para o padrão GOST.">

  <!-- OpenGraph & Twitter Cards -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="Perfil de Implementação Kollontai — GOST">
  <meta property="og:description" content="Especificação canônica de infraestrutura, CI/CD, testes e ferramentas do perfil Kollontai para o padrão GOST.">
  <meta property="og:url" content="https://kollontai.2lp.in">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Perfil de Implementação Kollontai — GOST">
  <meta name="twitter:description" content="Especificação canônica de infraestrutura, CI/CD, testes e ferramentas do perfil Kollontai para o padrão GOST.">

  <style>
    :root {{
      --bg: #0d1117;
      --card-bg: #161b22;
      --border: #30363d;
      --text: #c9d1d9;
      --text-muted: #8b949e;
      --accent: #ff79c6;
      --accent-hover: #ff92d0;
      --link: #58a6ff;
      --code-bg: #1f242c;
      --font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
      --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    }}

    @media (prefers-color-scheme: light) {{
      :root {{
        --bg: #f6f8fa;
        --card-bg: #ffffff;
        --border: #d0d7de;
        --text: #24292f;
        --text-muted: #57606a;
        --accent: #d03080;
        --accent-hover: #e04090;
        --link: #0969da;
        --code-bg: #eaeef2;
      }}
    }}

    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: var(--font-sans);
      background-color: var(--bg);
      color: var(--text);
      line-height: 1.6;
      padding: 2rem 1rem;
    }}

    .container {{
      max-width: 900px;
      margin: 0 auto;
    }}

    header {{
      margin-bottom: 2.5rem;
      border-bottom: 1px solid var(--border);
      padding-bottom: 1.5rem;
    }}

    h1 {{
      font-size: 2.1rem;
      margin-bottom: 0.5rem;
      color: var(--accent);
    }}

    .subtitle {{
      color: var(--text-muted);
      font-size: 1.05rem;
      margin-bottom: 1.25rem;
    }}

    .badges {{
      display: flex;
      flex-wrap: wrap;
      gap: 0.6rem;
      margin-bottom: 1.25rem;
    }}

    .badge {{
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      padding: 0.3rem 0.65rem;
      border-radius: 6px;
      font-size: 0.85rem;
      font-family: var(--font-mono);
      color: var(--text);
      text-decoration: none;
    }}

    .badge-accent {{
      border-color: var(--accent);
      color: var(--accent);
      font-weight: 600;
    }}

    .quick-links {{
      display: flex;
      flex-wrap: wrap;
      gap: 0.75rem;
      margin-top: 1rem;
    }}

    .btn {{
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      color: var(--text);
      padding: 0.5rem 1rem;
      border-radius: 6px;
      text-decoration: none;
      font-size: 0.9rem;
      font-weight: 500;
      transition: all 0.15s ease;
    }}

    .btn:hover {{
      border-color: var(--accent);
      color: var(--accent);
      transform: translateY(-1px);
    }}

    .raw-box {{
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1rem 1.25rem;
      margin: 1.5rem 0;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }}

    .raw-box-title {{
      font-size: 0.85rem;
      color: var(--text-muted);
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }}

    .raw-url {{
      font-family: var(--font-mono);
      font-size: 0.95rem;
      color: var(--accent);
      word-break: break-all;
    }}

    article h1 {{ display: none; }} /* Já no header */
    article h2 {{
      font-size: 1.5rem;
      margin-top: 2.5rem;
      margin-bottom: 1rem;
      padding-bottom: 0.4rem;
      border-bottom: 1px solid var(--border);
      color: var(--text);
    }}

    article h3 {{
      font-size: 1.2rem;
      margin-top: 1.75rem;
      margin-bottom: 0.75rem;
      color: var(--text);
    }}

    article h4 {{
      font-size: 1.05rem;
      margin-top: 1.25rem;
      margin-bottom: 0.5rem;
      color: var(--text);
    }}

    article p, article ul, article ol {{
      margin-bottom: 1rem;
    }}

    article ul, article ol {{
      padding-left: 1.5rem;
    }}

    article li {{
      margin-bottom: 0.35rem;
    }}

    article a {{
      color: var(--link);
      text-decoration: none;
    }}

    article a:hover {{
      text-decoration: underline;
    }}

    article hr {{
      border: none;
      border-top: 1px solid var(--border);
      margin: 2rem 0;
    }}

    article code {{
      font-family: var(--font-mono);
      font-size: 0.9em;
      background: var(--code-bg);
      padding: 0.2rem 0.4rem;
      border-radius: 4px;
      border: 1px solid var(--border);
    }}

    article pre {{
      background: var(--code-bg);
      border: 1px solid var(--border);
      padding: 1rem;
      border-radius: 6px;
      overflow-x: auto;
      margin-bottom: 1.25rem;
      font-size: 0.9rem;
      line-height: 1.5;
    }}

    article pre code {{
      background: none;
      padding: 0;
      border: none;
      border-radius: 0;
      font-size: inherit;
    }}

    article table {{
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 1.5rem;
      font-size: 0.92rem;
    }}

    article th, article td {{
      border: 1px solid var(--border);
      padding: 0.6rem 0.85rem;
      text-align: left;
    }}

    article th {{
      background: var(--card-bg);
      font-weight: 600;
    }}

    article blockquote {{
      border-left: 4px solid var(--accent);
      padding: 0.5rem 1rem;
      color: var(--text-muted);
      margin-bottom: 1rem;
      background: var(--card-bg);
      border-radius: 0 4px 4px 0;
    }}

    .site-footer {{
      border-top: 1px solid var(--border);
      padding: 2.5rem 1rem;
      margin-top: 4rem;
      text-align: center;
      font-size: 0.88rem;
      line-height: 1.6;
    }}

    .footer-canonical {{
      display: flex;
      flex-direction: column;
      gap: 0.45rem;
      align-items: center;
      justify-content: center;
    }}

    .footer-line-identity {{
      font-weight: 500;
    }}

    .footer-line-metadata {{
      color: var(--text-muted);
      font-size: 0.82rem;
    }}

    .site-footer a {{
      color: var(--accent);
      text-decoration: none;
    }}

    .site-footer a:hover {{
      text-decoration: underline;
    }}
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>Perfil de Implementação: Kollontai</h1>
      <p class="subtitle">Especificação canônica de infraestrutura, engenharia e ferramentas para repositórios GOST.</p>
      
      <div class="badges">
        <span class="badge badge-accent">Perfil: kollontai</span>
        <span class="badge">Norma Base: GOST v1.3.0</span>
        <span class="badge">Status: Ativo / Produção</span>
        <a class="badge" href="https://gost.2lp.in" target="_blank" rel="noopener">Norma Central: gost.2lp.in ↗</a>
      </div>

      <div class="raw-box">
        <div class="raw-box-title">URL Canônica do Perfil (Agnóstica de Forja Git)</div>
        <div class="raw-url">https://kollontai.2lp.in/profile.md</div>
      </div>

      <div class="quick-links">
        <a class="btn" href="profile.md" download>📥 Baixar profile.md</a>
        <a class="btn" href="kollontai.md">📄 Ver kollontai.md (Raw)</a>
        <a class="btn" href="https://codeberg.org/lumenpink/gost-profile-kollontai" target="_blank" rel="noopener">🦊 Forja (Codeberg)</a>
        <a class="btn" href="https://gost.2lp.in" target="_blank" rel="noopener">📜 Norma GOST</a>
      </div>
    </header>

    <article>
{html_body}
    </article>

    <footer class="site-footer">
      <div class="footer-canonical">
        <div class="footer-line footer-line-identity">
          Orgulhosamente produzido por uma <a href="https://travesti.2lp.in/pt/" target="_blank" rel="noopener">travesti latina</a> 🏳️‍⚧️ :)
        </div>
        <div class="footer-line footer-line-metadata">
          Perfil de Implementação Kollontai • GOST v1.3.0 • por <a href="https://lumen.pink" target="_blank" rel="noopener">Lumen Pink</a> • Brasil 🇧🇷 • <a href="LICENSE" target="_blank" rel="noopener">CC-BY-SA-4.0</a>
        </div>
      </div>
    </footer>
  </div>
</body>
</html>
"""

with open(OUT_HTML, "w", encoding="utf-8") as f:
    f.write(html_template)

print(f"✅ Site construído com sucesso em: {OUT_HTML}")
print(f"✅ profile.md e kollontai.md sincronizados em: {SITE_DIR}")
