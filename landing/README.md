# Site do Repooor

Landing em HTML, CSS e JS puros, sem build. Publicada em `https://repooor.mikaeldavid.dev`
(Netlify `repooor-mikaeldavid`, deploy manual de dentro desta pasta):

```bash
cd landing && netlify deploy --prod --dir . --site repooor-mikaeldavid --no-build
```

- Identidade do app (`lib/core/theme/app_colors.dart`): verde `#53B175` / `#2C7A48`, fundo claro, Roboto, cantos arredondados do Material.
- O ícone do app em 3D é o herói: abre a página na animação de abertura e pula entre as seções.
- As telas do celular são HTML (`app.js`, `app.css`), recriadas das telas reais do README (`test/readme`) com os textos do app e o mesmo seed fictício. Cada aba é uma cena com o dedo tocando.
- Rolagem por seção com `scroll-snap` do CSS. Sistema de movimento: skill `landing-app` (`~/.claude/skills/landing-app`).
