import { loadStdlib } from "@reach-sh/stdlib";
import launchToken from "@reach-sh/stdlib/launchToken.mjs";
import assert from "assert";

const [, , infile] = process.argv;

(async () => {
  console.log("START");

  const backend = await import(`./build/${infile}.main.mjs`);
  const stdlib = await loadStdlib();
  const startingBalance = stdlib.parseCurrency(1000);

  const accAlice = await stdlib.newTestAccount(startingBalance);
  const accBob = await stdlib.newTestAccount(startingBalance);
  const accEve = await stdlib.newTestAccount(startingBalance);
  const accs = await Promise.all(
    Array.from({ length: 10 }).map(() => stdlib.newTestAccount(startingBalance))
  );

  const getExchange = async ctc => stdlib.bigNumberToNumber((await ctc.v.exchange())[1])
  const getNext = async ctc => stdlib.bigNumberToNumber((await ctc.v.next())[1])
  const getRemaining = async ctc => stdlib.bigNumberToNumber((await ctc.v.remaining())[1])

  const reset = async (accs) => {
    await Promise.all(accs.map(rebalance));
    await Promise.all(
      accs.map(async (el) =>
        console.log(`balance (acc): ${await getBalance(accAlice)}`)
      )
    );
  };

  const rebalance = async (acc) => {
    if ((await getBalance(acc)) > 1000) {
      await stdlib.transfer(
        acc,
        accEve.networkAccount.addr,
        stdlib.parseCurrency((await getBalance(acc)) - 1000)
      );
    } else {
      await stdlib.transfer(
        accEve,
        acc.networkAccount.addr,
        stdlib.parseCurrency(1000 - (await getBalance(acc)))
      );
    }
  };

  const zorkmid = await launchToken(stdlib, accAlice, "zorkmid", "ZMD");
  const gil = await launchToken(stdlib, accBob, "gil", "GIL");
  const tok0 = await launchToken(stdlib, accAlice, "tok0", "TOK0");
  const tok1 = await launchToken(stdlib, accAlice, "tok1", "TOK1");
  const tok2 = await launchToken(stdlib, accAlice, "tok2", "TOK2");
  const tok3 = await launchToken(stdlib, accAlice, "tok3", "TOK3");
  const tok4 = await launchToken(stdlib, accAlice, "tok4", "TOK4");
  const tok5 = await launchToken(stdlib, accAlice, "tok5", "TOK5");
  const tok6 = await launchToken(stdlib, accAlice, "tok6", "TOK6");
  await accAlice.tokenAccept(gil.id);
  await accBob.tokenAccept(zorkmid.id);

  const getBalance = async (who) =>
    stdlib.formatCurrency(await stdlib.balanceOf(who), 4);

  const beforeAlice = await getBalance(accAlice);
  const beforeBob = await getBalance(accBob);

  const getParams = (addr) => ({
    addr,
    addr2: addr,
    addr3: addr,
    addr4: addr,
    addr5: addr,
    amt: stdlib.parseCurrency(1),
    tok: zorkmid.id,
    token_name: "",
    token_symbol: "",
    secs: 0,
    secs2: 0,
  });

  const signal = () => {};

  // (1) can be deleted before activation
  console.log("CAN DELETED INACTIVE");
  (async (acc) => {
    let addr = acc.networkAccount.addr;
    let ctc = acc.contract(backend);
    Promise.all([
      backend.Constructor(ctc, {
        getParams: () => getParams(addr),
        signal,
      }),
      backend.Verifier(ctc, {}),
    ]).catch(console.dir);
    let appId = await ctc.getInfo();
    console.log(appId);
  })(accAlice);
  await stdlib.wait(4);

  await reset([accAlice, accBob]);

  // (2) constructor receives payment on activation
  console.log("CAN ACTIVATE WITH PAYMENT");
  await (async (acc, acc2) => {
    let addr = acc.networkAccount.addr;
    let ctc = acc.contract(backend);
    Promise.all([
      backend.Constructor(ctc, {
        getParams: () => getParams(addr),
        signal,
      }),
    ]);
    let appId = await ctc.getInfo();
    console.log(appId);
    let ctc2 = acc2.contract(backend, appId);
    Promise.all([backend.Contractee(ctc2, {})]);
    await stdlib.wait(50);
  })(accAlice, accBob);
  await stdlib.wait(4);

  const afterAlice = await getBalance(accAlice);
  const afterBob = await getBalance(accBob);

  const diffAlice = Math.round(afterAlice - beforeAlice);
  const diffBob = Math.round(afterBob - beforeBob);

  console.log(
    `Alice went from ${beforeAlice} to ${afterAlice} (${diffAlice}).`
  );
  console.log(`Bob went from ${beforeBob} to ${afterBob} (${diffBob}).`);

  assert.equal(diffAlice, 1);
  assert.equal(diffBob, -1);

  await reset([accAlice, accBob]);

  console.log("CAN ROLL ALL");
  await (async (acc, acc2) => {
    let addr = acc.networkAccount.addr;
    let ctc = acc.contract(backend);
    Promise.all([
      backend.Constructor(ctc, {
        getParams: () => getParams(addr),
        signal,
      }),
    ]);
    let appId = await ctc.getInfo();
    console.log(appId);
    let ctc2 = acc2.contract(backend, appId);
    let ctc3 = acc.contract(backend, appId);

    Promise.all([
      backend.Contractee(ctc2, {}),
      backend.Alice(ctc3, {
        getParams: () => ({
          tokens: [
            tok0.id,
            tok1.id,
            tok2.id,
            tok3.id,
            tok4.id,
            tok5.id,
            tok6.id,
          ],
        }),
        ...stdlib.hasConsoleLogger
      }),
      backend.Bob(ctc2, {
        signal: () => {
          console.log("BOB");
        },
      }),
    ]);
    await stdlib.wait(100);
    console.log("exchange", await getExchange(ctc3));
    console.log("next", await getNext(ctc3));
    assert(await getExchange(ctc3) !== await getNext(ctc3), "next != exchange");
    console.log("roll 1");
    console.log("remaining", await getRemaining(ctc3));
    await ctc3.a.touch();
    await stdlib.wait(10);
    console.log("roll 2");
    console.log("next", await getNext(ctc3));
    console.log("remaining", await getRemaining(ctc3));
    await ctc3.a.touch();
    await stdlib.wait(10);
    console.log("roll 3");
    console.log("next", await getNext(ctc3));
    console.log("remaining", await getRemaining(ctc3));
    await ctc3.a.touch();
    await stdlib.wait(10);
    console.log("roll 4");
    console.log("next", await getNext(ctc3));
    console.log("remaining", await getRemaining(ctc3));
    await ctc3.a.touch();
    await stdlib.wait(10);
    console.log("roll 5");
    console.log("next", await getNext(ctc3));
    console.log("remaining", await getRemaining(ctc3));
    await ctc3.a.touch();
    await stdlib.wait(10);
    console.log("roll 6");
    console.log("next", await getNext(ctc3));
    console.log("remaining", await getRemaining(ctc3));
    await ctc3.a.touch();
    await stdlib.wait(10);
  })(accAlice, accBob);
  await stdlib.wait(100);

  console.log("CAN ROLL NONE");
  console.log("- BOB TRIES TO ROLL WITHOUT EXCHANGE TOKEN");
  await (async (acc, acc2) => {
    let addr = acc.networkAccount.addr;
    let ctc = acc.contract(backend);
    Promise.all([
      backend.Constructor(ctc, {
        getParams: () => getParams(addr),
        signal,
      }),
    ]);
    let appId = await ctc.getInfo();
    console.log(appId);
    let ctc2 = acc2.contract(backend, appId);
    let ctc3 = acc.contract(backend, appId);

    Promise.all([
      backend.Contractee(ctc2, {}),
      backend.Alice(ctc3, {
        getParams: () => ({
          tokens: [
            tok0.id,
            tok1.id,
            tok2.id,
            tok3.id,
            tok4.id,
            tok5.id,
            tok6.id,
          ],
        }),
      }),
      backend.Bob(ctc2, {
        signal: () => {
          console.log("BOB");
        },
      }),
    ]);
    await stdlib.wait(100);
    console.log("roll 1");
    await ctc2.a.touch().catch(console.dir);

  })(accAlice, accBob);
  await stdlib.wait(100);

  process.exit();
})();
