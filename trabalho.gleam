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

import sgleam/check

/// Conjunto dos possíveis erros a serem identificados no programa.
pub type Erros {
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
fn gols(num: Int) -> Result(Gols, Erros) {
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
fn valor_gols(gols: Gols) -> Int {
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
  Desempenho(nome_time: String, numero_pontos: Int, numero_vitorias: Int, saldo_gols: Int)
}