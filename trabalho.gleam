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
type Erros {
  Campos_Excessivos
  Campos_Insuficientes
  Numero_Gols_Negativo
  Formato_Gols_Invalido
  Times_Nome_Igual
  Jogos_Em_Excesso
}

/// Representa um número de gols.
opaque type Gols {
  Gols(numero_gols: Int)
}
/// Devolve Ok(Gols) com o valor de *num* se *num* for maior ou igual a zero, ou Error(
/// Numero_Gols_Negativo) caso contrário.
fn gols(num: Int) -> Result(Gols, Erros) {
  case num >= 0 {
    True -> Ok(Gols(num))
    False -> Error(Erros(Numero_Gols_Negativo))
  }
}
/// Devolve o valor em *gols*.
fn valor_gols(gols: Gols) -> Int {
  gols.numero_gols
}

/// Representa a pontuação de um time em um jogo realizado.
type Pontuacao {
  Pontuacao(nome_time: String, numero_gols: Gols)
}

/// Representa um jogo realizado.
type Jogo {
  Jogo(pontuacao_anfitriao: Pontuacao, pontuacao_visitante: Pontuacao)
}

/// Representa um desempenho de um time no Campeonato.
type Desempenho {
  Desempenho(nome_time: String, numero_pontos: Int, numero_vitorias: Int, saldo_gols: Int)
}