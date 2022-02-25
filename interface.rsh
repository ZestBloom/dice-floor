"reach 0.1";
"use strict";

import { requireTok7 } from "./util.rsh";

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.2 - initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () => [
  Participant("Alice", {
    getParams: Fun(
      [],
      Object({
        tokens: Array(Token, 7),
      })
    ),
  }),
];
export const Views = () => [];
export const Api = () => [
  API({
    touch: Fun([], Null),
  }),
];
export const App = (map) => {
  const [[Alice], _, [a]] = map;
  const {
    tokens: [tok0, tok1, tok2, tok3, tok4, tok5, tok6],
  } = requireTok7(Alice);
  Alice.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
    [1, tok5],
    [1, tok6],
  ]);
  const [as] = parallelReduce([0])
    .invariant(balance() >= 0)
    .while(as <= 6)
    .api(
      a.touch,
      () => assume(true),
      () => 0,
      (k) => {
        require(true)
        k(null)
        if(as == 0) transfer(balance(tok0), tok0).to(Alice);
        else if(as == 1) transfer(balance(tok1), tok1).to(Alice);
        else if(as == 2) transfer(balance(tok2), tok2).to(Alice);
        else if(as == 3) transfer(balance(tok3), tok3).to(Alice);
        else if(as == 4) transfer(balance(tok4), tok4).to(Alice);
        else if(as == 5) transfer(balance(tok5), tok5).to(Alice);
        else if(as == 6) transfer(balance(tok6), tok6).to(Alice);
        return [
          as + 1
        ]
      }
    )
    .timeout(false);
  commit();
  Alice.publish();
  transfer(balance()).to(Alice);
  transfer(balance(tok0), tok0).to(Alice);
  transfer(balance(tok1), tok1).to(Alice);
  transfer(balance(tok2), tok2).to(Alice);
  transfer(balance(tok3), tok3).to(Alice);
  transfer(balance(tok4), tok4).to(Alice);
  transfer(balance(tok5), tok5).to(Alice);
  transfer(balance(tok6), tok6).to(Alice);
  commit();
  exit();
};
// ----------------------------------------------
