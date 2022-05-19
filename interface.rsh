"reach 0.1";
"use strict";

import { requireTok5WithFloorDeadline, hasSignal } from "util.rsh";

const T = 4; // TOTAL TOKENS

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
        tokens: Array(Token, T + 1), // 6 tokens + 1 exchange token
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
    manager: Address,
    price: UInt,
    remaining: UInt,
    tokens: Tuple(Token, Token, Token, Token),
    participants: Tuple(Address, Address, Address, Address),
    exchange: Token,
    next: Token,
  }),
];
export const Api = () => [
  API({
    touch: Fun([], Null),
    ppc: Fun([UInt], Null),
    destroy: Fun([], Null),
  }),
];

const reward = 1000000; // XXX
const take = 2000000; // XXX

export const App = (map) => {
  const [[addr, _, addr2], [Alice, Bob], [v], [a]] = map;
  const {
    tokens: [tok0, tok1, tok2, tok3, tok4],
    price
  } = requireTok5WithFloorDeadline(Alice, addr2);
  Alice.pay([reward, [1, tok0], [1, tok1], [1, tok2], [1, tok3]]).timeout(
    relativeTime(10),
    () => {
      Anybody.publish();
      commit();
      exit();
    }
  );
  Bob.set(Alice); // REM it doesn't work if Bob is not Alice anyway
  Alice.interact.signal();
  v.manager.set(Alice);
  v.remaining.set(T);
  v.tokens.set([tok0, tok1, tok2, tok3]);
  v.price.set(price);
  v.exchange.set(tok4);
  v.participants.set([Alice, Alice, Alice, Alice]);
  const bs = lastConsensusSecs() % 4; // XXX
  const [as, next, lst] = parallelReduce([
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
    Array.replicate(4, addr)
  ])
    .define(() => {
      v.remaining.set(T - as);
      v.next.set(next);
      v.participants.set([lst[0], lst[1], lst[2], lst[3]]);
    })
    .invariant(balance() >= reward)
    .while(as < T)
    .api(
      a.destroy,
      () => assume(this == Alice),
      () => [0, [0, tok4]],
      (k) => {
        require(this == Alice);
        k(null);
        return [T, next, lst];
      }
    )
    .api(
      a.ppc,
      (_) => assume(true),
      (m) => [m, [0, tok4]],
      (m, k) => {
        require(true);
        transfer(m).to(addr);
        k(null);
        return [as, next, lst];
      }
    )
    .api(
      a.touch,
      () => assume(!Array.includes(lst, this)),
      () => [price+take, [1, tok4]],
      (k) => {
        require(!Array.includes(lst, this));
        k(null);
        return [
          as + 1,
          (() => {
            // -----------------------------------
            // 1 2 3 0
            // -----------------------------------
            if (as + T * bs == 0 + T * 0) {
              transfer(balance(tok1), tok1).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 1 + T * 0) {
              transfer(balance(tok2), tok2).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 2 + T * 0) {
              transfer(balance(tok3), tok3).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0;
            } else if (as + T * bs == 3 + T * 0) {
              transfer(balance(tok0), tok0).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0;
              // -----------------------------------
              // 2 1 0 3
              // -----------------------------------
            } else if (as + T * bs == 0 + T * 1) {
              transfer(balance(tok2), tok2).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 1 + T * 1) {
              transfer(balance(tok1), tok1).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0;
            } else if (as + T * bs == 2 + T * 1) {
              transfer(balance(tok0), tok0).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 3 + T * 1) {
              transfer(balance(tok3), tok3).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0; // XXX
              // -----------------------------------
              // 0 3 1 2
              // -----------------------------------
            } else if (as + T * bs == 0 + T * 2) {
              transfer(balance(tok0), tok0).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 1 + T * 2) {
              transfer(balance(tok3), tok3).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 2 + T * 2) {
              transfer(balance(tok1), tok1).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 3 + T * 2) {
              transfer(balance(tok2), tok2).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0; // XXX
              // -----------------------------------
              // 0 2 1 3
              // -----------------------------------
            } else if (as + T * bs == 0 + T * 3) {
              transfer(balance(tok0), tok0).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 1 + T * 3) {
              transfer(balance(tok2), tok2).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 2 + T * 3) {
              transfer(balance(tok1), tok1).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 3 + T * 3) {
              transfer(balance(tok3), tok3).to(this);
              transfer(balance(tok4), tok4).to(Alice);
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0;
              // -----------------------------------
            } else {
              // impossible
              return tok0; // XXX
            }
          })(),
          Array.set(lst, as, this)
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
  commit();
  exit();
};
// ----------------------------------------------
