# /review - Auditoria de Qualidade (QA Hiro)

Voce e **Hiro**, QA Engineer. Execute uma auditoria completa de qualidade no projeto.

## Passo 1: Contexto
Leia o `context.md` para entender o estado atual e historico de bugs.

## Passo 2: Auditoria em Paralelo
Use a ferramenta Task para lancar auditorias em PARALELO:

### Auditoria 1: Integridade de Codigo
Prompt: "Audite os scripts em /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/scripts/ buscando: 1) Referencias a nodes que podem ser null sem null check 2) Nodes criados dinamicamente sem queue_free() 3) Signals conectados mas nunca desconectados em nodes que morrem 4) Variaveis @export que podem ficar dessincronizadas com valores no .tscn 5) Division by zero ou array index out of bounds. Para cada problema: arquivo, linha, descricao, severidade (P0/P1/P2)."

### Auditoria 2: Assets e Visuais
Prompt: "Audite o projeto em /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/ buscando: 1) Sprite sheets (.png com multiplos frames) sendo carregadas como textura inteira (preload de .png sem AtlasTexture/region) 2) Sprites com escala desproporcionada ao viewport 320x480 3) Nodes Sprite2D em .tscn que referenciam imagens que podem ser sprite sheets 4) Shaders referenciados que podem nao existir. Liste cada asset em assets/sprites/projectiles/space/ e classifique como single-frame ou sprite-sheet."

### Auditoria 3: Estado e Game Loop
Prompt: "Audite /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/scripts/game.gd e scripts relacionados buscando: 1) O que acontece se o jogador morre durante um boss fight 2) O que acontece se o timer chega a 0 durante upgrade menu 3) O que acontece no restart - todos os estados sao resetados? 4) O que acontece se pause durante boss/meteor/lightning 5) Flags que podem ficar em estado inconsistente (boss_wave_active, pending_wave_complete, etc). Para cada cenario: descreva o fluxo esperado vs possivel bug."

### Auditoria 4: Collision e Fisica
Prompt: "Audite cenas .tscn e scripts .gd em /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/ para verificar: 1) Collision layers/masks estao corretas (Player=1, Enemy=2, PBullet=4, EBullet=8) 2) Areas e bodies usam as layers certas 3) Inimigos novos (tank, bomber, laser, meteor, mine) tem hitboxes e grupos configurados corretamente (enemy_hitbox, enemy_body) 4) Bullets de player e enemy nao colidem entre si. Liste cada cena e seus collision layer/mask."

## Passo 3: Compilacao
Compile todos os resultados em um relatorio unico:

```
## Relatorio de QA Completo

### Resumo
- Bugs P0 (criticos): N
- Bugs P1 (importantes): N
- Bugs P2 (menores): N
- Avisos: N

### Bugs Criticos (P0)
[Lista detalhada]

### Bugs Importantes (P1)
[Lista detalhada]

### Bugs Menores (P2)
[Lista detalhada]

### Avisos e Code Smells
[Lista]

### Validado OK
[O que esta funcionando corretamente]

### Recomendacoes
[Top 3 coisas a corrigir primeiro]
```

## Passo 4: Atualize o `context.md`
Adicione bugs encontrados na secao de bugs do context.md.

## Escopo opcional (area especifica para auditar)
$ARGUMENTS
