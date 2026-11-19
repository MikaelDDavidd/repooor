// Site do Repooor (base: site do Valorant Guide): escada de entrada, marca VG em 3D, ilha do celular com mola, odômetro,
// paralaxe e o passeio pelas telas reais do app. Sem dependências.
(() => {
  const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const prefersReduce = reduce;
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];

  // ---------- Mola (stiffness, damping, massa) ----------

  const running = new WeakMap();
  const velocities = new WeakMap();
  function spring(state, target, { k = 150, c = 20, m = 1, delay = 0, onUpdate, onDone } = {}) {
    running.get(state)?.cancel();
    if (!velocities.has(state)) velocities.set(state, {});
    const velocity = velocities.get(state);
    const keys = Object.keys(target);
    for (const key of keys) velocity[key] ??= 0;
    if (reduce) {
      Object.assign(state, target);
      onUpdate?.(state);
      onDone?.();
      return;
    }
    let raf = 0;
    let timer = 0;
    let last = 0;
    const tick = (now) => {
      const dt = Math.min((now - last) / 1000, 1 / 30);
      last = now;
      const steps = Math.max(1, Math.round(dt / (1 / 240)));
      const h = dt / steps;
      let settled = true;
      for (const key of keys) {
        for (let i = 0; i < steps; i++) {
          const force = -k * (state[key] - target[key]) - c * velocity[key];
          velocity[key] += (force / m) * h;
          state[key] += velocity[key] * h;
        }
        if (Math.abs(state[key] - target[key]) > 0.01 || Math.abs(velocity[key]) > 0.05)
          settled = false;
      }
      if (settled) {
        for (const key of keys) {
          state[key] = target[key];
          velocity[key] = 0;
        }
        onUpdate?.(state);
        running.delete(state);
        onDone?.();
        return;
      }
      onUpdate?.(state);
      raf = requestAnimationFrame(tick);
    };
    const start = () => {
      last = performance.now();
      raf = requestAnimationFrame(tick);
    };
    if (delay) timer = setTimeout(start, delay * 1000);
    else start();
    running.set(state, {
      cancel() {
        clearTimeout(timer);
        cancelAnimationFrame(raf);
      },
    });
  }

  // ---------- Entrada na carga (depois da abertura) ----------

  function startRise() {
    for (const el of $$(".rise")) {
      el.style.transitionDelay = `${el.dataset.delay ?? 0}ms`;
      el.classList.add("in");
      el.addEventListener("transitionend", () => (el.style.transitionDelay = ""), { once: true });
    }
  }

  // ---------- Marca VG em 3D: camadas empilhadas que balançam, seguem o ponteiro e pulam ----------

  const mark = $("#mark3d");
  const markHop = $("#mark-hop");
  const markShadow = $("#mark-shadow");
  // O ícone do app (cesta branca no quadrado verde) como uma peça 3D: a frente e o verso são o
  // ícone; o miolo são quadrados num verde mais escuro, que dão a espessura.
  const LAYERS = 14;
  const GAP = 1.6;
  for (let i = LAYERS - 1; i >= 0; i--) {
    const layer = document.createElement("span");
    layer.className = "layer";
    if (i === 0 || i === LAYERS - 1) layer.innerHTML = '<img src="img/icon-512.png" alt="">';
    else layer.style.background = `hsl(142 40% ${Math.round(30 + 8 * Math.sin((i / (LAYERS - 1)) * Math.PI))}%)`;
    layer.style.transform = `translateZ(${(-i + (LAYERS - 1) / 2) * GAP}px)${i === LAYERS - 1 ? " rotateY(180deg)" : ""}`;
    mark.append(layer);
  }
  const pose = { ry: 0, rx: -8, y: 0, sx: 1, sy: 1, extra: 0, rz: 0 };
  // A cesta balança pela alça (pivô acima do ícone), como uma cesta carregada na mão.
  markHop.style.transformOrigin = "50% -40px";
  const aim = { x: 0, y: 0, on: false };
  function renderMark() {
    mark.style.transform = `rotateX(${pose.rx}deg) rotateY(${pose.ry + pose.extra}deg)`;
    markHop.style.transform = `translateY(${pose.y}px) rotate(${pose.rz}deg) scale(${pose.sx}, ${pose.sy})`;
    const height = Math.min(1, -pose.y / 70);
    markShadow.style.transform = `scale(${1 - 0.45 * height})`;
    markShadow.style.opacity = String(1 - 0.6 * height);
  }
  renderMark();

  let hopping = false;
  function hop() {
    if (hopping || reduce) return;
    hopping = true;
    spring(pose, { sx: 1.12, sy: 0.82 }, { k: 420, c: 24, onUpdate: renderMark });
    setTimeout(() => {
      const duration = 600;
      const peak = 60;
      const start = performance.now();
      const from = pose.extra;
      spring(pose, { sx: 0.94, sy: 1.08 }, { k: 300, c: 20, onUpdate: renderMark });
      const air = (now) => {
        const t = Math.min(1, (now - start) / duration);
        pose.y = -4 * peak * t * (1 - t);
        pose.rz = 10 * Math.sin(t * Math.PI * 2);
        renderMark();
        if (t < 1) {
          requestAnimationFrame(air);
          return;
        }
        pose.y = 0;
        pose.sx = 1.14;
        pose.sy = 0.84;
        spring(pose, { sx: 1, sy: 1, rz: 0 }, { k: 320, c: 11, onUpdate: renderMark, onDone: () => (hopping = false) });
      };
      requestAnimationFrame(air);
    }, 150);
  }
  // ---------- A marca acompanha a página: um poleiro por seção, pulo com arco entre eles ----------

  const buddy = $("#buddy");
  const perches = $$(".perch");
  const IOS_EASE = (t) => (t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) ** 3 / 2);
  const scaleOf = (p) => +(innerWidth < 640 ? (p.dataset.scaleM ?? p.dataset.scale) : p.dataset.scale);
  const spot = (p) => {
    const r = p.getBoundingClientRect();
    return { x: r.left + r.width / 2, y: r.top + r.height / 2, s: scaleOf(p) };
  };
  const place = { x: 0, y: 0, s: 1 };
  let perch = perches[0];
  let flying = false;
  const renderBuddy = () => (buddy.style.transform = `translate(${place.x}px, ${place.y}px) scale(${place.s})`);
  function settle() {
    if (flying) return;
    Object.assign(place, spot(perch));
    renderBuddy();
  }
  function flyTo(next) {
    perch = next;
    if (reduce) return settle();
    flying = true;
    hopping = true;
    const from = { ...place };
    // Se o poleiro de origem já saiu da tela, a cesta entra pela borda em vez de voar escondida.
    from.y = Math.max(-80, Math.min(innerHeight + 80, from.y));
    spring(pose, { sx: 1.14, sy: 0.82 }, { k: 420, c: 24, onUpdate: renderMark });
    setTimeout(() => {
      const t0 = performance.now();
      const to0 = spot(perch);
      const dist = Math.hypot(to0.x - from.x, to0.y - from.y);
      const duration = Math.min(980, 520 + dist * 0.22);
      const arc = Math.max(70, Math.min(260, 90 + dist * 0.18));
      const dir = Math.abs(to0.x - from.x) > 30 ? Math.sign(to0.x - from.x) : from.y < to0.y ? 1 : -1;
      spring(pose, { sx: 0.92, sy: 1.1 }, { k: 300, c: 20, onUpdate: renderMark });
      const frame = (now) => {
        const to = spot(perch);
        const t = Math.min(1, (now - t0) / duration);
        const e = IOS_EASE(t);
        place.x = from.x + (to.x - from.x) * e;
        place.y = from.y + (to.y - from.y) * e - arc * 4 * t * (1 - t);
        place.s = from.s + (to.s - from.s) * e;
        pose.rz = dir * 18 * Math.sin(Math.PI * t);
        renderBuddy();
        renderMark();
        if (t < 1) return requestAnimationFrame(frame);
        pose.sx = 1.16;
        pose.sy = 0.82;
        pose.rz = -dir * 14;
        // Pousa e oscila como pêndulo até parar.
        spring(pose, { sx: 1, sy: 1, rz: 0 }, { k: 110, c: 5, onUpdate: renderMark });
        flying = false;
        hopping = false;
        settle();
        restock(perches.indexOf(perch));
        check();
      };
      requestAnimationFrame(frame);
    }, 110);
  }
  // ---------- A cesta se enche: o selo de "em falta" desce a cada seção e um produto cai nela ----------

  const MISSING = [6, 4, 2, 0];
  const ITEMS = [
    ["#E5483B", "M12 7.5c-1.2-1.1-2.7-1.6-4.3-1.3C4.6 6.8 3 9.8 3.6 13.4 4.3 17.5 7 21 9.6 21c.9 0 1.5-.5 2.4-.5s1.5.5 2.4.5c2.6 0 5.3-3.5 6-7.6.6-3.6-1-6.6-4.1-7.2-1.6-.3-3.1.2-4.3 1.3zM12 6.5c.2-2 1.4-3.6 3.6-4-.1 2-1.5 3.7-3.6 4z"],
    ["#2D9CDB", "M8 2h8v3l2 3v12a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V8l2-3V2zm.5 7v3h7V9h-7z"],
    ["#8D6E63", "M18.5 3H6c-1.1 0-2 .9-2 2v5.71c0 3.83 2.95 7.18 6.78 7.29 3.96.12 7.22-3.06 7.22-7v-1h.5c1.93 0 3.5-1.57 3.5-3.5S20.43 3 18.5 3zM16 5v3H6V5h10zm2.5 3H18V5h.5c.83 0 1.5.67 1.5 1.5S19.33 8 18.5 8zM4 19h16v2H4z"],
    ["#EE8B30", "M12 22c-.5 0-1-.4-1-1v-6.3C8.1 14.2 6 11.6 6 8.5V5l2 1c1.7.8 3 2.3 3.6 4.1h.8C13 8.3 14.3 6.8 16 6l2-1v3.5c0 3.1-2.1 5.7-5 6.2V21c0 .6-.5 1-1 1z"],
  ];
  const badge = document.createElement("span");
  badge.className = "miss-badge";
  badge.innerHTML = '<span class="roll" id="miss-n"></span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 16.17 4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>';
  markHop.append(badge);
  const missN = badge.querySelector("#miss-n");
  let missing = MISSING[0];
  setRoll(missN, String(missing));
  function dropItem(k) {
    const [color, d] = ITEMS[k % ITEMS.length];
    const item = document.createElement("span");
    item.className = "drop";
    item.style.background = color;
    item.innerHTML = `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="${d}"/></svg>`;
    markHop.append(item);
    const x = (k % 2 ? 1 : -1) * (8 + 10 * Math.random());
    item
      .animate(
        [
          { transform: `translate(${x}px, -190px) rotate(${-40 * Math.sign(x)}deg) scale(1)`, opacity: 0 },
          { opacity: 1, offset: 0.15 },
          { transform: `translate(${x * 0.3}px, -30px) rotate(${10 * Math.sign(x)}deg) scale(.95)`, opacity: 1, offset: 0.78 },
          { transform: "translate(0, 6px) rotate(0) scale(.25)", opacity: 0 },
        ],
        { duration: 700, easing: "cubic-bezier(.5,0,.75,0)" },
      )
      .finished.then(() => {
        item.remove();
        pose.sx = 1.1;
        pose.sy = 0.88;
        spring(pose, { sx: 1, sy: 1 }, { k: 360, c: 12, onUpdate: renderMark });
      });
  }
  // O pouso só toca o efeito com a cesta na tela; se a pessoa passou rápido, espera ela aparecer.
  let pendingRestock = -1;
  const onScreen = () => place.y > 60 && place.y < innerHeight - 40;
  function restock(index) {
    if (!onScreen()) {
      pendingRestock = index;
      return;
    }
    pendingRestock = -1;
    const want = MISSING[Math.max(0, Math.min(MISSING.length - 1, index))];
    if (want === missing) return;
    const down = want < missing;
    const drops = (missing - want) / 2;
    if (down && !reduce) for (let k = 0; k < drops; k++) setTimeout(() => dropItem(index + k), 120 + k * 300);
    setTimeout(() => {
      missing = want;
      badge.classList.toggle("done", missing === 0);
      if (missing > 0) setRoll(missN, String(missing), { direction: down ? -1 : 1 });
      badge.animate([{ transform: "translateZ(40px) scale(1)" }, { transform: "translateZ(40px) scale(1.25)" }, { transform: "translateZ(40px) scale(1)" }], { duration: 360, easing: "ease-out" });
    }, down ? 820 + Math.max(0, drops - 1) * 300 : 0);
  }

  // Pula quando o centro do próximo poleiro passa de 86% da altura da tela (regra do Hatchling).
  function pick() {
    let best = perches[0];
    for (const p of perches) {
      const r = p.getBoundingClientRect();
      if (r.top + r.height / 2 < innerHeight * 0.86) best = p;
    }
    return best;
  }
  let introDone = false;
  function check() {
    if (!introDone || flying) return;
    const next = pick();
    if (next !== perch) flyTo(next);
  }
  let checkQueued = false;
  window.addEventListener(
    "scroll",
    () => {
      if (checkQueued) return;
      checkQueued = true;
      requestAnimationFrame(() => {
        checkQueued = false;
        settle();
        if (!flying && pendingRestock >= 0 && onScreen()) restock(pendingRestock);
        check();
      });
    },
    { passive: true },
  );
  new ResizeObserver(() => settle()).observe(document.body);
  window.addEventListener("load", settle);

  // ---------- Abertura: a marca se monta, a faixa cruza e a marca voa para o topo ----------

  const intro = $("#intro");
  function endIntro() {
    intro.classList.add("gone");
    document.documentElement.classList.remove("intro-on");
    buddy.classList.add("ready");
    introDone = true;
    check();
  }
  function runIntro() {
    settle();
    // Roda a cada abertura. Só pula com "reduzir movimento", com a página já rolada ou aberta num #link.
    if (reduce || scrollY > 40 || location.hash) {
      endIntro();
      startRise();
      return;
    }
    document.documentElement.classList.add("intro-on");
    const logo = $("#intro-mark");
    const band = $(".intro-band", intro);
    const EASE = "cubic-bezier(.32,.72,0,1)";
    logo.animate(
      [
        { transform: "scale(.4) rotate(-12deg)", opacity: 0 },
        { transform: "scale(1.08) rotate(3deg)", opacity: 1, offset: 0.6 },
        { transform: "none", opacity: 1 },
      ],
      { duration: 760, easing: EASE, fill: "both" },
    );
    setTimeout(() => {
      band.animate([{ transform: "translateX(-70vw) skewX(-24deg)" }, { transform: "translateX(140vw) skewX(-24deg)" }], {
        duration: 820,
        easing: "cubic-bezier(.7,0,.3,1)",
        fill: "forwards",
      });
    }, 620);
    setTimeout(() => {
      settle();
      const front = $("#mark3d .layer:last-child");
      const r = front.getBoundingClientRect();
      const m = logo.getBoundingClientRect();
      const dx = r.left + r.width / 2 - (m.left + m.width / 2);
      const dy = r.top + r.height / 2 - (m.top + m.height / 2);
      logo.animate([{ transform: "none" }, { transform: `translate(${dx}px, ${dy}px) scale(${r.width / m.width})` }], { duration: 720, easing: EASE, fill: "forwards" });
      intro.animate([{ backgroundColor: "#0f1923" }, { backgroundColor: "rgba(15,25,35,0)" }], { duration: 560, delay: 120, easing: "ease-out", fill: "forwards" });
      startRise();
    }, 1080);
    setTimeout(endIntro, 1820);
  }
  requestAnimationFrame(() => requestAnimationFrame(runIntro));

  if (!reduce) {
    const hit = $("#mark-hit");
    const t0 = performance.now();
    const idle = (now) => {
      const t = (now - t0) / 1000;
      const wantY = aim.on ? aim.x * 30 : 16 * Math.sin(t * 0.8);
      const wantX = aim.on ? -8 - aim.y * 18 : -8 + 4 * Math.sin(t * 0.7);
      pose.ry += (wantY - pose.ry) * 0.08;
      pose.rx += (wantX - pose.rx) * 0.08;
      renderMark();
      requestAnimationFrame(idle);
    };
    requestAnimationFrame(idle);
    hit.addEventListener("pointermove", (event) => {
      const box = hit.getBoundingClientRect();
      aim.x = ((event.clientX - box.left) / box.width) * 2 - 1;
      aim.y = ((event.clientY - box.top) / box.height) * 2 - 1;
      aim.on = true;
    });
    hit.addEventListener("pointerleave", () => (aim.on = false));
    hit.addEventListener("click", hop);
    const schedule = (ms) =>
      setTimeout(() => {
        if (!document.hidden && !aim.on && !prefersReduce && !flying) hop();
        schedule(6000 + Math.random() * 4000);
      }, ms);
    schedule(1700);
  }

  // ---------- Cabeçalho ----------

  const header = $("#header");
  const onScroll = () => header.classList.toggle("scrolled", window.scrollY > 32);
  onScroll();

  for (const link of $$(".hover-snap")) {
    let entered = 0;
    link.addEventListener("mouseenter", () => (entered = performance.now()));
    link.addEventListener("mouseleave", () => {
      if (performance.now() - entered < 0.88 * 300) {
        link.classList.add("snap-back");
        requestAnimationFrame(() => requestAnimationFrame(() => link.classList.remove("snap-back")));
      }
    });
  }

  // Selo do "Em breve": ao sair do hover, um empurrão de 45 graus (o selo tem 8 pontas).
  const sealButton = $("#seal-btn");
  const kick = $(".seal .kick");
  let sealEnter = 0;
  kick.style.transformOrigin = "12px 12px";
  sealButton.addEventListener("mouseenter", () => (sealEnter = performance.now()));
  sealButton.addEventListener("mouseleave", () => {
    if (reduce || performance.now() - sealEnter < 100) return;
    kick.animate([{ transform: "rotate(0deg)" }, { transform: "rotate(45deg)" }], {
      duration: 500,
      easing: "cubic-bezier(0, 0, .58, 1)",
    });
  });

  // ---------- Odômetro ----------

  function setRoll(el, text, { direction = 1 } = {}) {
    const previous = el.dataset.shown ?? "";
    el.dataset.shown = text;
    const spans = [...el.children].filter((child) => !child.classList.contains("out"));
    if (spans.length !== text.length) {
      el.textContent = "";
      for (const char of text) {
        const span = document.createElement("span");
        span.textContent = char;
        el.append(span);
      }
      return;
    }
    const height = el.offsetHeight || 20;
    [...text].forEach((char, index) => {
      if (previous[index] === char) return;
      const old = spans[index];
      const fresh = document.createElement("span");
      fresh.textContent = char;
      old.after(fresh);
      old.classList.add("out");
      old.style.left = `${old.offsetLeft}px`;
      if (reduce) {
        old.remove();
        return;
      }
      old
        .animate(
          [
            { transform: "none", opacity: 1, filter: "blur(0px)" },
            {
              transform: `translateY(${-direction * (height / 2)}px) scale(.6)`,
              opacity: 0,
              filter: `blur(${height / 6}px)`,
            },
          ],
          { duration: 400, easing: "cubic-bezier(0, 0, .58, 1)", fill: "forwards" },
        )
        .finished.then(() => old.remove());
      const state = { y: direction * (height / 3), s: 0.8, o: 0, b: height / 6 };
      const draw = (st) => {
        fresh.style.transform = `translateY(${st.y}px) scale(${st.s})`;
        fresh.style.opacity = Math.min(1, Math.max(0, st.o));
        fresh.style.filter = `blur(${Math.max(0, st.b)}px)`;
      };
      draw(state);
      spring(state, { y: 0, s: 1, o: 1, b: 0 }, { k: 150, c: 14, onUpdate: draw });
    });
  }
  const pad = (n) => String(n).padStart(2, "0");
  const hms = (s) => `${pad(Math.floor(s / 3600))}:${pad(Math.floor((s % 3600) / 60))}:${pad(s % 60)}`;

  // ---------- Celular: as telas são HTML (app.js); aqui ficam as abas, a legenda e o contador ----------

  const stage = $("#stage");
  const phone = $("#phone");
  const caption = $("#step-caption");
  new ResizeObserver(() => (phone.style.padding = `${phone.offsetWidth * 0.035}px`)).observe(stage);
  phone.style.padding = `${phone.offsetWidth * 0.035}px`;

  const SCENES = {
    home: { label: "Low stock", value: "6" },
    pantry: { label: "In the pantry", value: "14" },
    receipt: { label: "Receipt items", value: "6" },
    market: { label: "In the cart", value: "R$ 0,00" },
    spending: { label: "November", value: "R$ 455,95" },
  };
  const ORDER = Object.keys(SCENES);

  const pillName = $("#pill-name");
  const pillValue = $("#pill-value");
  const counterNum = $("#counter-num");
  const stepsBar = $("#steps");
  const phases = $("#phases");
  const slider = $("#phase-slider");

  function movePhase(name) {
    const target = $(`.phase[data-scene="${name}"]`, phases);
    for (const el of $$(".phase", phases)) {
      const on = el === target;
      el.classList.toggle("on", on);
      el.setAttribute("aria-selected", String(on));
    }
    slider.style.width = `${target.offsetWidth}px`;
    slider.style.transform = `translateX(${target.offsetLeft}px)`;
    if (phases.scrollWidth > phases.clientWidth)
      phases.scrollTo({ left: target.offsetLeft - phases.clientWidth / 2 + target.offsetWidth / 2, behavior: "smooth" });
  }
  requestAnimationFrame(() => {
    slider.style.transition = "none";
    movePhase("home");
    requestAnimationFrame(() => (slider.style.transition = ""));
  });
  window.addEventListener("resize", () => movePhase(current || "home"));

  function setLayer(selector, name) {
    for (const el of $$(selector, stage)) el.classList.toggle("on", el.dataset.scene === name);
  }
  let captionTimer = 0;
  function setCaption(text) {
    caption.classList.add("swap");
    clearTimeout(captionTimer);
    captionTimer = setTimeout(() => {
      caption.textContent = text;
      caption.classList.remove("swap");
    }, 220);
  }

  let current = "";
  let run = null;
  let auto = true;

  function renderSteps(count, index) {
    stepsBar.innerHTML = "";
    stepsBar.classList.add("manual");
    for (let i = 0; i < count; i++) {
      const bar = document.createElement("i");
      if (i <= index) bar.className = "done";
      stepsBar.append(bar);
    }
  }

  function show(name) {
    if (name === current) return;
    run?.kill();
    current = name;
    const scene = SCENES[name];
    movePhase(name);
    setLayer(".bg", name);
    setLayer(".title", name);
    setRoll(counterNum, pad(ORDER.indexOf(name) + 1));
    pillName.textContent = scene.label;
    pillValue.dataset.shown = "";
    pillValue.textContent = "";
    setRoll(pillValue, scene.value);
    const beats = window.DemoApp.scenes[name].beats;
    renderSteps(beats, -1);
    run = window.DemoApp.play(name, {
      step(index, text) {
        if (current !== name) return;
        renderSteps(beats, index);
        setCaption(text);
      },
      value(text) {
        if (current === name) setRoll(pillValue, text, { direction: -1 });
      },
      done() {
        if (current !== name || !auto) return;
        setTimeout(() => current === name && show(ORDER[(ORDER.indexOf(name) + 1) % ORDER.length]), 900);
      },
    });
  }

  let started = false;
  function unlock() {
    if (started) return;
    started = true;
    stage.classList.add("unlocked");
    stage.style.cursor = "default";
  }
  function start() {
    if (started) return;
    unlock();
    setTimeout(() => show("home"), 450);
  }
  stage.addEventListener("click", () => start());
  for (const button of $$(".phase", phases)) {
    button.addEventListener("click", (event) => {
      event.stopPropagation();
      auto = false;
      unlock();
      current = "";
      show(button.dataset.scene);
    });
  }
  // Abre sozinho quando o palco aparece na tela, para quem só rola a página.
  new IntersectionObserver(
    ([entry], observer) => {
      if (!entry.isIntersecting) return;
      observer.disconnect();
      setTimeout(start, 2600);
    },
    { threshold: 0.6 },
  ).observe(stage);

  window.addEventListener("pagehide", () => run?.kill());

  // ---------- Paralaxe do fundo do palco ----------

  const frame = $(".stage-frame");
  const wallpapers = $$(".bg", stage);
  function parallax() {
    if (prefersReduce) return;
    const max = document.documentElement.scrollHeight - window.innerHeight;
    const progress = max > 0 ? window.scrollY / max : 0;
    for (const img of wallpapers) {
      const travel = Math.max(0, img.offsetHeight - frame.offsetHeight);
      img.style.transform = `translateY(${-progress * travel}px)`;
    }
  }
  window.addEventListener(
    "scroll",
    () => {
      onScroll();
      parallax();
    },
    { passive: true },
  );
  window.addEventListener("resize", parallax);
  parallax();

  // ---------- Dica "Psst": o cursor cutuca a cada 4 s ----------

  const psst = $("#psst");
  const cursor = $("#psst-cursor");
  let nudge = 0;
  const move = (x, ms) => {
    cursor.style.transition = `transform ${ms}ms cubic-bezier(.4,0,.2,1)`;
    cursor.style.transform = `translate(${x}px, ${x}px)`;
  };
  const startNudge = () => {
    if (reduce) return;
    nudge = setInterval(() => {
      move(-4, 1000);
      setTimeout(() => move(0, 700), 1000);
    }, 4000);
  };
  psst.addEventListener("mouseenter", () => {
    clearInterval(nudge);
    move(-6, 700);
  });
  psst.addEventListener("mouseleave", () => {
    move(0, 700);
    startNudge();
  });
  startNudge();
})();
