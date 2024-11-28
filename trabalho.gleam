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

/// Representa a pontuação de um time em um jogo realizado.
pub type Pontuacao {
  Pontuacao(nome_time: String, numero_gols: Gols)
}

/// Representa um jogo realizado.
pub type Jogo {
  Jogo(pontuacao_anfitriao: Pontuacao, pontuacao_visitante: Pontuacao)
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

// Funções do Programa

// [lista de strings]

/// Retorna uma lista de Jogos com base na *lista* de textos da entrada, ou um erro caso não
/// seja possível.
fn cria_lista_jogos(lista: List(String)) -> Result(List(Jogo), Erro) {
  case lista {
    [] -> Ok([])
    [primeiro, ..resto] -> {
      case converte_para_jogo(primeiro.split()) {
        Error(erro) -> Error(erro)
        Ok(jogo) -> {
          case cria_lista_jogos(resto) {
            Error(erro) -> Error(erro)
            Ok(resto_jogos) -> jogo <> resto_jogos
          }
        }
      }
    }
  }
}

pub fn cria_lista_jogos_examples() {
  check.eq(cria_lista_jogos([]), OK([]))
  check.eq(cria_lista_jogos([""]), Erro(CamposInsuficientes))
  check.eq(
    cria_lista_jogos(["Sao-Paulo 2 Palmeiras 1 Corinthians"]),
    Erro(CamposExcessivos),
  )
  check.eq(
    cria_lista_jogos(["Sao-Paulo -2 Palmeiras 1"]),
    Erro(NumeroGolsNegativo),
  )
  check.eq(
    cria_lista_jogos(["São-Paulo Palmeiras Corinthians Flamengo"]),
    Erro(FormatoGolsInvalido),
  )
  check.eq(cria_lista_jogos(["Palmeiras 2 Palmeiras 3"]), Erro(TimesNomeIgual))
  check.eq(
    cria_lista_jogos(["Sao-Paulo 2 Palmeiras 1", "Sao-Paulo 1 Palmeiras 3"]),
    Erro(JogosEmExcesso),
  )
  check.eq(cria_lista_jogos(["Sao-Paulo 2 Palmeiras 1"]), [
    Result(Jogo(
      Pontuacao("Sao-Paulo", Gols(2)),
      Pontuacao("Palmeiras", Gols(1)),
    )),
  ])
  check.eq(
    cria_lista_jogos([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Result([
      Jogo(Pontuacao("Sao-Paulo", Gols(1)), Pontuacao("Atletico-MG", Gols(2))),
      Jogo(Pontuacao("Flamengo", Gols(2)), Pontuacao("Palmeiras", Gols(1))),
      Jogo(Pontuacao("Palmeiras", Gols(0)), Pontuacao("Sao-Paulo", Gols(0))),
      Jogo(Pontuacao("Atletico-MG", Gols(1)), Pontuacao("Flamengo", Gols(2))),
    ]),
  )
}
/// Separa o *texto* de entrada em diferentes elementos de acordo com os espaços presentes e
/// coloca-os em uma lista.
/// Converte os itens da *lista* de entrada em um Jogo e retorna ele. Caso a *lista* não possa
/// ser representada dessa forma, isto é, possui um número inválido de campos ou inconsistência
/// nos dados, retorna um erro.
// para cada string em [lista de strings]
// [lista dos elementos de cada string]

// [lista de Jogos]
