"reach 0.1";
"use strict";

import { requireTok7, hasSignal } from "util.rsh";

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.4 - add view etc
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
  Participant("Bob", {
    ...hasSignal,
  }),
];
export const Views = () => [
  View({
    remaining: UInt,
    tokens: Tuple(Token, Token, Token, Token, Token, Token),
    exchange: Token,
    next: Token,
  }),
];
export const Api = () => [
  API({
    touch: Fun([], Null),
  }),
];

export const App = (map) => {
  const [[Alice, Bob], [v], [a]] = map;
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
  ]);
  v.remaining.set(6);
  v.tokens.set([tok0, tok1, tok2, tok3, tok4, tok5]);
  v.exchange.set(tok6);
  const bs = lastConsensusTime() % 5;
  const [as, next] = parallelReduce([
    0,
    (() => {
      if (0 + bs == 0 + 7 * 0) {
        return tok5;
      } else if (0 + bs == 0 + 7 * 1) {
        return tok4;
      } else if (0 + bs == 0 + 7 * 2) {
        return tok3;
      } else if (0 + bs == 0 + 7 * 3) {
        return tok2;
      } else {
        return tok6;
      }
    })(),
  ])
    .define(() => {
      v.remaining.set(6 - as);
      v.next.set(next);
    })
    .invariant(balance() >= 0)
    .while(as < 6)
    .api(
      a.touch,
      () => assume(true),
      () => [0, [1, tok6]],
      (k) => {
        require(true);
        k(null);
        return [
          as + 1,
          (() => {
            if (as + bs == 0 + 7 * 0) {
              return tok5;
            } else if (as + bs == 1 + 7 * 0) {
              transfer(balance(tok5), tok5).to(this);
              transfer(1, tok6).to(Alice);
              return tok3;
            } else if (as + bs == 2 + 7 * 0) {
              transfer(balance(tok3), tok3).to(this);
              transfer(1, tok6).to(Alice);
              return tok4;
            } else if (as + bs == 3 + 7 * 0) {
              transfer(balance(tok4), tok4).to(this);
              transfer(1, tok6).to(Alice);
              return tok2;
            } else if (as + bs == 4 + 7 * 0) {
              transfer(balance(tok2), tok2).to(this);
              transfer(1, tok6).to(Alice);
              return tok0;
            } else if (as + bs == 5 + 7 * 0) {
              transfer(balance(tok0), tok0).to(this);
              transfer(1, tok6).to(Alice);
              return tok2;
            } else if (as + bs == 0 + 7 * 1) {
              transfer(balance(tok2), tok2).to(this);
              transfer(1, tok6).to(Alice);
              return tok4;
            } else if (as + bs == 1 + 7 * 1) {
              transfer(balance(tok4), tok4).to(this);
              transfer(1, tok6).to(Alice);
              return tok0;
            } else if (as + bs == 2 + 7 * 1) {
              transfer(balance(tok0), tok0).to(this);
              transfer(1, tok6).to(Alice);
              return tok5;
            } else if (as + bs == 3 + 7 * 1) {
              transfer(balance(tok5), tok5).to(this);
              transfer(1, tok6).to(Alice);
              return tok1;
            } else if (as + bs == 4 + 7 * 1) {
              transfer(balance(tok1), tok1).to(this);
              transfer(1, tok6).to(Alice);
              return tok3;
            } else if (as + bs == 5 + 7 * 1) {
              transfer(balance(tok3), tok3).to(this);
              transfer(1, tok6).to(Alice);
              return tok0;
            } else if (as + bs == 0 + 7 * 2) {
              transfer(balance(tok0), tok0).to(this);
              transfer(1, tok6).to(Alice);
              return tok3;
            } else if (as + bs == 1 + 7 * 2) {
              transfer(balance(tok3), tok3).to(this);
              transfer(1, tok6).to(Alice);
              return tok1;
            } else if (as + bs == 2 + 7 * 2) {
              transfer(balance(tok1), tok1).to(this);
              transfer(1, tok6).to(Alice);
              return tok2;
            } else if (as + bs == 3 + 7 * 2) {
              transfer(balance(tok2), tok2).to(this);
              transfer(1, tok6).to(Alice);
              return tok5;
            } else if (as + bs == 4 + 7 * 2) {
              transfer(balance(tok5), tok5).to(this);
              transfer(1, tok6).to(Alice);
              return tok4;
            } else if (as + bs == 5 + 7 * 2) {
              transfer(balance(tok4), tok4).to(this);
              transfer(1, tok6).to(Alice);
              return tok0;
            } else if (as + bs == 0 + 7 * 3) {
              transfer(balance(tok0), tok0).to(this);
              transfer(1, tok6).to(Alice);
              return tok2;
            } else if (as + bs == 1 + 7 * 3) {
              transfer(balance(tok2), tok2).to(this);
              transfer(1, tok6).to(Alice);
              return tok5;
            } else if (as + bs == 2 + 7 * 3) {
              transfer(balance(tok5), tok5).to(this);
              transfer(1, tok6).to(Alice);
              return tok3;
            } else if (as + bs == 3 + 7 * 3) {
              transfer(balance(tok3), tok3).to(this);
              transfer(1, tok6).to(Alice);
              return tok4;
            } else if (as + bs == 4 + 7 * 3) {
              transfer(balance(tok4), tok4).to(this);
              transfer(1, tok6).to(Alice);
              return tok1;
            } else if (as + bs == 5 + 7 * 3) {
              transfer(balance(tok1), tok1).to(this);
              transfer(1, tok6).to(Alice);
              return tok0;
            } else {
              return tok6;
            }
          })(),
        ];
      }
    )
    .timeout(false);
  commit();
  Bob.publish();
  Bob.only(() => interact.signal());
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
