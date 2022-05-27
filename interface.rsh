"reach 0.1";
"use strict";

import { requireTok6WithFloorDeadline, hasSignal } from "util.rsh";

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
        tokens: Array(Token, T), // 6 tokens
        reward: UInt,
        //ctcEvent: Contract
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
    tokens: Tuple(Token, Token, Token, Token, Token, Token),
    participants: Tuple(Address, Address, Address, Address, Address, Address),
    next: Token,
  }),
];
export const Api = () => [
  API({
    touch: Fun([], Null),
    destroy: Fun([], Null),
    claim: Fun([UInt], Null),
  }),
];

const reward = 1000000; // XXX
// TODO calculate reward as max(2000000, price/100)
const take = 2000000; // XXX

export const App = (map) => {
  const [[addr, _, addr2], [Alice, Bob], [v], [a]] = map;
  const {
    tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
    price,
    //ctcEvent
  } = requireTok6WithFloorDeadline(Alice, addr2);
  Alice.pay([
    reward + price / 1000000, // store price in balance
    [1, tok0],
    [1, tok1],
    [1, tok2],
    [1, tok3],
    [1, tok4],
    [1, tok5],
  ]).timeout(relativeTime(10), () => {
    Anybody.publish();
    commit();
    exit();
  });
  Bob.set(Alice); // REM it doesn't work if Bob is not Alice anyway
  Alice.interact.signal();
  v.manager.set(Alice);
  v.remaining.set(T);
  v.tokens.set([tok0, tok1, tok2, tok3, tok4, tok5]);
  v.price.set(price);
  v.participants.set([Alice, Alice, Alice, Alice, Alice, Alice]);
  const bs = lastConsensusSecs() % 2; // XXX
  const [keepGoing, as, cs, next, lst] = parallelReduce([
    true,
    0,
    0,
    (() => {
      if (bs == 0) {
        return tok1;
      } else if (bs == 1) {
        return tok2;
      } else {
        // impossible
        return tok0; // XXX
      }
    })(),
    Array.replicate(T, addr),
  ])
    .define(() => {
      v.remaining.set(T - as);
      v.next.set(next);
      v.participants.set([lst[0], lst[1], lst[2], lst[3], lst[4], lst[5]]);
    })
    .invariant(balance() >= reward)
    .while(keepGoing)
    // Alice can destroy pack
    .api(
      a.destroy,
      () => assume(this == Alice),
      () => 0,
      (k) => {
        require(this == Alice);
        k(null);
        return [false, as, bs, next, lst];
      }
    )
    // Participants can claim token
    .api(
      a.claim,
      (m) => assume(m < T && lst[m % T] == this && this != addr),
      (_) => 0,
      (m, k) => {
        require(m < T && lst[m % T] == this && this != addr);
        k(null);
        // -----------------------------------
        // 1 2 3 0 4 5
        // -----------------------------------
        if (bs == 0) {
          if (m % T == 0) {
            transfer(balance(tok1), tok1).to(this);
          } else if (m % T == 1) {
            transfer(balance(tok2), tok2).to(this);
          } else if (m % T == 2) {
            transfer(balance(tok3), tok3).to(this);
          } else if (m % T == 3) {
            transfer(balance(tok0), tok0).to(this);
          } else if (m % T == 4) {
            transfer(balance(tok4), tok4).to(this);
          } else if (m % T == 5) {
            transfer(balance(tok5), tok5).to(this);
          }
        }
        // -----------------------------------
        // 2 1 0 3 4 5
        // -----------------------------------
        else if (bs == 1) {
          if (m % T == 0) {
            transfer(balance(tok2), tok2).to(this);
          } else if (m % T == 1) {
            transfer(balance(tok1), tok1).to(this);
          } else if (m % T == 2) {
            transfer(balance(tok0), tok0).to(this);
          } else if (m % T == 3) {
            transfer(balance(tok3), tok3).to(this);
          } else if (m % T == 4) {
            transfer(balance(tok4), tok4).to(this);
          } else if (m % T == 5) {
            transfer(balance(tok5), tok5).to(this);
          }
        }
        return [true, as, bs + 1, next, lst];
      }
    )
    // Anyone can touch the pack
    .api(
      a.touch,
      () => assume(as < T && !Array.includes(lst, this)),
      () => price + take,
      (k) => {
        require(as < T && !Array.includes(lst, this));
        k(null);
        return [
          true,
          as + 1,
          cs,
          (() => {
            // -----------------------------------
            // 1 2 3 0 4 5
            // -----------------------------------
            if (as + T * bs == 0 + T * 0) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok2;
            } else if (as + T * bs == 1 + T * 0) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 2 + T * 0) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0;
            } else if (as + T * bs == 3 + T * 0) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok4;
            } else if (as + T * bs == 4 + T * 0) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok5;
            } else if (as + T * bs == 5 + T * 0) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0; // XXX
              // -----------------------------------
              // 2 1 0 3 4 5
              // -----------------------------------
            } else if (as + T * bs == 0 + T * 1) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok1;
            } else if (as + T * bs == 1 + T * 1) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0;
            } else if (as + T * bs == 2 + T * 1) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok3;
            } else if (as + T * bs == 3 + T * 1) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok4;
            } else if (as + T * bs == 4 + T * 1) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok5;
            } else if (as + T * bs == 5 + T * 1) {
              transfer(take).to(addr);
              transfer(price).to(Alice);
              return tok0; // XXX
            } else {
              // impossible
              return tok0; // XXX
            }
          })(),
          Array.set(lst, as, this),
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
