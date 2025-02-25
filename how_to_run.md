## Multiplier32FP

- Autor: Walber Florencio
- CI Inovador - Polo UFC
- Última modificação: 25/02/2025


## Descrição
Este projeto implementa um multiplicador de 32 bits em ponto flutuante, como Projeto Final da disciplina Projeto Físico

## Requisitos
- Xcelium 24.09
- Genus 21.10
- Innovus 21.15

## Execução

1. Navegue até o diretório `scripts` onde está o run_first
    ```
    cd backend/synthesis/scripts
    ```

2. Execute o arquivo run_first
    ```
    ./run_first.sh
    ```

3. Escolha a frequência de operação (MIN: 10MHz, MAX: 110MHz)

4. Escolha qual software executar: (x)celium, (g)enus ou (i)nnovus

    - Para gerar os .vcd pela primeira vez é necessário rodar o xcelium no modo RTL
    - Caso escolha xcelium, aparecerão novas opções:

        - Escolher a opção `run all` apenas se já tiver os vcd e sdf criados
        - A opção `full time` significa executar metade do tempo em inatividade após ler os 100 vetores de teste
        - A opção `active` significa executar apenas durante o tempo de leitura dos 100 vetores de teste
        - Escolha entre os modos rtl, synthesis, synthesis com sdf pré-layout, e synthesis com sdf pós-layout
            - Para escolher as sínteses pré-layout, precisa ter executado o Genus
            - Para escolher as sínteses pós-layout, precisa ter executado o Innovus
        - Em seguida, escolha entre abrir ou não a interface gráfica (gui)

    - As opções Genus e Innovus executam diretamente

5. Observe a execução e verifique os resultados

