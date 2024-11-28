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

/// Representa o placar de um jogo realizado.
pub type Placar {
  Placar(
    anfitriao: String,
    gols_anfitriao: Gols,
    visitante: String,
    gols_visitante: Gols,
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

// Funções do Programa

// [lista de strings]

/// Retorna uma lista de Jogos com base na *lista* de textos da entrada, ou um erro caso não
/// seja possível.
/// Separa o *texto* de entrada em diferentes elementos de acordo com os espaços presentes e
/// coloca-os em uma lista.
// para cada string em [listaErro de strings]
// [lista dos elementos de cada string]

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
