"reach 0.1";
"use strict";

import { hasSignal } from "util.rsh";

const SERIAL_VER = 0;
const T = 6; // TOTAL TOKENS
const FEE_RELAY = 16_000; // 1000uA profit
const FEE_TOUCH = 6_000; // zero net profit
const FEE_TAKE = 2_000_000; // platform takes 2A
const FEE_CONSTRUCT = 14_000; // zero net profit

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.7 - add post deposit signal
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Event = () => [];
export const Participants = () => [
  Participant("Manager", {
    getParams: Fun(
      [],
      Object({
        price: UInt,
        reward: UInt,
        //ctcEvent: Contract,
      })
    ),
    ...hasSignal,
  }),
  Participant("Relay", {
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
    //claim: Fun([UInt], Null),
    //register: Fun([], Null),
  }),
];

// TODO calculate reward as max(2000000, price/100)

export const App = (map) => {
  const [
    { amt, ttl, tok0, tok1, tok2, tok3, tok4, tok5 },
    [addr, _],
    [Manager, Relay],
    [v],
    [a],
    _,
  ] = map;
  Manager.only(() => {
    const { price /*, ctcEvent*/ } = declassify(interact.getParams());
    assume(price > 0);
  });
  Manager.publish(price /*, ctcEvent*/)
    .pay([
      FEE_CONSTRUCT + FEE_RELAY + FEE_TOUCH * 6 + amt + SERIAL_VER,
      [1, tok0],
      [1, tok1],
      [1, tok2],
      [1, tok3],
      [1, tok4],
      [1, tok5],
    ])
    .timeout(relativeTime(ttl), () => {
      Anybody.publish();
      commit();
      exit();
    });
  require(price > 0);
  transfer(FEE_CONSTRUCT + amt + SERIAL_VER).to(addr);
  //Relay.set(Manager); // REM it doesn't work if Relay is not Manager anyway
  /*
  const r = remote(ctcEvent, {
    incr: Fun([], Null),
  });
  */
  v.manager.set(Manager);
  v.remaining.set(T);
  v.tokens.set([tok0, tok1, tok2, tok3, tok4, tok5]);
  v.price.set(price);
  v.participants.set([Manager, Manager, Manager, Manager, Manager, Manager]);
  Manager.interact.signal();
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
    .invariant(balance() >= FEE_RELAY + (T - as) * FEE_TOUCH)
    .while(keepGoing)
    // Manager can register
    /*
    .api(
      a.register,
      () => assume(this == Manager),
      () => 0,
      (k) => {
        require(this == Manager);
        r.incr();
        k(null);
        return [true, as, bs, next, lst];
      }
    )
    */
    // Manager can destroy pack
    .api(
      a.destroy,
      () => assume(this == Manager),
      () => 0,
      (k) => {
        require(this == Manager);
        k(null);
        return [false, as, bs, next, lst];
      }
    )
    // Anyone can touch the pack
    .api(
      a.touch,
      () => assume(as < T && !Array.includes(lst, this)),
      () => price + FEE_TAKE,
      (k) => {
        require(as < T && !Array.includes(lst, this));
        k(null);
        transfer(FEE_TOUCH).to(this);
        transfer(FEE_TAKE).to(addr);
        transfer(price).to(Manager);
        return [
          as < 5 ? /*keepGoing*/ true : false,
          as + 1,
          cs,
          (() => {
            // -----------------------------------
            // 1 2 3 0 4 5
            // -----------------------------------
            if (as + T * bs == 0 + T * 0) {
              transfer(balance(tok1), tok1).to(this);
              return tok2;
            } else if (as + T * bs == 1 + T * 0) {
              transfer(balance(tok2), tok2).to(this);
              return tok3;
            } else if (as + T * bs == 2 + T * 0) {
              transfer(balance(tok3), tok3).to(this);
              return tok0;
            } else if (as + T * bs == 3 + T * 0) {
              transfer(balance(tok0), tok0).to(this);
              return tok4;
            } else if (as + T * bs == 4 + T * 0) {
              transfer(balance(tok4), tok4).to(this);
              return tok5;
            } else if (as + T * bs == 5 + T * 0) {
              transfer(balance(tok5), tok5).to(this);
              return tok0; // XXX
              // -----------------------------------
              // 2 1 0 3 4 5
              // -----------------------------------
            } else if (as + T * bs == 0 + T * 1) {
              transfer(balance(tok2), tok2).to(this);
              return tok1;
            } else if (as + T * bs == 1 + T * 1) {
              transfer(balance(tok1), tok1).to(this);
              return tok0;
            } else if (as + T * bs == 2 + T * 1) {
              transfer(balance(tok0), tok0).to(this);
              return tok3;
            } else if (as + T * bs == 3 + T * 1) {
              transfer(balance(tok3), tok3).to(this);
              return tok4;
            } else if (as + T * bs == 4 + T * 1) {
              transfer(balance(tok4), tok4).to(this);
              return tok5;
            } else if (as + T * bs == 5 + T * 1) {
              transfer(balance(tok5), tok5).to(this);
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
  Relay.publish(); // bob must be alice
  Relay.only(() => interact.signal());
  transfer(balance()).to(Relay); // 1000000
  transfer(balance(tok0), tok0).to(Manager);
  transfer(balance(tok1), tok1).to(Manager);
  transfer(balance(tok2), tok2).to(Manager);
  transfer(balance(tok3), tok3).to(Manager);
  transfer(balance(tok4), tok4).to(Manager);
  transfer(balance(tok5), tok5).to(Manager);
  commit();
  exit();
};
// ----------------------------------------------
