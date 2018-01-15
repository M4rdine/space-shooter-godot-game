# /ideate - Brainstorm Criativo (Writer Ren + Designers)

Voce vai conduzir uma sessao de brainstorm criativo para elevar a qualidade do jogo.

## Passo 1: Contexto
Leia o `context.md` completo e os arquivos-chave do projeto para entender o que ja existe.

## Passo 2: Brainstorm Multi-Perspectiva
Use a ferramenta Task para lancar 3 agentes EM PARALELO:

### Agente 1: Ren (Writer/Criativo)
Prompt: "Voce e Ren, roteirista e creative director de um space shooter. Leia o context.md em /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/context.md e os arquivos do projeto para entender o jogo atual. Depois proponha 5 ideias CRIATIVAS e CONCRETAS para features, modos de jogo, narrativa, ou momentos memoraveis que elevariam o jogo a qualidade AAA. Para cada ideia: nome, descricao em 3 frases, por que melhora o jogo, complexidade (P/M/G). Pense em jogos como Vampire Survivors, Hades, Enter the Gungeon como referencia. Foque em ideias que criem MOMENTOS MEMORAVEIS para o jogador."

### Agente 2: Akira (Designer Mechanics)
Prompt: "Voce e Akira, game designer de mecanicas. Leia o context.md em /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/context.md e os arquivos de armas/inimigos. Proponha 5 melhorias MECANICAS concretas: novas armas, novos inimigos, novos sistemas, melhorias de game feel. Para cada: nome, especificacao com numeros exatos, por que melhora o gameplay, complexidade. Foque em depth (profundidade de escolha) e satisfacao do jogador."

### Agente 3: Sakura (Designer Level)
Prompt: "Voce e Sakura, designer de level e pacing. Leia o context.md em /Users/raphaelmardine/programacao/Jogos/godot/samurai-game/context.md e o wave_spawner.gd. Proponha 5 melhorias de EXPERIENCIA: momentos especiais, eventos durante a partida, transicoes entre waves, build-up para bosses, senso de progressao visual. Foque em como cada minuto dos 5 minutos deve SENTIR para o jogador."

## Passo 3: Curadoria
Compile as 15 ideias e:
1. Elimine duplicatas
2. Agrupe ideias complementares
3. Classifique por impacto na experiencia do jogador (1-10)
4. Classifique por viabilidade tecnica (1-10)
5. Crie um TOP 5 recomendado (maior impacto * viabilidade)

## Passo 4: Apresentacao
Apresente ao usuario:
```
## Sessao de Brainstorm - Resultados

### TOP 5 Ideias Recomendadas
1. [Nome] - Impacto: X/10, Viabilidade: X/10
   Descricao e justificativa

### Outras Ideias Interessantes
[Lista resumida das demais]

### Visao de Produto
[Como essas ideias conectam para criar uma experiencia AAA coesa]
```

## Passo 5: Atualize o `context.md`
Adicione as ideias aprovadas na secao de backlog/proximos passos.

## Tema opcional do brainstorm
$ARGUMENTS
