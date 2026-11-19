// As telas do Repooor recriadas em HTML (Material, tema de lib/core/theme), com os textos do app e
// os dados fictícios do seed das telas do README (test/readme). Cada cena tem um roteiro: o dedo
// toca e a tela responde como no app. Tudo em pontos do iPhone (402 x 874).
(() => {
  const IOS = "cubic-bezier(.32,.72,0,1)";
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const h = (markup) => {
    const t = document.createElement("template");
    t.innerHTML = markup.trim();
    return t.content.firstElementChild;
  };
  const brl = (v) => `R$ ${v.toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  const TOP = 54;

  // Ícones do Material (mesmos do app).
  const P = {
    home: "M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z",
    search: "M15.5 14h-.79l-.28-.27A6.471 6.471 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    settings: "M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58a.49.49 0 0 0 .12-.61l-1.92-3.32a.488.488 0 0 0-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54a.484.484 0 0 0-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58a.49.49 0 0 0-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z",
    pantry: "M20 2H4c-1 0-2 .9-2 2v3.01c0 .72.43 1.34 1 1.69V20c0 1.1 1.1 2 2 2h14c.9 0 2-.9 2-2V8.7c.57-.35 1-.97 1-1.69V4c0-1.1-1-2-2-2zm-5 12H9v-2h6v2zm5-7H4V4l16-.02V7z",
    cart: "M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49A1.003 1.003 0 0 0 20 4H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z",
    chart: "M5 9.2h3V19H5zM10.6 5h2.8v14h-2.8zm5.6 8H19v6h-2.8z",
    qr: "M9.5 6.5v3h-3v-3h3M11 5H5v6h6V5zm-1.5 9.5v3h-3v-3h3M11 13H5v6h6v-6zm6.5-6.5v3h-3v-3h3M19 5h-6v6h6V5zm-6 8h1.5v1.5H13V13zm1.5 1.5H16V16h-1.5v-1.5zM16 13h1.5v1.5H16V13zm-3 3h1.5v1.5H13V16zm1.5 1.5H16V19h-1.5v-1.5zM16 16h1.5v1.5H16V16zm1.5-1.5H19V16h-1.5v-1.5zm0 3H19V19h-1.5v-1.5zM22 7h-2V4h-3V2h5v5zm0 15v-5h-2v3h-3v2h5zM2 22h5v-2H4v-3H2v5zM2 2v5h2V4h3V2H2z",
    chevron: "M10 6 8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z",
    plusC: "M13 7h-2v4H7v2h4v4h2v-4h4v-2h-4V7zm-1-5C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z",
    minusC: "M7 11v2h10v-2H7zm5-9C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z",
    trash: "M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM8 9h8v10H8V9zm7.5-5-1-1h-5l-1 1H5v2h14V4z",
    back: "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z",
    close: "M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z",
    add: "M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z",
    check: "M9 16.17 4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z",
    checkC: "M16.59 7.58 10 14.17l-3.59-3.58L5 12l5 5 8-8zM12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8z",
    flat: "M22 12l-4-4v3H3v2h15v3z",
    money: "M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z",
    fire: "M13.5.67s.74 2.65.74 4.8c0 2.06-1.35 3.73-3.41 3.73-2.07 0-3.63-1.67-3.63-3.73l.03-.36C5.21 7.51 4 10.62 4 14c0 4.42 3.58 8 8 8s8-3.58 8-8C20 8.61 17.41 3.8 13.5.67zM11.71 19c-1.78 0-3.22-1.4-3.22-3.14 0-1.62 1.05-2.76 2.81-3.12 1.77-.36 3.6-1.21 4.62-2.58.39 1.29.59 2.65.59 4.04 0 2.65-2.15 4.8-4.8 4.8z",
    basket: "M17.21 9l-4.38-6.56a.993.993 0 0 0-.83-.42c-.32 0-.64.14-.83.43L6.79 9H2c-.55 0-1 .45-1 1 0 .09.01.18.04.27l2.54 9.27c.23.84 1 1.46 1.92 1.46h13c.92 0 1.69-.62 1.93-1.46l2.54-9.27L23 10c0-.55-.45-1-1-1h-4.79zM9 9l3-4.4L15 9H9zm3 8c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z",
    receipt: "M18 17H6v-2h12v2zm0-4H6v-2h12v2zm0-4H6V7h12v2zM3 22l1.5-1.5L6 22l1.5-1.5L9 22l1.5-1.5L12 22l1.5-1.5L15 22l1.5-1.5L18 22l1.5-1.5L21 22V2l-1.5 1.5L18 2l-1.5 1.5L15 2l-1.5 1.5L12 2l-1.5 1.5L9 2 7.5 3.5 6 2 4.5 3.5 3 2v20z",
    help: "M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z",
    compare: "M9.01 14H2v2h7.01v3L13 15l-3.99-4v3zm5.98-1v-3H22V8h-7.01V5L11 9l3.99 4z",
    // categorias
    coffee: "M18.5 3H6c-1.1 0-2 .9-2 2v5.71c0 3.83 2.95 7.18 6.78 7.29 3.96.12 7.22-3.06 7.22-7v-1h.5c1.93 0 3.5-1.57 3.5-3.5S20.43 3 18.5 3zM16 5v3H6V5h10zm2.5 3H18V5h.5c.83 0 1.5.67 1.5 1.5S19.33 8 18.5 8zM4 19h16v2H4z",
    meat: "M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z",
    fruit: "M12 7.5c-1.2-1.1-2.7-1.6-4.3-1.3C4.6 6.8 3 9.8 3.6 13.4 4.3 17.5 7 21 9.6 21c.9 0 1.5-.5 2.4-.5s1.5.5 2.4.5c2.6 0 5.3-3.5 6-7.6.6-3.6-1-6.6-4.1-7.2-1.6-.3-3.1.2-4.3 1.3zM12 6.5c.2-2 1.4-3.6 3.6-4-.1 2-1.5 3.7-3.6 4z",
    grain: "M12 22c-.5 0-1-.4-1-1v-6.3C8.1 14.2 6 11.6 6 8.5V5l2 1c1.7.8 3 2.3 3.6 4.1h.8C13 8.3 14.3 6.8 16 6l2-1v3.5c0 3.1-2.1 5.7-5 6.2V21c0 .6-.5 1-1 1z",
    soap: "M12 2.5c-3.6 4.3-6 7.7-6 11a6 6 0 0 0 12 0c0-3.3-2.4-6.7-6-11zm0 16a4.5 4.5 0 0 1-4.5-4.5h1.5a3 3 0 0 0 3 3v1.5z",
    milk: "M8 2h8v3l2 3v12a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V8l2-3V2zm.5 7v3h7V9h-7z",
  };
  const icon = (name, size = 24, color = "currentColor") =>
    `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="${color}" aria-hidden="true"><path d="${P[name]}"/></svg>`;

  const CAT = {
    Bebidas: { icon: "coffee", color: "#2D9CDB" },
    Carnes: { icon: "meat", color: "#E5483B" },
    Frutas: { icon: "fruit", color: "#E5483B" },
    Grãos: { icon: "grain", color: "#EE8B30" },
    Higiene: { icon: "soap", color: "#27AE60" },
    Laticínios: { icon: "milk", color: "#F4A623" },
  };
  const catIcon = (cat, size = 40) => {
    const c = CAT[cat];
    return `<span class="cat" style="width:${size}px;height:${size}px;background:${c.color}1f;color:${c.color}">${icon(c.icon, size * 0.55)}</span>`;
  };

  // Despensa do seed (o mesmo das telas do README).
  const PANTRY = [
    { cat: "Bebidas", name: "Café em Pó", have: 1, want: 2, unit: "un", price: 18.9 },
    { cat: "Carnes", name: "Peito de Frango", have: 0, want: 2, unit: "kg", price: 19.9 },
    { cat: "Frutas", name: "Banana Prata", have: 2, want: 6, unit: "un", price: 1.45 },
    { cat: "Grãos", name: "Arroz Branco Tipo 1", have: 1, want: 4, unit: "un", price: 27.9 },
    { cat: "Grãos", name: "Feijão Carioca", have: 1, want: 4, unit: "un", price: 8.49 },
    { cat: "Higiene", name: "Papel Higiênico 12 Rolos", have: 1, want: 2, unit: "un", price: 21.9 },
    { cat: "Laticínios", name: "Leite Integral", have: 4, want: 12, unit: "un", price: 5.29 },
  ];

  const app = $("#app-screen");
  const screenBox = $("#phone-screen");
  const touch = $("#touch");
  let K = 0.75;

  app.append(
    h(`<div class="sb"><span>09:41</span><span class="icons">
      <svg viewBox="0 0 18 12"><rect x="0" y="8" width="3" height="4" rx="1"/><rect x="5" y="5" width="3" height="7" rx="1"/><rect x="10" y="2.5" width="3" height="9.5" rx="1"/><rect x="15" y="0" width="3" height="12" rx="1"/></svg>
      <svg viewBox="0 0 16 12"><path d="M8 2.5c2.4 0 4.6.9 6.2 2.5l1.3-1.4A10.6 10.6 0 0 0 8 .5 10.6 10.6 0 0 0 .5 3.6L1.8 5C3.4 3.4 5.6 2.5 8 2.5zm0 4c1.3 0 2.5.5 3.4 1.3l1.3-1.4A7 7 0 0 0 8 4.5a7 7 0 0 0-4.7 1.9l1.3 1.4C5.5 7 6.7 6.5 8 6.5zm0 4 2-2.1a2.8 2.8 0 0 0-4 0z"/></svg>
      <svg viewBox="0 0 27 13"><rect x=".5" y=".5" width="23" height="12" rx="3.5" fill="none" stroke="currentColor" opacity=".4"/><rect x="2" y="2" width="20" height="9" rx="2"/><path d="M25 4.5v4c.8-.3 1.5-1.1 1.5-2s-.7-1.7-1.5-2z" opacity=".4"/></svg>
    </span></div>`),
  );

  const screens = {};
  function screen(name, html, fixed = "") {
    const el = h(`<section class="scr" data-name="${name}"><div class="content">${html}</div>${fixed}</section>`);
    app.append(el);
    screens[name] = el;
    return el;
  }
  const appbar = (title, lead = "", actions = "") =>
    `<div class="appbar">${lead ? `<span class="lead">${icon(lead)}</span>` : ""}<h1>${title}</h1><span class="acts">${actions}</span></div>`;
  const nav = (active) =>
    `<nav class="bnav">${[
      ["home", "Home"],
      ["pantry", "Despensa"],
      ["", ""],
      ["cart", "Compras"],
      ["chart", "Analise"],
    ]
      .map(([ic, label]) =>
        ic ? `<span class="it${label === active ? " on" : ""}">${icon(ic)}${label === "Despensa" ? '<b class="badge">6</b>' : ""}<span>${label}</span></span>` : '<span class="gap"></span>',
      )
      .join("")}<span class="fab-qr">${icon("qr", 28, "#fff")}</span></nav>`;
  const bar = (have, want) => {
    const pct = Math.min(1, have / want);
    return `<span class="bar"><i style="width:${(pct * 100).toFixed(0)}%;background:${pct >= 1 ? "#53B175" : "#D32F2F"}"></i></span>`;
  };

  // ---------- Home ----------
  const low = PANTRY.filter((p) => p.have < p.want);
  const home = screen(
    "home",
    `${appbar("Home", "", icon("search") + icon("settings"))}
    <div class="pad">
      <h2 class="hello">Bom dia</h2>
      <p class="muted" style="margin-top:2px">Gerencie sua despensa</p>
      <div class="tile t-pantry"><span class="sq">${icon("pantry", 22)}</span><span class="tx"><b>Despensa</b><small>14 itens · <span class="miss">6</span> em falta</small></span>${icon("chevron")}</div>
      <div class="tile"><span class="sq">${icon("cart", 22)}</span><span class="tx"><b>Ultima compra</b><small>Compra do mes · 04/11 · 14 itens</small></span>${icon("chevron")}</div>
      <div class="btn-g">${icon("cart", 20)}Nova compra</div>
      <div class="head2"><b>Estoque baixo</b><span class="link">Ver tudo</span></div>
      <div class="lowlist">${low
        .slice(0, 5)
        .map((p) => `<div class="lrow"><span class="nm">${p.name}</span>${bar(p.have, p.want)}<span class="ct">${p.have}/${p.want}</span></div>`)
        .join("")}</div>
      <div class="card miss-card"><b>Itens em falta</b>${low
        .slice(0, 4)
        .map((p) => `<div class="mrow"><i></i><span>${p.name}</span><span class="ct">${p.have}/${p.want}</span></div>`)
        .join("")}</div>
      <div style="height:120px"></div>
    </div>`,
    nav("Home"),
  );

  // ---------- Despensa ----------
  const groups = [...new Set(PANTRY.map((p) => p.cat))];
  const pantry = screen(
    "pantry",
    `${appbar("Despensa")}
    <div class="pad">${groups
      .map(
        (g) => `<div class="grp">${icon(CAT[g].icon, 16, CAT[g].color)}<span>${g}</span></div>${PANTRY.filter((p) => p.cat === g)
          .map(
            (p, i) => `<div class="pcard" data-name="${p.name}">${catIcon(g)}
              <span class="tx"><b>${p.name}</b><span class="brow">${bar(p.have, p.want)}<span class="ct">${p.have}/${p.want}</span></span></span>
              <span class="step minus">${icon("minusC", 26)}</span><span class="step plus">${icon("plusC", 26)}</span>
            </div>`,
          )
          .join("")}`,
      )
      .join("")}<div style="height:120px"></div></div>`,
    `<span class="fab-add">${icon("add", 28, "#fff")}</span>${nav("Despensa")}`,
  );
  function setStock(name, have) {
    const p = PANTRY.find((x) => x.name === name);
    p.have = have;
    const card = $(`.pcard[data-name="${name}"]`, pantry);
    const pct = Math.min(1, have / p.want);
    const fill = $(".bar i", card);
    fill.style.width = `${(pct * 100).toFixed(0)}%`;
    fill.style.background = pct >= 1 ? "#53B175" : "#D32F2F";
    $(".ct", card).textContent = `${have}/${p.want}`;
  }

  // ---------- Leitura da nota ----------
  const camera = screen(
    "camera",
    `<div class="cam">
      <div class="cam-top"><span>${icon("close", 26, "#fff")}</span><b>Importar NFC-e</b><span></span></div>
      <div class="paper"><div class="paper-in">
        <p class="pt">MERCADO BOA COMPRA LTDA</p><p>CNPJ 00.000.000/0001-00</p><p class="pl">--------------------------------</p>
        <p>ARROZ TIPO 1 5KG ........ 55,80</p><p>FEIJAO CARIOCA 1KG ...... 25,47</p><p>LEITE INTEGRAL UHT 1L ... 42,32</p><p>BANANA PRATA KG ......... 8,74</p><p>CAFE TORRADO 250G ....... 9,90</p><p>SAL REFINADO 1KG ........ 5,45</p>
        <p class="pl">--------------------------------</p><p class="pt">TOTAL R$ 147,68</p>
        <svg class="qrimg" viewBox="0 0 29 29" shape-rendering="crispEdges"></svg>
      </div></div>
      <div class="frame"><i></i><i></i><i></i><i></i><span class="scanline"></span></div>
      <p class="cam-hint">Aponte para o QR code da nota</p>
    </div>`,
  );
  // QR decorativo determinístico (só o desenho; não é uma nota de verdade).
  (() => {
    const svg = $(".qrimg", camera);
    let seed = 7;
    const rnd = () => ((seed = (seed * 9301 + 49297) % 233280) / 233280);
    let cells = "";
    const finder = (x, y) => `<rect x="${x}" y="${y}" width="7" height="7"/><rect x="${x + 1}" y="${y + 1}" width="5" height="5" fill="#fff"/><rect x="${x + 2}" y="${y + 2}" width="3" height="3"/>`;
    for (let y = 0; y < 29; y++)
      for (let x = 0; x < 29; x++) {
        const inFinder = (x < 8 && y < 8) || (x > 20 && y < 8) || (x < 8 && y > 20);
        if (!inFinder && rnd() > 0.52) cells += `<rect x="${x}" y="${y}" width="1" height="1"/>`;
      }
    svg.innerHTML = `<rect width="29" height="29" fill="#fff"/>${cells}${finder(0, 0)}${finder(22, 0)}${finder(0, 22)}`;
  })();

  const LINES = [
    { name: "Arroz Branco Tipo 1", qty: "2 un", price: 55.8, type: "fuzzyLow", raw: "ARROZ TIPO 1 5KG" },
    { name: "Feijão Carioca", qty: "3 un", price: 25.47, type: "fuzzyHigh", raw: "FEIJAO CARIOCA TIPO 1 1KG" },
    { name: "Leite Integral", qty: "8 un", price: 42.32, type: "fuzzyHigh", raw: "LEITE INTEGRAL UHT 1L" },
    { name: "Banana Prata", qty: "1,2 kg", price: 8.74, type: "exact", raw: "BANANA PRATA KG" },
    { name: "Café em Pó", qty: "1 un", price: 9.9, type: "fuzzyHigh", raw: "CAFE TORRADO MOIDO 250G" },
    { name: "Sal Refinado", qty: "1 un", price: 5.45, type: "willCreateNew", raw: "SAL REFINADO 1KG" },
  ];
  const CHIP = {
    exact: ["Vinculado", "#2C7A48", "rgba(83,177,117,.12)", "check"],
    fuzzyHigh: ["Parecido", "#2C7A48", "rgba(83,177,117,.12)", "compare"],
    fuzzyLow: ["Sugerido", "#C0431E", "rgba(243,96,63,.1)", "help"],
    willCreateNew: ["Novo produto", "#2980B9", "rgba(52,152,219,.1)", "plusC"],
  };
  const review = screen(
    "review",
    `${appbar("Revisar importação", "close")}
    <div class="pad">
      <div class="card head-r"><b class="store">MERCADO BOA COMPRA LTDA</b><small>CNPJ 00.000.000/0001-00</small>
        <span class="meta">11/11/2026 18:42 <span style="margin-left:14px">6 itens</span></span>
        <span class="total">${icon("receipt", 18)}Total · ${brl(147.68)}</span></div>
      ${LINES.map((l) => {
        const [label, fg, bg, ic] = CHIP[l.type];
        return `<div class="card rline"><span class="bsk">${icon("basket", 22)}</span>
          <span class="tx"><b>${l.name}</b><small>${l.qty}</small><span class="chip" style="color:${fg};background:${bg}">${icon(ic, 14, fg)}${label}</span><small class="raw">da nota: ${l.raw}</small></span>
          <b class="pr">${brl(l.price)}</b></div>`;
      }).join("")}
      <div style="height:170px"></div>
    </div>`,
    `<div class="rfoot"><div class="ttype"><span>Tipo da compra</span><span class="seg"><span class="on">Avulsa</span><span>Mensal</span></span></div><span class="btn-g imp">${icon("cart", 20)}Importar 6 itens</span></div>
`,
  );

  // ---------- Projetar mercado ----------
  const proj = PANTRY.filter((p) => p.have < p.want).map((p) => ({ ...p, buy: p.want - p.have, picked: false }));
  const fmtQty = (p) => `${p.buy} ${p.unit}`;
  const market = screen(
    "market",
    `${appbar("Projetar mercado", "back")}
    <div class="pad">
      <div class="card sum">
        <h3>Mercado de hoje</h3>
        <div class="srow big"><span><b>No carrinho</b><small class="pc">0 de ${proj.length} itens</small></span><b class="vcart">${brl(0)}</b></div>
        <div class="srow"><span>Falta pegar<small class="pend">${proj.length} itens</small></span><b class="vpend"></b></div>
        <div class="srow"><span>Previsão total<small>carrinho + o que falta</small></span><b class="vtot"></b></div>
      </div>
      ${[...new Set(proj.map((p) => p.cat))]
        .map(
          (g) => `<div class="grp">${icon(CAT[g].icon, 16, CAT[g].color)}<span>${g}</span></div>${proj
            .filter((p) => p.cat === g)
            .map(
              (p) => `<div class="card mitem" data-name="${p.name}">
                <div class="mtop">${catIcon(g, 38)}<span class="tx"><b>${p.name}</b><small>Tem ${p.have} de ${p.want} ${p.unit}</small></span>${icon("trash", 22, "#6B6B6B")}</div>
                <div class="mbot"><span class="qty">${icon("minusC", 24)}<b>${fmtQty(p)}</b>${icon("plusC", 24)}</span><span class="prev">${icon("flat", 16)}<span class="pl">Previsto</span> <span class="pv">${brl(p.price * p.buy)}</span></span></div>
              </div>`,
            )
            .join("")}`,
        )
        .join("")}
      <div style="height:170px"></div>
    </div>`,
    `<div class="mfoot"><span class="seg"><span class="on">${icon("check", 16)}Mensal</span><span>Avulsa</span></span><span class="btn-g">${icon("cart", 20)}Cravar ${proj.length} itens</span></div>`,
  );
  function renderTotals() {
    const cart = proj.filter((p) => p.picked).reduce((s, p) => s + p.price * p.buy, 0);
    const pend = proj.filter((p) => !p.picked);
    const pendV = pend.reduce((s, p) => s + p.price * p.buy, 0);
    $(".vcart", market).textContent = brl(cart);
    $(".pc", market).textContent = `${proj.length - pend.length} de ${proj.length} itens`;
    $(".vpend", market).textContent = brl(pendV);
    $(".pend", market).textContent = `${pend.length} ${pend.length === 1 ? "item" : "itens"}`;
    $(".vtot", market).textContent = brl(cart + pendV);
    return cart;
  }
  function pick(name, on) {
    const p = proj.find((x) => x.name === name);
    p.picked = on;
    const card = $(`.mitem[data-name="${name}"]`, market);
    card.classList.toggle("picked", on);
    $(".pl", card).textContent = on ? "Paguei" : "Previsto";
    $(".prev svg path", card).setAttribute("d", P[on ? "checkC" : "flat"]);
    return renderTotals();
  }

  // ---------- Analise ----------
  const PERIODS = {
    "1M": { spent: 455.95, top: 345.9, topCat: "Grãos", cats: [["Laticínios", 14, "#F6A623"], ["Grãos", 9, "#EE7B30"], ["Frutas", 6, "#E5483B"], ["Massas", 4, "#F4B740"], ["Limpeza", 3, "#9B5DE5"], ["Carnes", 3, "#8D6E63"], ["Bebidas", 2, "#2D9CDB"], ["Higiene", 2, "#E91E63"]] },
    "3M": { spent: 455.95, top: 345.9, topCat: "Grãos", cats: [["Laticínios", 39, "#F6A623"], ["Grãos", 21, "#EE7B30"], ["Frutas", 18, "#E5483B"], ["Massas", 12, "#F4B740"], ["Limpeza", 12, "#9B5DE5"], ["Carnes", 9, "#8D6E63"], ["Bebidas", 6, "#2D9CDB"], ["Higiene", 5, "#E91E63"], ["Hortifruti", 5, "#2EC4B6"]] },
  };
  const spending = screen(
    "spending",
    `${appbar("Analise")}
    <div class="pad">
      <div class="card kpi"><span class="sq">${icon("money", 24)}</span><span class="tx"><small>Gasto em novembro</small><b>${brl(455.95)}</b></span></div>
      <div class="card kpi"><span class="sq">${icon("fire", 24)}</span><span class="tx"><small>Categoria mais cara</small><b>${brl(345.9)}</b><small>Grãos</small></span></div>
      <div class="periods">${["1M", "3M", "6M", "1A"].map((p) => `<span class="per${p === "3M" ? " on" : ""}" data-p="${p}">${p === "3M" ? icon("check", 16) : ""}${p}</span>`).join("")}</div>
      <div class="card donut-card"><h3>Consumo por categoria</h3>
        <svg class="donut" viewBox="0 0 200 200"></svg>
        <div class="legend"></div>
      </div>
      <div style="height:120px"></div>
    </div>`,
    nav("Analise"),
  );
  function drawDonut(period, animate = true) {
    const data = PERIODS[period].cats;
    const total = data.reduce((s, c) => s + c[1], 0);
    const svg = $(".donut", spending);
    const R = 62;
    const C = 2 * Math.PI * R;
    let acc = 0;
    svg.innerHTML = data
      .map(([name, v, color], i) => {
        const len = (v / total) * C;
        const mid = ((acc + len / 2) / C) * 2 * Math.PI - Math.PI / 2;
        const pct = Math.round((v / total) * 100);
        const seg = `<circle class="seg" cx="100" cy="100" r="${R}" fill="none" stroke="${color}" stroke-width="34" stroke-dasharray="${len - 1.2} ${C}" stroke-dashoffset="${-acc}" transform="rotate(-90 100 100)" style="--d:${i * 90}ms;--len:${len}"/>${pct >= 4 ? `<text x="${100 + Math.cos(mid) * R}" y="${100 + Math.sin(mid) * R + 3.5}" text-anchor="middle">${pct}%</text>` : ""}`;
        acc += len;
        return seg;
      })
      .join("");
    $(".legend", spending).innerHTML = data
      .slice(0, 5)
      .map(([name, v, color]) => `<div class="lg"><i style="background:${color}"></i><span>${name}</span><b class="n">${v}</b></div>`)
      .join("");
    if (!animate) return;
    $$(".seg", svg).forEach((seg) =>
      seg.animate([{ strokeDasharray: `0 ${C}` }, { strokeDasharray: seg.getAttribute("stroke-dasharray") }], {
        duration: 620,
        delay: parseInt(getComputedStyle(seg).getPropertyValue("--d")) || 0,
        easing: IOS,
        fill: "backwards",
      }),
    );
    $$("text", svg).forEach((t, i) => t.animate([{ opacity: 0 }, { opacity: 1 }], { duration: 300, delay: 500 + i * 90, fill: "backwards" }));
  }

  // ---------- Escala, toque e navegação (mesmo motor do site do Valorant) ----------

  function measure() {
    K = screenBox.offsetWidth / 402 || K;
    app.style.transform = `scale(${K})`;
    const size = 46 * K;
    touch.style.width = touch.style.height = `${size}px`;
    touch.style.margin = `${-size / 2}px 0 0 ${-size / 2}px`;
  }
  new ResizeObserver(measure).observe(screenBox);
  measure();
  function at(el, dx = 0, dy = 0) {
    const a = app.getBoundingClientRect();
    const r = el.getBoundingClientRect();
    return [(r.left + r.width / 2 - a.left) / K + dx, (r.top + r.height / 2 - a.top) / K + dy];
  }
  let shown = null;
  const scrollY = new WeakMap();
  function setScroll(scr, y, ms = 700) {
    const content = $(".content", scr);
    const from = scrollY.get(scr) ?? 0;
    scrollY.set(scr, y);
    for (const anim of content.getAnimations()) anim.cancel();
    content.style.transform = `translateY(${-y}px)`;
    if (ms) content.animate([{ transform: `translateY(${-from}px)` }, { transform: `translateY(${-y}px)` }], { duration: ms, easing: IOS });
  }
  function go(name, kind = "fade") {
    const next = screens[name];
    const prev = shown;
    if (next === prev) return;
    shown = next;
    for (const anim of next.getAnimations()) anim.cancel();
    setScroll(next, 0, 0);
    next.classList.add("on");
    if (!prev) return;
    prev.classList.remove("on");
    prev.classList.add("leaving");
    const done = () => prev.classList.remove("leaving");
    if (kind === "cut") return done();
    const FR = {
      push: [
        [{ transform: "translateX(100%)", boxShadow: "-24px 0 48px rgba(0,0,0,0)" }, { transform: "none", boxShadow: "-24px 0 48px rgba(0,0,0,.18)" }],
        [{ transform: "none", filter: "brightness(1)" }, { transform: "translateX(-30%)", filter: "brightness(.85)" }],
        560,
      ],
      up: [
        [{ transform: "translateY(100%)" }, { transform: "none" }],
        [{ opacity: 1 }, { opacity: 1 }],
        560,
      ],
      fade: [
        [{ opacity: 0, transform: "scale(1.03)" }, { opacity: 1, transform: "none" }],
        [{ opacity: 1 }, { opacity: 0 }],
        480,
      ],
    }[kind];
    next.animate(FR[0], { duration: FR[2], easing: IOS });
    prev.animate(FR[1], { duration: FR[2], easing: IOS }).finished.then(done, done);
  }
  function makeRun() {
    const run = { alive: true, timers: [], intervals: [] };
    run.sleep = (ms) => new Promise((resolve) => run.timers.push(setTimeout(() => run.alive && resolve(), ms)));
    run.kill = () => {
      run.alive = false;
      run.timers.forEach(clearTimeout);
    };
    run.tap = async (point, press) => {
      const [x, y] = point;
      for (const anim of touch.getAnimations()) anim.cancel();
      touch.style.left = `${x * K}px`;
      touch.style.top = `${y * K}px`;
      touch.animate(
        [
          { opacity: 0, transform: "scale(.5)" },
          { opacity: 1, transform: "scale(1)", offset: 0.34 },
          { opacity: 1, transform: "scale(.8)", offset: 0.52 },
          { opacity: 0, transform: "scale(1.3)" },
        ],
        { duration: 700, easing: "ease-out" },
      );
      await run.sleep(280);
      if (press) press.animate([{ transform: "none" }, { transform: "scale(.96)" }, { transform: "none" }], { duration: 260, easing: "ease-out" });
      await run.sleep(100);
    };
    run.scroll = async (scr, want, x = 200) => {
      const from = scrollY.get(scr) ?? 0;
      const y = Math.max(0, Math.min(want, $(".content", scr).offsetHeight - 874));
      const dist = y - from;
      if (!dist) return;
      const travel = Math.min(Math.abs(dist), 440) * Math.sign(dist);
      const startY = dist > 0 ? 660 : 280;
      for (const anim of touch.getAnimations()) anim.cancel();
      touch.style.left = `${x * K}px`;
      touch.style.top = "0px";
      touch.animate(
        [
          { opacity: 0, transform: `translateY(${startY * K}px) scale(.6)` },
          { opacity: 1, transform: `translateY(${startY * K}px) scale(.9)`, offset: 0.15 },
          { opacity: 1, transform: `translateY(${(startY - travel) * K}px) scale(.9)`, offset: 0.75, easing: IOS },
          { opacity: 0, transform: `translateY(${(startY - travel) * K}px) scale(1.1)` },
        ],
        { duration: 1100 },
      );
      await run.sleep(160);
      setScroll(scr, y, 900);
      await run.sleep(1000);
    };
    return run;
  }

  // ---------- Roteiro de cada cena ----------
  const RESET = () => {
    const base = { "Café em Pó": 1, "Peito de Frango": 0 };
    for (const [n, v] of Object.entries(base)) setStock(n, v);
  };
  const SCENES = {
    home: {
      beats: 2,
      async play(run, ui) {
        go("home", shown ? "fade" : "cut");
        $$(".lowlist .bar i", home).forEach((b, i) => b.animate([{ width: "0%" }, { width: b.style.width }], { duration: 700, delay: 300 + i * 90, easing: IOS, fill: "backwards" }));
        ui.step(0, "Home shows what is running low: each bar is what you have against what you want.");
        await run.sleep(2200);
        await run.scroll(home, 300);
        await run.sleep(1100);
        await run.scroll(home, 0);
        const tile = $(".t-pantry", home);
        await run.tap(at(tile), tile);
        RESET();
        go("pantry", "push");
        ui.step(1, "Tap Despensa to see the whole pantry by category.");
        await run.sleep(2000);
      },
    },
    pantry: {
      beats: 2,
      async play(run, ui) {
        RESET();
        go("pantry", shown ? "fade" : "cut");
        ui.step(0, "Every product has what you have and what you want. The bar turns green when it is full.");
        await run.sleep(1500);
        const cafe = $('.pcard[data-name="Café em Pó"] .plus', pantry);
        await run.tap(at(cafe), cafe);
        setStock("Café em Pó", 2);
        ui.value("13");
        await run.sleep(1300);
        const frango = $('.pcard[data-name="Peito de Frango"] .plus', pantry);
        await run.tap(at(frango), frango);
        setStock("Peito de Frango", 1);
        await run.sleep(900);
        await run.tap(at(frango), frango);
        setStock("Peito de Frango", 2);
        ui.value("12");
        ui.step(1, "Bought something? One tap on plus and the pantry knows.");
        await run.sleep(1600);
        await run.scroll(pantry, 360);
        await run.sleep(1600);
      },
    },
    receipt: {
      beats: 3,
      async play(run, ui) {
        go("camera", shown ? "fade" : "cut");
        $(".scanline", camera).animate([{ transform: "translateY(0)" }, { transform: "translateY(214px)" }], { duration: 1400, iterations: 2, direction: "alternate", easing: "ease-in-out" });
        ui.step(0, "Point the camera at the NFC-e QR code. The invoice comes from the state tax portal.");
        await run.sleep(2900);
        $(".frame", camera).animate([{ transform: "scale(1)" }, { transform: "scale(.94)" }, { transform: "scale(1)" }], { duration: 360, easing: "ease-out" });
        await run.sleep(300);
        go("review", "up");
        const rows = $$(".rline", review);
        rows.forEach((r, i) => r.animate([{ opacity: 0, transform: "translateY(18px)" }, { opacity: 1, transform: "none" }], { duration: 480, delay: 300 + i * 120, easing: IOS, fill: "backwards" }));
        $$(".rline .chip", review).forEach((c, i) => c.animate([{ opacity: 0, transform: "scale(.6)" }, { opacity: 1, transform: "none" }], { duration: 420, delay: 900 + i * 160, easing: "cubic-bezier(.34,1.4,.64,1)", fill: "backwards" }));
        ui.step(1, "Each line lands on a product you already have. A new line becomes a product with a suggested category.");
        await run.sleep(2600);
        await run.scroll(review, 420);
        await run.sleep(900);
        const btn = $(".imp", review);
        await run.tap(at(btn), btn);
        ui.step(2, "Confirm and the purchase is filled in. Finishing it adds the quantities to the pantry.");
        await run.sleep(2600);
      },
    },
    market: {
      beats: 2,
      async play(run, ui) {
        proj.forEach((p) => pick(p.name, false));
        ui.value(brl(0));
        go("market", shown ? "fade" : "cut");
        ui.step(0, "Everything below its ideal amount, priced with what you paid last time.");
        await run.sleep(2000);
        for (const name of ["Café em Pó", "Peito de Frango"]) {
          const card = $(`.mitem[data-name="${name}"]`, market);
          await run.tap(at(card, 0, -18), card);
          const cart = pick(name, true);
          ui.value(brl(cart));
          if (name === "Café em Pó") ui.step(1, "At the market, tap an item as you pick it: the cart adds up and what is left goes down.");
          await run.sleep(1300);
        }
        await run.scroll(market, 380);
        const card = $('.mitem[data-name="Banana Prata"]', market);
        await run.tap(at(card, 0, -18), card);
        ui.value(brl(pick("Banana Prata", true)));
        await run.sleep(2200);
      },
    },
    spending: {
      beats: 2,
      async play(run, ui) {
        for (const per of $$(".per", spending)) per.classList.toggle("on", per.dataset.p === "3M");
        go("spending", shown ? "fade" : "cut");
        await run.sleep(200);
        drawDonut("3M");
        ui.step(0, "This month's spending, the most expensive category and what each category takes.");
        await run.sleep(2600);
        const one = $('.per[data-p="1M"]', spending);
        await run.tap(at(one), one);
        for (const per of $$(".per", spending)) {
          const on = per.dataset.p === "1M";
          per.classList.toggle("on", on);
          per.innerHTML = `${on ? icon("check", 16) : ""}${per.dataset.p}`;
        }
        drawDonut("1M");
        ui.step(1, "Switch the period and the chart redoes the math.");
        await run.sleep(2600);
        await run.scroll(spending, 300);
        await run.sleep(1600);
        const three = $('.per[data-p="3M"]', spending);
        await run.scroll(spending, 0);
        await run.tap(at(three), three);
        for (const per of $$(".per", spending)) {
          const on = per.dataset.p === "3M";
          per.classList.toggle("on", on);
          per.innerHTML = `${on ? icon("check", 16) : ""}${per.dataset.p}`;
        }
        drawDonut("3M");
        await run.sleep(2000);
      },
    },
  };

  window.DemoApp = {
    scenes: SCENES,
    play(name, ui) {
      const run = makeRun();
      SCENES[name].play(run, ui).then(() => run.alive && ui.done());
      return run;
    },
  };
  renderTotals();
  drawDonut("3M", false);
  go("home", "cut");
})();
