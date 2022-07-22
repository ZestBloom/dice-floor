"reach 0.1";
"use strict";

import { requireTok6WithPriceDeadline, hasSignal } from "util.rsh";

const T = 6; // TOTAL TOKENS
const SERIAL_VER = 0;
const DIST_LENGTH = 10;
const FEE_RELAY = 1000000;
const reward = 1000000; // XXX
// TODO calculate reward as max(2000000, price/100)
const take = 2000000; // XXX

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.7 - add post deposit signal
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () => [
  Participant("Manager", {
    getParams: Fun(
      [],
      Object({
        prices: Array(UInt, T), // 6 prices
        tokens: Array(Token, T), // 6 tokens
        reward: UInt, // ??
        //ctcEvent: Contract, // app info for register api
        addrs: Array(Address, DIST_LENGTH),
        distr: Array(UInt, DIST_LENGTH),
        royaltyCap: UInt,
      })
    ),
    ...hasSignal,
  }),
  ParticipantClass("Relay", {
    ...hasSignal,
  }),
];
export const Views = () => [
  View({
    manager: Address,
    prices: Tuple(UInt, UInt, UInt, UInt, UInt, UInt),
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



export const App = (map) => {
  const [[addr, _, addr2], [Manager, Relay], [v], [a]] = map;
  const {
    tokens: [tok0, tok1, tok2, tok3, tok4, tok5],
    prices: [prc0, prc1, prc2, prc3, prc4, prc5],
    addrs,
    distr,
    royaltyCap,
  } = requireTok6WithPriceDeadline(Manager, addr2);
  Manager.pay([
    reward + SERIAL_VER + FEE_RELAY, // with serial version
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
  //Relay.set(Manager); // REM it doesn't work if Relay is not Alice anyway
  Manager.interact.signal();
  /*
  const r = remote(ctcEvent, {
    incr: Fun([], Null),
  });
  */
  v.manager.set(Manager);
  v.remaining.set(T);
  v.tokens.set([tok0, tok1, tok2, tok3, tok4, tok5]);
  v.prices.set([prc0, prc1, prc2, prc3, prc4, prc5]);
  v.participants.set([Manager, Manager, Manager, Manager, Manager, Manager]);
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
    .invariant(balance() >= reward + FEE_RELAY + SERIAL_VER)
    .while(keepGoing)
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
      () =>
        ((ds) => {
          if (ds == 0) {
            return prc0;
          } else if (ds == 1) {
            return prc1;
          } else if (ds == 2) {
            return prc2;
          } else if (ds == 3) {
            return prc3;
          } else if (ds == 4) {
            return prc4;
          } else if (ds == 5) {
            return prc5;
          } else {
            // impossible
            return prc0;
          }
        })(as), // + take,
      (k) => {
        require(as < T && !Array.includes(lst, this));
        k(null);
        /*
        const price = ((ds) => {
          if (ds == 0) {
            return prc0;
          } else if (ds == 1) {
            return prc1;
          } else if (ds == 2) {
            return prc2;
          } else if (ds == 3) {
            return prc3;
          } else if (ds == 4) {
            return prc4;
          } else if (ds == 5) {
            return prc5;
          } else {
            // impossible
            return prc0;
          }
        })(as);
        */
        //transfer(take).to(addr);
        //transfer(price).to(Manager);
        return [
          true,
          as + 1,
          cs,
          (() => {
            // -----------------------------------
            // 0 1 2 3 4 5
            // -----------------------------------
            if (as + T * bs == 0 + T * 0) {
              //transfer(balance(tok0), tok0).to(this);
              return tok1;
            } else if (as + T * bs == 1 + T * 0) {
              //transfer(balance(tok1), tok1).to(this);
              return tok2;
            } else if (as + T * bs == 2 + T * 0) {
              //transfer(balance(tok2), tok2).to(this);
              return tok3;
            } else if (as + T * bs == 3 + T * 0) {
              //transfer(balance(tok3), tok3).to(this);
              return tok4;
            } else if (as + T * bs == 4 + T * 0) {
              //transfer(balance(tok4), tok4).to(this);
              return tok5;
            } else if (as + T * bs == 5 + T * 0) {
              //transfer(balance(tok5), tok5).to(this);
              return tok0;
              // -----------------------------------
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
  // Step: split payment
  Relay.publish();
  const total = balance()//- reward - SERIAL_VER - FEE_RELAY;
  const cent = total / 100;
  const partTake = (total - cent) / royaltyCap;
  //const distrTake = distr.slice(1, DIST_LENGTH - 1).sum();
  //const recvAmount = balance() - partTake * distrTake; // REM includes reward amount
  transfer(partTake * distr[0]).to(addrs[0]);
  transfer(partTake * distr[1]).to(addrs[1]);
  transfer(partTake * distr[2]).to(addrs[2]);
  transfer(partTake * distr[3]).to(addrs[3]);
  commit();
  Relay.publish();
  transfer(partTake * distr[4]).to(addrs[4]);
  transfer(partTake * distr[5]).to(addrs[5]);
  transfer(partTake * distr[6]).to(addrs[6]);
  transfer(partTake * distr[7]).to(addrs[7]);
  commit();
  Relay.only(() => {
    const rAddr = this;
    assume(this == Manager);
  });
  Relay.publish(rAddr); // bob must be alice
  require(rAddr == Manager);
  transfer(partTake * distr[8]).to(addrs[8]);
  transfer(partTake * distr[9]).to(addrs[9]);
  // Relay participant receives reward
  //transfer(FEE_RELAY).to(rAddr);
  commit();
  Relay.publish();
  transfer(balance()).to(Manager); // 1000000
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
