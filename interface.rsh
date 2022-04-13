"reach 0.1";
"use strict";

import { requireTok6WithFloorAddrReward, hasSignal } from "util.rsh";

const T = 6; // TOTAL TOKENS

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.7 - add post deposit signal
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () => [
  Participant("Alice", {
    getParams: Fun(
      [],
      Object({
        price: UInt,
        tokens: Array(Token, T), // 6 tokens + 1 exchange token
        addr: Address,
        reward: UInt,
      })
    ),
    ...hasSignal,
  }),
  Participant("Bob", {
    ...hasSignal,
  }),
];
export const Views = () => [
  View({
    price: UInt,
    remaining: UInt,
    tokens: Tuple(Token, Token, Token, Token, Token, Token),
    next: Token,
  }),
];
export const Api = () => [
  API({
    touch: Fun([], Null),
    ppc: Fun([UInt], Null),
  }),
];

export const App = (map) => {
  const [[Alice, Bob], [v], [a]] = map;
  const {
    tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
    price,
    addr,
    reward
  } = requireTok6WithFloorAddrReward(Alice);
  Alice.pay([
    reward,
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
    [1, tok5],
  ]);
  Alice.interact.signal();
  v.remaining.set(T);
  v.tokens.set([tok0, tok1, tok2, tok3, tok4, tok5]);
  v.price.set(price);
  const bs = lastConsensusSecs() % 4; // XXX
  const [as, next] = parallelReduce([
    0,
    (() => {
      if (bs == 0) {
        return tok1;
      } else if (bs == 1) {
        return tok2;
      } else if (bs == 2) {
        return tok0;
      } else if (bs == 3) {
        return tok0;
      } else {
        // impossible
        return tok0; // XXX 
      }
    })(),
  ])
    .define(() => {
      v.remaining.set(T - as);
      v.next.set(next);
    })
    .invariant(balance() >= reward)
    .while(as < T)
    .api(
      a.ppc,
      (_) => assume(true),
      (m) => m,
      (m, k) => {
        require(true);
        transfer(m).to(addr);
        k(null);
        return [as, next];
      }
    )
    .api(
      a.touch,
      () => assume(true),
      () => price,
      (k) => {
        require(true);
        k(null);
        return [
          as + 1,
          (() => {
            if (as + T * bs == 0 + T * 0) {
              transfer(balance(tok1), tok1).to(this);
              transfer(price).to(Alice);
              return tok5;
            } else if (as + T * bs == 1 + T * 0) {
              transfer(balance(tok5), tok5).to(this);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 2 + T * 0) {
              transfer(balance(tok3), tok3).to(this);
              transfer(price).to(Alice);
              return tok4;
            } else if (as + T * bs == 3 + T * 0) {
              transfer(balance(tok4), tok4).to(this);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 4 + T * 0) {
              transfer(balance(tok2), tok2).to(this);
              transfer(price).to(Alice);
              return tok0; // XXX
            } else if (as + T * bs == 5 + T * 0) {
              transfer(balance(tok0), tok0).to(this);
              transfer(price).to(Alice);
              return tok0;
            } else if (as + T * bs == 0 + T * 1) {
              transfer(balance(tok2), tok2).to(this);
              transfer(price).to(Alice);
              return tok4;
            } else if (as + T * bs == 1 + T * 1) {
              transfer(balance(tok4), tok4).to(this);
              transfer(price).to(Alice);
              return tok0;
            } else if (as + T * bs == 2 + T * 1) {
              transfer(balance(tok0), tok0).to(this);
              transfer(price).to(Alice);
              return tok5;
            } else if (as + T * bs == 3 + T * 1) {
              transfer(balance(tok5), tok5).to(this);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 4 + T * 1) {
              transfer(balance(tok1), tok1).to(this);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 5 + T * 1) {
              transfer(balance(tok3), tok3).to(this);
              transfer(price).to(Alice);
              return tok0; // XXX
            } else if (as + T * bs == 0 + T * 2) {
              transfer(balance(tok0), tok0).to(this);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 1 + T * 2) {
              transfer(balance(tok3), tok3).to(this);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 2 + T * 2) {
              transfer(balance(tok1), tok1).to(this);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 3 + T * 2) {
              transfer(balance(tok2), tok2).to(this);
              transfer(price).to(Alice);
              return tok5;
            } else if (as + T * bs == 4 + T * 2) {
              transfer(balance(tok5), tok5).to(this);
              transfer(price).to(Alice);
              return tok4;
            } else if (as + T * bs == 5 + T * 2) {
              transfer(balance(tok4), tok4).to(this);
              transfer(price).to(Alice);
              return tok0; // XXX
            } else if (as + T * bs == 0 + T * 3) {
              transfer(balance(tok0), tok0).to(this);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 1 + T * 3) {
              transfer(balance(tok2), tok2).to(this);
              transfer(price).to(Alice);
              return tok5;
            } else if (as + T * bs == 2 + T * 3) {
              transfer(balance(tok5), tok5).to(this);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 3 + T * 3) {
              transfer(balance(tok3), tok3).to(this);
              transfer(price).to(Alice);
              return tok4;
            } else if (as + T * bs == 4 + T * 3) {
              transfer(balance(tok4), tok4).to(this);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 5 + T * 3) {
              transfer(balance(tok1), tok1).to(this);
              transfer(price).to(Alice);
              return tok0; // XXX
            } else {
              // impossible
              return tok0; // XXX
            }
          })(),
        ];
      }
    )
    .timeout(false);
  commit();
  Bob.publish(); // bob must be alice
  Bob.only(() => interact.signal());
  transfer(balance()).to(Bob); // 1000000
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
