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
import gleam/list
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

// Funções do Programa ---------------------------------------------------------------------

// Conversão da lista de textos em uma lista de placares -----------------------------------

/// Retorna uma lista de Placares com base na *lista* de textos da entrada, ou o erro corres-
/// pondente caso não seja possível.
fn cria_lista_placares(lista: List(String)) -> Result(List(Placar), Erro) {
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

/// Converte os itens de *campos* em um Jogo e retorna um Result composto por um Ok com o novo
/// Jogo, ou um Error com o  correspondente.
pub fn converte_para_placar(campos: List(String)) -> Result(Placar, Erro) {
  case campos {
    [] -> Error(CamposInsuficientes)
    [_] -> Error(CamposInsuficientes)
    [_, _] -> Error(CamposInsuficientes)
    [_, _, _] -> Error(CamposInsuficientes)
    [_, _, _, _, _, ..] -> Error(CamposExcessivos)
    [anf, gols_anf, vis, gols_vis] ->
      case int.parse(gols_anf), int.parse(gols_vis) {
        Error(_), _ -> Error(FormatoGolsInvalido)
        _, Error(_) -> Error(FormatoGolsInvalido)
        Ok(gols_anf_ok), Ok(gols_vis_ok) ->
          case gols(gols_anf_ok), gols(gols_vis_ok) {
            Error(erro), _ -> Error(erro)
            _, Error(erro) -> Error(erro)
            Ok(gols_anf_tad), Ok(gols_vis_tad) ->
              Ok(Placar(anf, gols_anf_tad, vis, gols_vis_tad))
          }
      }
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
/// um placar possuem mesmo nome ou se um time anfitrião recebe um time visitante mais de uma
/// vez presente, retornando um Result composto por um Ok com os *placares*, ou um Error com
/// o Erro correspondente.
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
  todo
}

pub fn calcula_desempenhos_() {
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
      Desempenho("Criciuma", 3, 1, -2),
      Desempenho("Goias", 0, 0, -2),
      Desempenho("Vitoria", 0, 0, -1),
      Desempenho("Gremio", 3, 1, 1),
    ],
  )
  check.eq(
    calcula_desempenhos([
      Placar("Flamengo", Gols(0), "AthleticoPR", Gols(1)),
      Placar("Paicandu", Gols(0), "Chapecoense", Gols(0)),
      Placar("Vasco", Gols(0), "Flamengo", Gols(1)),
    ]),
    [
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("AthleticoPR", 3, 1, 1),
      Desempenho("Paicandu", 1, 0, 0),
      Desempenho("Chapecoense", 1, 0, 0),
      Desempenho("Vasco", 0, 0, -1),
    ],
  )
}

/// Retorna uma lista composta por dois Desempenhos com base no *placar* e dos times presentes.
pub fn calcula_desempenho(placar: Placar) -> List(Desempenho) {
  todo
}

pub fn calcula_desempenho_() {
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

// Ordenação dos desempenhos ----------------------------------------------------------------








/// Lista de Placares:
/// Placar("Maringa", Gols(1), "BotaFogo", Gols(3)), Placar("Flamengo", Gols(0), "AthleticoPR", Gols(1)), Placar("Vasco", Gols(2), "Internacional", Gols(0)),
/// Placar("Gremio", Gols(2), "Cruzeiro", Gols(5)), Placar("Goias", Gols(1), "AtleticoMG", Gols(0)), Placar("Sport", Gols(0), "AtleticoGO", Gols(0)),  
/// Placar("Coritiba", Gols(1), "Fluminense", Gols(1)), Placar("Fortaleza", Gols(3), "Bahia", Gols(2)), Placar("Corinthians", Gols(4), "SaoPaulo", Gols(1)), 
/// Placar("Vitoria", Gols(2), "Chapecoense", Gols(1)), Placar("Paicandu", Gols(1), "Londrina", Gols(2)), Placar("Juventude", Gols(2), "Criciuma", Gols(2)), 
/// Placar("SaoPaulo", Gols(1), "Palmeiras", Gols(0)), Placar("AthleticoPR", Gols(3), "Santos", Gols(0)), Placar("Palmeiras", Gols(3), "Internacional", Gols(3)),
/// Placar("AtleticoGO", Gols(2), "Juventude", Gols(4)), Placar("Paicandu", Gols(0), "Chapecoense", Gols(0)), Placar("Sport", Gols(2), "Cruzeiro", Gols(1)),  
/// Placar("Cuiaba", Gols(4), "Corinthians", Gols(0)), Placar("Santos", Gols(1), "Maringa", Gols(5)), Placar("Cuiaba", Gols(2), "Bahia", Gols(2)), 
/// Placar("Vasco", Gols(0), "Flamengo", Gols(1)), Placar("Fortaleza", Gols(2), "Fluminense", Gols(2)), Placar("BotaFogo", Gols(1), "Coritiba", Gols(3))
/// Placar("AtleticoMG", Gols(1), "Londrina", Gols(0)), Placar("Criciuma", Gols(2), "Goias", Gols(0)), Placar("Vitoria", Gols(2), "Gremio", Gols(3)), 
