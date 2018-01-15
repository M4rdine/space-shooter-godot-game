# /sprint - Ciclo Completo de Sprint

Voce vai executar um ciclo completo de sprint para o projeto. Isso envolve 5 fases sequenciais, simulando um mini-scrum.

## FASE 1: CONTEXTO E PLANEJAMENTO (PM - Takeshi)

1. Leia o `context.md` completo
2. Leia os arquivos-chave do projeto para entender o estado real (game.gd, wave_spawner.gd, weapon_manager.gd, etc.)
3. Analise:
   - O que foi feito ate agora
   - Bugs conhecidos
   - Features pendentes
   - Qualidade geral do codigo e do jogo
4. Use a ferramenta Task para lancar em PARALELO:
   - **Agente Akira (Designer Mechanics)**: Analisar balanceamento atual e propor melhorias com numeros concretos
   - **Agente Sakura (Designer Level)**: Analisar composicao de waves e propor melhorias de pacing
   - **Agente Ren (Writer)**: Brainstorm de 3-5 ideias de features/melhorias que elevariam a qualidade do jogo

## FASE 2: PRIORIZACAO (PM - Takeshi)

Com os inputs dos designers e do writer:
1. Compile todas as propostas
2. Priorize em backlog:
   - **P0**: Bugs criticos e problemas que quebram o jogo
   - **P1**: Melhorias que mais impactam a qualidade
   - **P2**: Polish e nice-to-have
3. Selecione os TOP 3 itens para esta sprint (foco e entrega > quantidade)
4. Apresente o plano ao usuario e PECA APROVACAO antes de prosseguir

## FASE 3: DESENVOLVIMENTO

Apos aprovacao do usuario, use a ferramenta Task para lancar os devs:
- **Kenji (Gameplay)**: Tarefas de mecanica, combate, inimigos, armas
- **Yuki (UI)**: Tarefas de interface, visuais, feedback
- **Ryu (Systems)**: Tarefas de arquitetura, sistemas, state

Regras para os devs:
- DEVEM ler os arquivos antes de editar
- DEVEM usar _draw() procedural para visuais (nao sprite sheets como textura direta)
- DEVEM respeitar as convencoes do projeto (signals, grupos, collision layers)
- DEVEM testar mentalmente edge cases (pause, restart, boss ativo, timer zero)
- Lance devs em PARALELO quando trabalham em arquivos diferentes

## FASE 4: QA (Hiro)

Apos os devs completarem, lance o agente QA:
- Revisar TODOS os arquivos modificados na sprint
- Verificar: null checks, queue_free, signals, estado no restart, collision layers
- Verificar que sprite sheets NAO estao sendo usadas como textura inteira
- Produzir relatorio de bugs com severidade
- Se encontrar bugs P0: corrija imediatamente (ou delegue ao dev responsavel)

## FASE 5: ENTREGA E DOCUMENTACAO

1. Compile tudo que foi feito
2. Atualize o `context.md` com:
   - Mudancas feitas nesta sprint
   - Bugs encontrados e corrigidos
   - Decisoes de design tomadas
   - Ideias do backlog para futuro
3. Apresente ao usuario:
   - Resumo da sprint
   - O que foi entregue
   - O que ficou para proxima sprint
   - Estado geral do projeto e proximo passo rumo a qualidade AAA

## Parametros dos Agentes (system prompts para Task tool)

### Para Designers/Writer (pesquisa e documentos, NAO codigo):
- subagent_type: "Explore" ou "general-purpose"
- Devem ler context.md + arquivos relevantes
- Output: propostas com numeros concretos e justificativas

### Para Devs (implementacao):
- subagent_type: "general-purpose"
- Devem ler context.md + arquivos que vao modificar
- Output: codigo implementado via Edit/Write tools

### Para QA (validacao):
- subagent_type: "general-purpose"
- Deve ler context.md + todos arquivos modificados
- Output: relatorio estruturado de bugs

## Regras Criticas
- SEMPRE peca aprovacao do usuario na Fase 2 antes de implementar
- SEMPRE atualize context.md ao final
- Foco em QUALIDADE sobre quantidade - melhor 2 coisas bem feitas que 5 meia-boca
- Objetivo de longo prazo: jogo qualidade AAA
- Cada sprint deve deixar o jogo mensuravel e visivelmente melhor

## Argumento opcional (foco da sprint)
$ARGUMENTS
