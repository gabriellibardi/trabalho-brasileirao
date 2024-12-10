// Trabalho 01 - Classificação no Brasileirão
// Alunos: Gabriel Libardi Lulu (134728) e Vitor da Rocha Machado (132769)

// Lista de coisas a fazer:
// - Exemplos do tipo Gols

// Análise
//
// Implementar um programa com a função de classificar a pontuação de diferentes times
// do Campeonato Brasileiro de Futebol, a partir de um texto de entrada constituído pe-
// las pontuações dos jogos individuais.
//
// O texto é composto por linhas na forma:
//      Time_Anfitrião Num_de_gols_do_anfitrião Time_Visitante Num_de_gols_do_visitante
//
// O nome dos times não pode possuir espaços, os números de gols devem ser naturais e
// dois times diferentes se enfrentam no máximo duas vezes: na ida e na volta.
//
// Ao fim, o programa retorna um texto na forma de tabela com a classificação dos times
// a partir de seus desempenhos, medidos pelo número de pontos. Os pontos são calculados
// da seguinte forma: vitórias geram 3 pontos, empates geram 1 ponto e derrotas não ge-
// ram pontos. Como critério de desempate, é utilizado hierarquicamente o númeroo de vi-
// tórias, seguido pelo saldo de gols (número de gols feitos menos o número de gols so-
// fridos) e, por fim, a ordem alfabética dos nomes dos times (todas essas informações 
// são dispostas na tabela, que é ordenada a partir desses critérios).

import gleam/int
import gleam/order.{Lt}
import gleam/string
import sgleam/check

// Tipos de dados

/// Conjunto dos possíveis erros a serem identificados no programa.
pub type Erro {
  CamposExcessivos
  CamposInsuficientes
  NumeroGolsNegativo
  FormatoGolsInvalido
  TimesNomeIgual
  JogosEmExcesso
}

/// Representa um número de gols.
pub opaque type Gols {
  Gols(numero_gols: Int)
}

/// Devolve Ok(Gols) com o valor de *num* se *num* for maior ou igual a zero, ou Error(
/// Numero_Gols_Negativo) caso contrário.
pub fn gols(num: Int) -> Result(Gols, Erro) {
  case num >= 0 {
    True -> Ok(Gols(num))
    False -> Error(NumeroGolsNegativo)
  }
}

pub fn gols_examples() {
  check.eq(gols(-1), Error(NumeroGolsNegativo))
  check.eq(gols(0), Ok(Gols(0)))
  check.eq(gols(1), Ok(Gols(1)))
  check.eq(gols(5), Ok(Gols(5)))
}

/// Devolve o valor em *gols*.
pub fn valor_gols(gols: Gols) -> Int {
  gols.numero_gols
}

pub fn valor_gols_examples() {
  check.eq(valor_gols(Gols(0)), 0)
  check.eq(valor_gols(Gols(2)), 2)
  check.eq(valor_gols(Gols(3)), 3)
}

/// Representa um placar de um jogo realizado.
pub type Placar {
  Placar(
    nome_time_anf: String,
    gols_anf: Gols,
    nome_time_vis: String,
    gols_vis: Gols,
  )
}

/// Representa um desempenho de um time no Campeonato.
pub type Desempenho {
  Desempenho(
    nome_time: String,
    numero_pontos: Int,
    numero_vitorias: Int,
    saldo_gols: Int,
  )
}

// Funções do Programa --------------------------------------------------------------------- ---------------------------------------------------------------------

// Função principal do programa
pub fn main(lista: List(String)) -> Result(List(String), Erro) {
  case cria_lista_placares(lista) {
    Error(erro) -> Error(erro)
    Ok(lista_placares) ->
      case verifica_placares(lista_placares) {
        Error(erro) -> Error(erro)
        Ok(lista_verificada) ->
          Ok(
            converte_desempenhos_string(
              ordena_desempenhos(calcula_desempenhos(lista_verificada)),
            ),
          )
      }
  }
}

pub fn main_examples() {
  check.eq(main([]), Ok([]))
  check.eq(main([""]), Error(CamposInsuficientes))
  check.eq(main(["Palmeiras 2 Corinthians"]), Error(CamposInsuficientes))
  check.eq(
    main(["Bahia 2 Vasco 3", "Flamengo 0 Vasco 0 3"]),
    Error(CamposExcessivos),
  )
  check.eq(
    main(["Maringa 2 Cuiaba 3", "Santos 0 Vasco 0", "Fluminense 3 Bahia -2"]),
    Error(NumeroGolsNegativo),
  )
  check.eq(
    main([
      "Vasco 2 Cruzeiro 3", "Flamengo zero Juventus 0", "Fluminense 3 Bahia 2",
    ]),
    Error(FormatoGolsInvalido),
  )
  check.eq(
    main([
      "Gremio 2 Bragantino 3", "Flamengo 0 Juventude 0",
      "Fluminense 3 Fluminense 2",
    ]),
    Error(TimesNomeIgual),
  )
  check.eq(
    main([
      "Vitoria 2 Corinthians 3", "Flamengo 0 Vasco 0", "Vitoria 3 Corinthians 2",
    ]),
    Error(JogosEmExcesso),
  )
  check.eq(
    main([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Ok([
      "Flamengo 6 2 2", "Atletico-MG 3 1 0", "Palmeiras 1 0 -1",
      "Sao-Paulo 1 0 -1",
    ]),
  )
  check.eq(
    main(["Flamengo 3 Criciuma 4"]),
    Ok(["Criciuma 3 1 1", "Flamengo 0 0 -1"]),
  )
  check.eq(
    main(["Maringa 2 Londrina 1"]),
    Ok(["Maringa 3 1 1", "Londrina 0 0 -1"]),
  )
  check.eq(main(["Sport 0 Bahia 0"]), Ok(["Bahia 1 0 0", "Sport 1 0 0"]))
  check.eq(
    main(["AthleticoPR 2 AtleticoGO 1", "Palmeiras 0 Corinthians 3"]),
    Ok([
      "Corinthians 3 1 3", "AthleticoPR 3 1 1", "AtleticoGO 0 0 -1",
      "Palmeiras 0 0 -3",
    ]),
  )
  check.eq(
    main([
      "Vasco 1 Coritiba 2", "BotaFogo 3 Gremio 1", "Coritiba 1 Internacional 0",
    ]),
    Ok([
      "Coritiba 6 2 2", "BotaFogo 3 1 2", "Internacional 0 0 -1", "Vasco 0 0 -1",
      "Gremio 0 0 -2",
    ]),
  )
  check.eq(
    main([
      "Vitoria 3 Fluminense 0", "Fluminense 0 Marialva 0",
      "Marialva 1 Flamengo 1", "Flamengo 2 Marialva 2",
    ]),
    Ok([
      "Vitoria 3 1 3", "Marialva 3 0 0", "Flamengo 2 0 0", "Fluminense 1 0 -3",
    ]),
  )
}

// Conversão da lista de textos em uma lista de placares -----------------------------------

/// Retorna uma lista de Placares com base na *lista* de textos da entrada, ou o Erro corres-
/// pondente caso não seja possível.
pub fn cria_lista_placares(lista: List(String)) -> Result(List(Placar), Erro) {
  case lista {
    [] -> Ok([])
    [primeiro, ..resto] -> {
      case converte_para_placar(string.split(primeiro, " ")) {
        Error(erro) -> Error(erro)
        Ok(placar) -> {
          case cria_lista_placares(resto) {
            Error(erro) -> Error(erro)
            Ok(resto_placares) -> Ok([placar, ..resto_placares])
          }
        }
      }
    }
  }
}

pub fn cria_lista_placares_examples() {
  check.eq(cria_lista_placares([]), Ok([]))
  check.eq(cria_lista_placares([""]), Error(CamposInsuficientes))
  check.eq(
    cria_lista_placares(["Sao-Paulo 2 Palmeiras 1 Corinthians"]),
    Error(CamposExcessivos),
  )
  check.eq(
    cria_lista_placares(["Sao-Paulo -2 Palmeiras 1"]),
    Error(NumeroGolsNegativo),
  )
  check.eq(
    cria_lista_placares(["São-Paulo Palmeiras Corinthians Flamengo"]),
    Error(FormatoGolsInvalido),
  )
  check.eq(
    cria_lista_placares(["Sao-Paulo 2 Palmeiras 1"]),
    Ok([Placar("Sao-Paulo", Gols(2), "Palmeiras", Gols(1))]),
  )
  check.eq(
    cria_lista_placares([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Ok([
      Placar("Sao-Paulo", Gols(1), "Atletico-MG", Gols(2)),
      Placar("Flamengo", Gols(2), "Palmeiras", Gols(1)),
      Placar("Palmeiras", Gols(0), "Sao-Paulo", Gols(0)),
      Placar("Atletico-MG", Gols(1), "Flamengo", Gols(2)),
    ]),
  )
}

/// Retorna um Placar com base na *lista* de textos da entrada, ou o Erro correspondente.
pub fn converte_para_placar(campos: List(String)) -> Result(Placar, Erro) {
  case campos {
    [anf, gols_anf, vis, gols_vis] ->
      case int.parse(gols_anf), int.parse(gols_vis) {
        Ok(gols_anf_ok), Ok(gols_vis_ok) ->
          case gols(gols_anf_ok), gols(gols_vis_ok) {
            Ok(gols_anf_tad), Ok(gols_vis_tad) ->
              Ok(Placar(anf, gols_anf_tad, vis, gols_vis_tad))
            _, _ -> Error(NumeroGolsNegativo)
          }
        _, _ -> Error(FormatoGolsInvalido)
      }
    [_, _, _, _, _, ..] -> Error(CamposExcessivos)
    _ -> Error(CamposInsuficientes)
  }
}

pub fn converte_para_placar_examples() {
  check.eq(converte_para_placar([]), Error(CamposInsuficientes))
  check.eq(converte_para_placar(["Fortaleza"]), Error(CamposInsuficientes))
  check.eq(converte_para_placar(["Palmeiras", "0"]), Error(CamposInsuficientes))
  check.eq(
    converte_para_placar(["Flamengo", "3", "Santos"]),
    Error(CamposInsuficientes),
  )
  check.eq(
    converte_para_placar(["Corinthians", "1", "Coritiba", "3", "BotaFogo"]),
    Error(CamposExcessivos),
  )
  check.eq(
    converte_para_placar(["SaoPaulo", "dois", "Palmeiras", "3"]),
    Error(FormatoGolsInvalido),
  )
  check.eq(
    converte_para_placar(["Fortaleza", "-4", "Internacional", "0"]),
    Error(NumeroGolsNegativo),
  )
  check.eq(
    converte_para_placar(["Criciuma", "1", "Fluminense", "3"]),
    Ok(Placar("Criciuma", Gols(1), "Fluminense", Gols(3))),
  )
  check.eq(
    converte_para_placar(["Vasco", "0", "Maringa", "2"]),
    Ok(Placar("Vasco", Gols(0), "Maringa", Gols(2))),
  )
}

// Verificação dos placares -----------------------------------------------------------------

/// Verifica se uma lista de *placares* possui alguma inconsistência, isto é, se os times de
/// um placar possuem mesmo nome ou se um time anfitrião recebe um mesmo time visitante mais
/// de uma vez, retornando os mesmos *placares* caso não haja inconsistências ou o Erro cor-
/// respondente.
pub fn verifica_placares(placares: List(Placar)) -> Result(List(Placar), Erro) {
  case placares {
    [] -> Ok([])
    [primeiro, ..resto] ->
      case
        primeiro.nome_time_anf == primeiro.nome_time_vis,
        repete_combinacao_times(primeiro, resto)
      {
        True, _ -> Error(TimesNomeIgual)
        False, True -> Error(JogosEmExcesso)
        False, False ->
          case verifica_placares(resto) {
            Error(erro) -> Error(erro)
            Ok(placares_ok) -> Ok([primeiro, ..placares_ok])
          }
      }
  }
}

pub fn verifica_placares_examples() {
  check.eq(verifica_placares([]), Ok([]))
  check.eq(
    verifica_placares([
      Placar("Coritiba", Gols(1), "Fluminense", Gols(1)),
      Placar("Fortaleza", Gols(3), "Bahia", Gols(2)),
    ]),
    Ok([
      Placar("Coritiba", Gols(1), "Fluminense", Gols(1)),
      Placar("Fortaleza", Gols(3), "Bahia", Gols(2)),
    ]),
  )
  check.eq(
    verifica_placares([
      Placar("Gremio", Gols(2), "Cruzeiro", Gols(5)),
      Placar("Gremio", Gols(1), "Cruzeiro", Gols(0)),
    ]),
    Error(JogosEmExcesso),
  )
  check.eq(
    verifica_placares([
      Placar("AthleticoPR", Gols(3), "Internacional", Gols(0)),
      Placar("Palmeiras", Gols(3), "Palmeiras", Gols(3)),
    ]),
    Error(TimesNomeIgual),
  )
  check.eq(
    verifica_placares([
      Placar("Vasco", Gols(0), "Flamengo", Gols(1)),
      Placar("Fortaleza", Gols(2), "Fluminense", Gols(2)),
    ]),
    Ok([
      Placar("Vasco", Gols(0), "Flamengo", Gols(1)),
      Placar("Fortaleza", Gols(2), "Fluminense", Gols(2)),
    ]),
  )
  check.eq(
    verifica_placares([
      Placar("AtleticoMG", Gols(1), "Londrina", Gols(0)),
      Placar("Criciuma", Gols(2), "Goias", Gols(0)),
      Placar("Vitoria", Gols(2), "Gremio", Gols(3)),
    ]),
    Ok([
      Placar("AtleticoMG", Gols(1), "Londrina", Gols(0)),
      Placar("Criciuma", Gols(2), "Goias", Gols(0)),
      Placar("Vitoria", Gols(2), "Gremio", Gols(3)),
    ]),
  )
}

/// Verifica se a combinação time anfitrião-visitante do *placar* repete na lista de *placares*,
/// retornando True caso repita e False caso não repita.
pub fn repete_combinacao_times(placar: Placar, placares: List(Placar)) -> Bool {
  case placares {
    [] -> False
    [primeiro, ..resto] ->
      {
        placar.nome_time_anf == primeiro.nome_time_anf
        && placar.nome_time_vis == primeiro.nome_time_vis
      }
      || repete_combinacao_times(placar, resto)
  }
}

pub fn repete_combinacao_times_examples() {
  check.eq(
    repete_combinacao_times(
      Placar("AtleticoMG", Gols(1), "Londrina", Gols(0)),
      [],
    ),
    False,
  )
  check.eq(
    repete_combinacao_times(
      Placar("Palmeiras", Gols(3), "Internacional", Gols(3)),
      [Placar("Paicandu", Gols(1), "Londrina", Gols(2))],
    ),
    False,
  )
  check.eq(
    repete_combinacao_times(Placar("Vitoria", Gols(2), "Gremio", Gols(3)), [
      Placar("AtleticoGO", Gols(2), "Juventude", Gols(4)),
      Placar("Vitoria", Gols(0), "Gremio", Gols(0)),
    ]),
    True,
  )
}

// Obtenção dos desempenhos -----------------------------------------------------------------

/// Retorna uma lista de Desempenhos com base nos *placares*.
pub fn calcula_desempenhos(placares: List(Placar)) -> List(Desempenho) {
  case placares {
    [] -> []
    [primeiro, ..resto] ->
      case calcula_desempenho(primeiro) {
        [desempenho_anf, desemepenho_vis] ->
          juncao_desempenhos(
            juncao_desempenhos(calcula_desempenhos(resto), desempenho_anf),
            desemepenho_vis,
          )
        _ -> []
      }
  }
}

pub fn calcula_desempenhos_examples() {
  check.eq(calcula_desempenhos([]), [])
  check.eq(
    calcula_desempenhos([Placar("Palmeiras", Gols(3), "Internacional", Gols(3))]),
    [Desempenho("Palmeiras", 1, 0, 0), Desempenho("Internacional", 1, 0, 0)],
  )
  check.eq(
    calcula_desempenhos([
      Placar("Criciuma", Gols(2), "Goias", Gols(0)),
      Placar("Vitoria", Gols(2), "Gremio", Gols(3)),
    ]),
    [
      Desempenho("Vitoria", 0, 0, -1),
      Desempenho("Gremio", 3, 1, 1),
      Desempenho("Criciuma", 3, 1, 2),
      Desempenho("Goias", 0, 0, -2),
    ],
  )
  check.eq(
    calcula_desempenhos([
      Placar("Flamengo", Gols(0), "AthleticoPR", Gols(1)),
      Placar("Paicandu", Gols(0), "Chapecoense", Gols(0)),
      Placar("Vasco", Gols(0), "Flamengo", Gols(1)),
    ]),
    [
      Desempenho("Vasco", 0, 0, -1),
      Desempenho("Flamengo", 3, 1, 0),
      Desempenho("Paicandu", 1, 0, 0),
      Desempenho("Chapecoense", 1, 0, 0),
      Desempenho("AthleticoPR", 3, 1, 1),
    ],
  )
}

/// Retorna uma lista composta por dois Desempenhos com base no *placar* e dos times presentes.
pub fn calcula_desempenho(placar: Placar) -> List(Desempenho) {
  case placar.gols_anf.numero_gols - placar.gols_vis.numero_gols {
    num if num > 0 -> [
      Desempenho(placar.nome_time_anf, 3, 1, num),
      Desempenho(placar.nome_time_vis, 0, 0, -num),
    ]
    num if num < 0 -> [
      Desempenho(placar.nome_time_anf, 0, 0, num),
      Desempenho(placar.nome_time_vis, 3, 1, -num),
    ]
    _ -> [
      Desempenho(placar.nome_time_anf, 1, 0, 0),
      Desempenho(placar.nome_time_vis, 1, 0, 0),
    ]
  }
}

pub fn calcula_desempenho_examples() {
  check.eq(calcula_desempenho(Placar("Sport", Gols(2), "Cruzeiro", Gols(1))), [
    Desempenho("Sport", 3, 1, 1),
    Desempenho("Cruzeiro", 0, 0, -1),
  ])
  check.eq(calcula_desempenho(Placar("Maringa", Gols(1), "BotaFogo", Gols(3))), [
    Desempenho("Maringa", 0, 0, -2),
    Desempenho("BotaFogo", 3, 1, 2),
  ])
  check.eq(calcula_desempenho(Placar("Cuiaba", Gols(2), "Bahia", Gols(2))), [
    Desempenho("Cuiaba", 1, 0, 0),
    Desempenho("Bahia", 1, 0, 0),
  ])
}

/// Retorna a atualização da lista de *desempenhos* a partir de *desempenho*, isto é, atualizando
/// o desempenho do time que já está na lista ou adicionando um novo *desempenho*.
pub fn juncao_desempenhos(
  desempenhos: List(Desempenho),
  desempenho: Desempenho,
) -> List(Desempenho) {
  case desempenhos {
    [] -> [desempenho]
    [primeiro, ..resto] ->
      case primeiro.nome_time == desempenho.nome_time {
        True -> [
          Desempenho(
            primeiro.nome_time,
            primeiro.numero_pontos + desempenho.numero_pontos,
            primeiro.numero_vitorias + desempenho.numero_vitorias,
            primeiro.saldo_gols + desempenho.saldo_gols,
          ),
          ..resto
        ]
        False -> [primeiro, ..juncao_desempenhos(resto, desempenho)]
      }
  }
}

pub fn juncao_desempenhos_examples() {
  check.eq(juncao_desempenhos([], Desempenho("Fluminense", 1, 0, 0)), [
    Desempenho("Fluminense", 1, 0, 0),
  ])
  check.eq(
    juncao_desempenhos(
      [Desempenho("Sport", 4, 1, 3), Desempenho("Coritiba", 0, 0, -3)],
      Desempenho("Santos", 3, 1, 3),
    ),
    [
      Desempenho("Sport", 4, 1, 3),
      Desempenho("Coritiba", 0, 0, -3),
      Desempenho("Santos", 3, 1, 3),
    ],
  )
  check.eq(
    juncao_desempenhos(
      [Desempenho("Flamengo", 0, 0, -1), Desempenho("SaoPaulo", 3, 1, 1)],
      Desempenho("Flamengo", 3, 1, 1),
    ),
    [Desempenho("Flamengo", 3, 1, 0), Desempenho("SaoPaulo", 3, 1, 1)],
  )
  check.eq(
    juncao_desempenhos(
      [
        Desempenho("Palmeiras", 3, 1, 2),
        Desempenho("Londrina", 0, 0, -2),
        Desempenho("Cruzeiro", 0, 0, -3),
        Desempenho("Criciuma", 3, 1, 3),
      ],
      Desempenho("BotaFogo", 3, 1, 2),
    ),
    [
      Desempenho("Palmeiras", 3, 1, 2),
      Desempenho("Londrina", 0, 0, -2),
      Desempenho("Cruzeiro", 0, 0, -3),
      Desempenho("Criciuma", 3, 1, 3),
      Desempenho("BotaFogo", 3, 1, 2),
    ],
  )
  check.eq(
    juncao_desempenhos(
      [
        Desempenho("Goias", 1, 0, 0),
        Desempenho("Internacional", 1, 0, 0),
        Desempenho("AtleticoMG", 3, 1, 2),
        Desempenho("Paicandu", 0, 0, -2),
      ],
      Desempenho("AtleticoMG", 3, 1, 1),
    ),
    [
      Desempenho("Goias", 1, 0, 0),
      Desempenho("Internacional", 1, 0, 0),
      Desempenho("AtleticoMG", 6, 2, 3),
      Desempenho("Paicandu", 0, 0, -2),
    ],
  )
}

// Ordenação dos desempenhos ----------------------------------------------------------------

/// Retorna a *lista_desempenhos* ordenada com base nos desempenhos dos times. Caso dois times
/// empatem, o desempate é feito de forma hierárquica pelo número de vitórias, saldo de gols
/// (número de gols feitos menos o número de gols sofridos) e pela ordem alfabética.
pub fn ordena_desempenhos(
  lista_desempenhos: List(Desempenho),
) -> List(Desempenho) {
  case lista_desempenhos {
    [] -> []
    [primeiro, ..resto] -> insere_ordenado(primeiro, ordena_desempenhos(resto))
  }
}

pub fn ordena_desempenhos_examples() {
  check.eq(ordena_desempenhos([]), [])
  check.eq(
    ordena_desempenhos([
      Desempenho("Sport", 3, 1, 1),
      Desempenho("Cruzeiro", 0, 0, -1),
    ]),
    [Desempenho("Sport", 3, 1, 1), Desempenho("Cruzeiro", 0, 0, -1)],
  )
  check.eq(
    ordena_desempenhos([
      Desempenho("Palmeiras", 0, 0, -2),
      Desempenho("Fortaleza", 3, 1, 3),
    ]),
    [Desempenho("Fortaleza", 3, 1, 3), Desempenho("Palmeiras", 0, 0, -2)],
  )
  check.eq(
    ordena_desempenhos([
      Desempenho("Maringa", 3, 1, 6),
      Desempenho("Botafogo", 0, 0, 4),
      Desempenho("Coritiba", 3, 1, 6),
      Desempenho("Fluminense", 3, 1, 3),
      Desempenho("Bahia", 6, 2, 9),
      Desempenho("Flamengo", 4, 0, 2),
    ]),
    [
      Desempenho("Bahia", 6, 2, 9),
      Desempenho("Flamengo", 4, 0, 2),
      Desempenho("Coritiba", 3, 1, 6),
      Desempenho("Maringa", 3, 1, 6),
      Desempenho("Fluminense", 3, 1, 3),
      Desempenho("Botafogo", 0, 0, 4),
    ],
  )
}

/// Insere *desempenho* no lugar correto da *lista_desempenhos*, isto é, seguindo as seguintes
/// regras de ordenação: número de pontos, número de vitórias, saldo de gols e ordem alfabética.
/// É necessário que *lista_desempenhos* já esteja ordenada.
pub fn insere_ordenado(
  desempenho: Desempenho,
  lista_desempenhos: List(Desempenho),
) -> List(Desempenho) {
  case lista_desempenhos {
    [] -> [desempenho]
    [primeiro, ..resto] ->
      case encontra_melhor(desempenho, primeiro) == desempenho {
        True -> [desempenho, ..lista_desempenhos]
        False -> [primeiro, ..insere_ordenado(desempenho, resto)]
      }
  }
}

pub fn insere_ordenado_examples() {
  check.eq(insere_ordenado(Desempenho("Bahia", 3, 1, 1), []), [
    Desempenho("Bahia", 3, 1, 1),
  ])
  check.eq(
    insere_ordenado(Desempenho("Bahia", 3, 1, 1), [
      Desempenho("Fortaleza", 0, 0, 2),
    ]),
    [Desempenho("Bahia", 3, 1, 1), Desempenho("Fortaleza", 0, 0, 2)],
  )
  check.eq(
    insere_ordenado(Desempenho("Bahia", 3, 1, 1), [
      Desempenho("Palmeiras", 6, 2, 7),
    ]),
    [Desempenho("Palmeiras", 6, 2, 7), Desempenho("Bahia", 3, 1, 1)],
  )
  check.eq(
    insere_ordenado(Desempenho("Maringa", 3, 1, 7), [
      Desempenho("Fluminense", 8, 2, 5),
      Desempenho("São-Paulo", 8, 2, 5),
      Desempenho("Coritiba", 6, 2, 4),
      Desempenho("Fortaleza", 2, 0, 2),
    ]),
    [
      Desempenho("Fluminense", 8, 2, 5),
      Desempenho("São-Paulo", 8, 2, 5),
      Desempenho("Coritiba", 6, 2, 4),
      Desempenho("Maringa", 3, 1, 7),
      Desempenho("Fortaleza", 2, 0, 2),
    ],
  )
}

/// Retorna o desempenho do time que possui um melhor desempenho entre *desempenho1* e *desempe-
/// nho2*, seguindo as ordem de pontuação: número de pontos, número de vitórias, saldo de gols e
/// ordem alfabética.
pub fn encontra_melhor(
  desempenho1: Desempenho,
  desempenho2: Desempenho,
) -> Desempenho {
  case
    { desempenho1.numero_pontos > desempenho2.numero_pontos }
    || {
      desempenho1.numero_pontos == desempenho2.numero_pontos
      && desempenho1.numero_vitorias > desempenho2.numero_vitorias
    }
    || {
      desempenho1.numero_pontos == desempenho2.numero_pontos
      && desempenho1.numero_vitorias == desempenho2.numero_vitorias
      && desempenho1.saldo_gols > desempenho2.saldo_gols
    }
    || {
      desempenho1.numero_pontos == desempenho2.numero_pontos
      && desempenho1.numero_vitorias == desempenho2.numero_vitorias
      && desempenho1.saldo_gols == desempenho2.saldo_gols
      && string.compare(desempenho1.nome_time, desempenho2.nome_time) == Lt
    }
  {
    True -> desempenho1
    False -> desempenho2
  }
}

pub fn encontra_melhor_examples() {
  check.eq(
    encontra_melhor(
      Desempenho("Sport", 3, 1, 1),
      Desempenho("Cruzeiro", 0, 0, -1),
    ),
    Desempenho("Sport", 3, 1, 1),
  )
  check.eq(
    encontra_melhor(
      Desempenho("Cruzeiro", 0, 0, -1),
      Desempenho("Sport", 3, 1, 1),
    ),
    Desempenho("Sport", 3, 1, 1),
  )
  check.eq(
    encontra_melhor(
      Desempenho("Palmeiras", 3, 1, -1),
      Desempenho("Fortaleza", 3, 3, 3),
    ),
    Desempenho("Fortaleza", 3, 3, 3),
  )
  check.eq(
    encontra_melhor(
      Desempenho("Bahia", 0, 0, 1),
      Desempenho("Maringa", 0, 0, -1),
    ),
    Desempenho("Bahia", 0, 0, 1),
  )
  check.eq(
    encontra_melhor(
      Desempenho("Fortaleza", 0, 0, 1),
      Desempenho("Cruzeiro", 0, 0, 1),
    ),
    Desempenho("Cruzeiro", 0, 0, 1),
  )
}

// Conversão da lista de desempenhos para uma de strings ------------------------------------

/// Retorna uma lista de strings composta pela conversão de cada elemento de *desempenhos*, que
/// é feita convertendo os itens de cada desempenho para string e concatenando-os com um espaço
/// entre cada um.
pub fn converte_desempenhos_string(
  desempenhos: List(Desempenho),
) -> List(String) {
  case desempenhos {
    [] -> []
    [primeiro, ..resto] -> [
      primeiro.nome_time
        <> " "
        <> int.to_string(primeiro.numero_pontos)
        <> " "
        <> int.to_string(primeiro.numero_vitorias)
        <> " "
        <> int.to_string(primeiro.saldo_gols),
      ..converte_desempenhos_string(resto)
    ]
  }
}

pub fn converte_desempenhos_string_examples() {
  check.eq(converte_desempenhos_string([]), [])
  check.eq(converte_desempenhos_string([Desempenho("Flamengo", 4, 1, 2)]), [
    "Flamengo 4 1 2",
  ])
  check.eq(
    converte_desempenhos_string([
      Desempenho("Corinthians", 3, 1, 1),
      Desempenho("SaoPaulo", 0, 0, -1),
    ]),
    ["Corinthians 3 1 1", "SaoPaulo 0 0 -1"],
  )
  check.eq(
    converte_desempenhos_string([
      Desempenho("Palmeiras", 6, 2, 3),
      Desempenho("Criciuma", 0, 0, -1),
      Desempenho("Londrina", 0, 0, -2),
    ]),
    ["Palmeiras 6 2 3", "Criciuma 0 0 -1", "Londrina 0 0 -2"],
  )
  check.eq(
    converte_desempenhos_string([
      Desempenho("Bahia", 3, 1, 3),
      Desempenho("Fortaleza", 0, 0, -3),
      Desempenho("AthleticoPR", 1, 0, 0),
      Desempenho("Maringa", 1, 0, 0),
    ]),
    ["Bahia 3 1 3", "Fortaleza 0 0 -3", "AthleticoPR 1 0 0", "Maringa 1 0 0"],
  )
}
