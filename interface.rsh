"reach 0.1";
"use strict";

import { requireTok6 } from "./util.rsh";

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.2 - use 6 tokens
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () => [
  Participant("Alice", {
    getParams: Fun(
      [],
      Object({
        tokens: Array(Token, 6),
      })
    ),
  }),
  Participant("Bob", {})
];
export const Views = () => [];
export const Api = () => [
  API({
    touch: Fun([], Null),
  }),
];
export const App = (map) => {
  const [[Alice, Bob], _, [a]] = map;
  const {
    tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
  } = requireTok6(Alice);
  Alice.pay([
    0,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
    [1, tok5],
  ]);
  const bs = lastConsensusTime() % 6;
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
        if(as + bs == 0 + 7 * 0) transfer(balance(tok0), tok0).to(this);
        else if(as + bs == 1 + 7 * 0) transfer(balance(tok1), tok1).to(this);
        else if(as + bs == 2 + 7 * 0) transfer(balance(tok4), tok4).to(this);
        else if(as + bs == 3 + 7 * 0) transfer(balance(tok5), tok5).to(this);
        else if(as + bs == 4 + 7 * 0) transfer(balance(tok3), tok3).to(this);
        else if(as + bs == 5 + 7 * 0) transfer(balance(tok2), tok2).to(this);
        else if(as + bs == 0 + 7 * 1) transfer(balance(tok1), tok1).to(this);
        else if(as + bs == 1 + 7 * 1) transfer(balance(tok4), tok4).to(this);
        else if(as + bs == 2 + 7 * 1) transfer(balance(tok3), tok3).to(this);
        else if(as + bs == 3 + 7 * 1) transfer(balance(tok0), tok0).to(this);
        else if(as + bs == 4 + 7 * 1) transfer(balance(tok2), tok2).to(this);
        else if(as + bs == 5 + 7 * 1) transfer(balance(tok5), tok5).to(this);
        else if(as + bs == 0 + 7 * 2) transfer(balance(tok2), tok2).to(this);
        else if(as + bs == 1 + 7 * 2) transfer(balance(tok5), tok5).to(this);
        else if(as + bs == 2 + 7 * 2) transfer(balance(tok3), tok3).to(this);
        else if(as + bs == 3 + 7 * 2) transfer(balance(tok0), tok0).to(this);
        else if(as + bs == 4 + 7 * 2) transfer(balance(tok4), tok4).to(this);
        else if(as + bs == 5 + 7 * 2) transfer(balance(tok1), tok1).to(this);
        else if(as + bs == 0 + 7 * 3) transfer(balance(tok2), tok2).to(this);
        else if(as + bs == 1 + 7 * 3) transfer(balance(tok3), tok3).to(this);
        else if(as + bs == 2 + 7 * 3) transfer(balance(tok0), tok0).to(this);
        else if(as + bs == 3 + 7 * 3) transfer(balance(tok1), tok1).to(this);
        else if(as + bs == 4 + 7 * 3) transfer(balance(tok5), tok5).to(this);
        else if(as + bs == 5 + 7 * 3) transfer(balance(tok4), tok4).to(this);
        else if(as + bs == 0 + 7 * 4) transfer(balance(tok3), tok3).to(this);
        else if(as + bs == 1 + 7 * 4) transfer(balance(tok1), tok1).to(this);
        else if(as + bs == 2 + 7 * 4) transfer(balance(tok4), tok4).to(this);
        else if(as + bs == 3 + 7 * 4) transfer(balance(tok2), tok2).to(this);
        else if(as + bs == 4 + 7 * 4) transfer(balance(tok0), tok0).to(this);
        else if(as + bs == 5 + 7 * 4) transfer(balance(tok5), tok5).to(this);
        else if(as + bs == 0 + 7 * 5) transfer(balance(tok2), tok2).to(this);
        else if(as + bs == 1 + 7 * 5) transfer(balance(tok1), tok1).to(this);
        else if(as + bs == 2 + 7 * 5) transfer(balance(tok5), tok5).to(this);
        else if(as + bs == 3 + 7 * 5) transfer(balance(tok4), tok4).to(this);
        else if(as + bs == 4 + 7 * 5) transfer(balance(tok0), tok0).to(this);
        else if(as + bs == 5 + 7 * 5) transfer(balance(tok3), tok3).to(this);
        return [
          as + 1,
        ]
      }
    )
    .timeout(false);
  commit();
  Bob.publish();
  transfer(balance()).to(Alice);
  transfer(balance(tok0), tok0).to(Alice);
  transfer(balance(tok1), tok1).to(Alice);
  transfer(balance(tok2), tok2).to(Alice);
  transfer(balance(tok3), tok3).to(Alice);
  transfer(balance(tok4), tok4).to(Alice);
  transfer(balance(tok5), tok5).to(Alice);
  commit();
  exit();
};
// ----------------------------------------------
